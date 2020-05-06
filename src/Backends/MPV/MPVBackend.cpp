#include "src/Backends/MPV/MPVBackend.hpp"
#include "src/Backends/MPVCommon/MPVCommon.hpp"
#include "src/qthelper.hpp"
#include "src/utils.hpp"
#include <QByteArray>
#include <QCoreApplication>
#include <QDebug>
#include <QEvent>
#include <QGuiApplication>
#include <QIcon>
#include <QMetaObject>
#include <QObject>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QQuickWindow>
#include <QtCore/qglobal.h>
#include <clocale>
#include <iostream>
#include <mpv/render_gl.h>
#include <stdexcept>
#include <stdio.h>
class QQuickItem;
class QSize;

#if defined(__linux__) || defined(__FreeBSD__)
#ifdef ENABLE_X11
#include <QX11Info> // IWYU pragma: keep
#include <QtX11Extras/QX11Info> // IWYU pragma: keep
#include <X11/Xlib.h> // IWYU pragma: keep
#include <X11/Xutil.h> // IWYU pragma: keep
#include <qx11info_x11.h> // IWYU pragma: keep
#endif
#include <qpa/qplatformnativeinterface.h> // IWYU pragma: keep
#endif

bool usedirect = false;

namespace {

void wakeup(void* ctx)
{
    QCoreApplication::postEvent((MPVBackend*)ctx, new QEvent(QEvent::User));
}

void on_mpv_redraw(void* ctx)
{
    QMetaObject::invokeMethod(
        reinterpret_cast<MPVBackend*>(ctx), "update", Qt::QueuedConnection);
}

static void*
get_proc_address_mpv(void* ctx, const char* name)
{
    return reinterpret_cast<void*>(
        reinterpret_cast<QOpenGLContext*>(ctx)->getProcAddress(QByteArray(name)));
}

} // namespace

class MpvRenderer : public QQuickFramebufferObject::Renderer {
    MPVBackend* obj;

public:
    MpvRenderer(MPVBackend* new_obj)
        : obj{ new_obj }
    {
        if (usedirect) {
            int r = mpv_opengl_cb_init_gl(obj->mpv_gl_cb, NULL, get_proc_address_mpv, QOpenGLContext::currentContext());
            if (r < 0) {
                std::cout << "No." << std::endl;
                throw std::runtime_error("failed to initialize mpv GL context");
            }
        }
    }

    virtual ~MpvRenderer() {}

    // This function is called when a new FBO is needed.
    // This happens on the initial frame.
    QOpenGLFramebufferObject* createFramebufferObject(const QSize& size)
    {
        // init mpv_gl:
        if (!obj->mpv_gl && !usedirect) {
            mpv_opengl_init_params gl_init_params{ get_proc_address_mpv,
                QOpenGLContext::currentContext(),
                nullptr };
            mpv_render_param params[]{
                { MPV_RENDER_PARAM_API_TYPE,
                    const_cast<char*>(MPV_RENDER_API_TYPE_OPENGL) },
                { MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params },
                { MPV_RENDER_PARAM_INVALID, nullptr },
                { MPV_RENDER_PARAM_INVALID, nullptr }
            };
#if defined(__linux__) || defined(__FreeBSD__)
#ifdef ENABLE_X11
            if (QGuiApplication::platformName().contains("xcb")) {
                params[2].type = MPV_RENDER_PARAM_X11_DISPLAY;
                params[2].data = QX11Info::display();
            }
#endif
            if (QGuiApplication::platformName().contains("wayland")) {
                params[2].type = MPV_RENDER_PARAM_WL_DISPLAY;
                auto* native = QGuiApplication::platformNativeInterface();
                params[2].data = native->nativeResourceForWindow("display", NULL);
            }
#endif

            if (mpv_render_context_create(&obj->mpv_gl, obj->mpv, params) < 0) {
                std::cout << "Failed to use render API, try setting Backend/direct to true in settings." << std::endl;
                throw std::runtime_error("failed to initialize mpv GL context");
            }
            mpv_render_context_set_update_callback(obj->mpv_gl, on_mpv_redraw, obj);
        }
        QMetaObject::invokeMethod(obj, "startPlayer");

        return QQuickFramebufferObject::Renderer::createFramebufferObject(size);
    }

    void render()
    {
        obj->window()->resetOpenGLState();
        QOpenGLFramebufferObject* fbo = framebufferObject();
        if (usedirect) {
            mpv_opengl_cb_draw(obj->mpv_gl_cb, fbo->handle(), fbo->width(), fbo->height());
        } else {
            mpv_opengl_fbo mpfbo{ .fbo = static_cast<int>(fbo->handle()),
                .w = fbo->width(),
                .h = fbo->height(),
                .internal_format = 0 };
            int flip_y{ 0 };
            mpv_render_param params[] = { { MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo },
                { MPV_RENDER_PARAM_FLIP_Y, &flip_y },
                { MPV_RENDER_PARAM_INVALID, nullptr } };
            mpv_render_context_render(obj->mpv_gl, params);
        }

        obj->window()->resetOpenGLState();
    }
};

MPVBackend::MPVBackend(QQuickItem* parent)
    : QQuickFramebufferObject(parent)
    , mpv{ mpv_create() }
    , mpv_gl(nullptr)
    , mpv_gl_cb(nullptr)

{
    if (!mpv)
        throw std::runtime_error("could not create mpv context");

    QSettings settings;
    usedirect = settings.value("Backend/direct", false).toBool();

    mpv_set_option_string(mpv, "terminal", "true");
    mpv_set_option_string(mpv, "msg-level", "all=v");

    // Fix?
    mpv_set_option_string(mpv, "ytdl", "yes");

    mpv_set_option_string(mpv, "slang", "en");

    mpv_set_option_string(mpv, "config", "yes");
    mpv_observe_property(mpv, 0, "tracks-menu", MPV_FORMAT_NONE);
    mpv_observe_property(mpv, 0, "chapter-list", MPV_FORMAT_NODE);
    mpv_observe_property(mpv, 0, "playback-abort", MPV_FORMAT_NONE);
    mpv_observe_property(mpv, 0, "chapter-list", MPV_FORMAT_NODE);
    mpv_observe_property(mpv, 0, "track-list", MPV_FORMAT_NODE);
    mpv_observe_property(mpv, 0, "audio-device-list", MPV_FORMAT_NODE);
    mpv_observe_property(mpv, 0, "playlist-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "volume", MPV_FORMAT_NONE);
    mpv_observe_property(mpv, 0, "mute", MPV_FORMAT_NONE);
    mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "media-title", MPV_FORMAT_STRING);
    mpv_observe_property(mpv, 0, "sub-text", MPV_FORMAT_STRING);
    mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "demuxer-cache-duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_NODE);
    mpv_observe_property(mpv, 0, "playlist", MPV_FORMAT_NODE);
    mpv_observe_property(mpv, 0, "speed", MPV_FORMAT_DOUBLE);

    mpv_request_log_messages(mpv, "v");

    mpv_set_wakeup_callback(mpv, wakeup, this);

    if (mpv_initialize(mpv) < 0)
        throw std::runtime_error("could not initialize mpv context");

    if (usedirect) {
        mpv_set_option_string(mpv, "vo", "libmpv");
        mpv_gl_cb = (mpv_opengl_cb_context*)mpv_get_sub_api(mpv, MPV_SUB_API_OPENGL_CB);
        if (!mpv_gl_cb)
            throw std::runtime_error("OpenGL not compiled in");
        mpv_opengl_cb_set_update_callback(mpv_gl_cb, on_mpv_redraw, (void*)this);
    } else {
        mpv_set_option_string(mpv, "vo", "libmpv");
    }

    connect(this,
        &MPVBackend::onUpdate,
        this,
        &MPVBackend::doUpdate,
        Qt::QueuedConnection);
    connect(this,
        &MPVBackend::positionChanged,
        this,
        &MPVBackend::updateDurationString,
        Qt::QueuedConnection);
    connect(this,
        &MPVBackend::durationChanged,
        this,
        &MPVBackend::updateDurationString,
        Qt::QueuedConnection);
}

MPVBackend::~MPVBackend()
{
    printf("Shutting down...\n");
    Utils::SetDPMS(true);
    command("write-watch-later-config");

    if (usedirect && mpv_gl_cb) {
        mpv_opengl_cb_uninit_gl(mpv_gl_cb);
    } else if (mpv_gl) {
        mpv_render_context_free(mpv_gl);
    }

    mpv_terminate_destroy(mpv);
    printf("MPV terminated.\n");
}

void MPVBackend::on_update(void* ctx)
{
    MPVBackend* self = (MPVBackend*)ctx;
    emit self->onUpdate();
}

void MPVBackend::doUpdate()
{
    update();
}

QVariant
MPVBackend::getProperty(const QString& name) const
{
    return mpv::qt::get_property_variant(mpv, name);
}

void MPVBackend::command(const QVariant& params)
{
    mpv::qt::node_builder node(params);
    mpv_command_node(mpv, node.node(), nullptr);
}

void MPVBackend::setProperty(const QString& name, const QVariant& value)
{
    mpv::qt::node_builder node(value);
    qDebug() << "Setting property" << name << "to" << value;
    mpv_set_property(mpv, name.toUtf8().data(), MPV_FORMAT_NODE, node.node());
}

void MPVBackend::setOption(const QString& name, const QVariant& value)
{
    mpv::qt::set_option_variant(mpv, name, value);
}

QVariant
MPVBackend::playerCommand(const Enums::Commands& cmd)
{
    return playerCommand(cmd, QVariant("NoArgProvided"));
}

QVariant
MPVBackend::playerCommand(const Enums::Commands& cmd, const QVariant& args)
{
    return MPVCommon::playerCommand(this, cmd, args);
}

QString
MPVBackend::getStats()
{
    return MPVCommon::getStats(this);
}

void MPVBackend::updateDurationString(int numTime)
{
    QMetaMethod metaMethod = sender()->metaObject()->method(senderSignalIndex());
    MPVCommon::updateDurationString(this, numTime, metaMethod);
}

void MPVBackend::toggleOnTop()
{
    onTop = !onTop;
    Utils::AlwaysOnTop(window()->winId(), onTop);
}

bool MPVBackend::event(QEvent* event)
{
    if (event->type() == QEvent::User) {
        on_mpv_events();
    }
    return QObject::event(event);
}

void MPVBackend::on_mpv_events()
{
    while (mpv) {
        mpv_event* event = mpv_wait_event(mpv, 0);
        if (event->event_id == MPV_EVENT_NONE) {
            break;
        }
        handle_mpv_event(event);
    }
}

QVariantMap
MPVBackend::getAudioDevices(const QVariant& drivers) const
{
    return MPVCommon::getAudioDevices(drivers);
}

void MPVBackend::handle_mpv_event(mpv_event* event)
{
    MPVCommon::handle_mpv_event(this, event);
}

QQuickFramebufferObject::Renderer*
MPVBackend::createRenderer() const
{
    window()->setIcon(QIcon(":/icon.png"));
    window()->setPersistentOpenGLContext(true);
    window()->setPersistentSceneGraph(true);
    return new MpvRenderer(const_cast<MPVBackend*>(this));
}
