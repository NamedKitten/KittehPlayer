#include "src/Backends/MPVNoFBO/MPVNoFBOBackend.hpp"
#include "src/Backends/MPVCommon/MPVCommon.hpp"
#include "src/qthelper.hpp"
#include "src/utils.hpp"
#include <QApplication>
#include <QByteArray>
#include <QCoreApplication>
#include <QDebug>
#include <QEvent>
#include <QIcon>
#include <QMetaObject>
#include <QOpenGLContext>
#include <QQuickWindow>
#include <clocale>
#include <stdexcept>
#include <stdio.h>
#include <stdlib.h>

void nofbowakeup(void* ctx)
{
    QCoreApplication::postEvent((MPVNoFBOBackend*)ctx, new QEvent(QEvent::User));
}

static void*
get_proc_address(void* ctx, const char* name)
{
    (void)ctx;
    QOpenGLContext* glctx = QOpenGLContext::currentContext();
    if (!glctx)
        return NULL;
    return (void*)glctx->getProcAddress(QByteArray(name));
}

MPVNoFBORenderer::MPVNoFBORenderer(mpv_handle* a_mpv, mpv_opengl_cb_context* a_mpv_gl)
    : mpv(a_mpv)
    , mpv_gl(a_mpv_gl)
    , window(0)
    , size()
{
    int r = mpv_opengl_cb_init_gl(mpv_gl, NULL, get_proc_address, NULL);
    if (r < 0)
        qDebug() << "could not initialize OpenGL";
}

MPVNoFBORenderer::~MPVNoFBORenderer()
{
    // Until this call is done, we need to make sure the player remains
    // alive. This is done implicitly with the mpv::qt::Handle instance
    // in this class.
    exit(0);
}

void MPVNoFBORenderer::paint()
{
    window->resetOpenGLState();

    // This uses 0 as framebuffer, which indicates that mpv will render directly
    // to the frontbuffer. Note that mpv will always switch framebuffers
    // explicitly. Some QWindow setups (such as using QQuickWidget) actually
    // want you to render into a FBO in the beforeRendering() signal, and this
    // code won't work there.
    // The negation is used for rendering with OpenGL's flipped coordinates.
    mpv_opengl_cb_draw(mpv_gl, 0, size.width(), -size.height());

    window->resetOpenGLState();
}

MPVNoFBOBackend::MPVNoFBOBackend(QQuickItem* parent)
    : QQuickItem(parent)
    , mpv_gl(0)
    , renderer(0)
{
    mpv = mpv_create();
    if (!mpv)
        throw std::runtime_error("could not create mpv context");

    mpv_set_option_string(mpv, "terminal", "no");
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
    mpv_set_wakeup_callback(mpv, nofbowakeup, this);

    if (mpv_initialize(mpv) < 0)
        throw std::runtime_error("could not initialize mpv context");

    // Make use of the MPV_SUB_API_OPENGL_CB API.
    mpv::qt::set_option_variant(mpv, "vo", "opengl-cb");

    // Setup the callback that will make QtQuick update and redraw if there
    // is a new video frame. Use a queued connection: this makes sure the
    // doUpdate() function is run on the GUI thread.
    mpv_gl = (mpv_opengl_cb_context*)mpv_get_sub_api(mpv, MPV_SUB_API_OPENGL_CB);
    if (!mpv_gl)
        throw std::runtime_error("OpenGL not compiled in");
    mpv_opengl_cb_set_update_callback(
        mpv_gl, MPVNoFBOBackend::on_update, (void*)this);

    connect(this,
        &MPVNoFBOBackend::onUpdate,
        this,
        &MPVNoFBOBackend::doUpdate,
        Qt::QueuedConnection);
    connect(this,
        &MPVNoFBOBackend::positionChanged,
        &MPVNoFBOBackend::updateDurationString);
    connect(this,
        &MPVNoFBOBackend::durationChanged,
        &MPVNoFBOBackend::updateDurationString);

    connect(this,
        &QQuickItem::windowChanged,
        this,
        &MPVNoFBOBackend::handleWindowChanged);
}

MPVNoFBOBackend::~MPVNoFBOBackend()
{
    printf("Shutting down...\n");
    qApp->quit();
    printf("MPV terminated.\n");
}

void MPVNoFBOBackend::sync()
{

    if (!renderer) {
        window()->setIcon(QIcon(":/icon.png"));
        renderer = new MPVNoFBORenderer(mpv, mpv_gl);
        connect(window(),
            &QQuickWindow::beforeRendering,
            renderer,
            &MPVNoFBORenderer::paint,
            Qt::DirectConnection);
        QMetaObject::invokeMethod(this, "startPlayer");
    }
    renderer->window = window();
    renderer->size = window()->size() * window()->devicePixelRatio();
}

void MPVNoFBOBackend::swapped()
{
    mpv_opengl_cb_report_flip(mpv_gl, 0);
}

void MPVNoFBOBackend::cleanup()
{
    if (renderer) {
        delete renderer;
        renderer = 0;
    }
}

void MPVNoFBOBackend::on_update(void* ctx)
{
    MPVNoFBOBackend* self = (MPVNoFBOBackend*)ctx;
    emit self->onUpdate();
}

void MPVNoFBOBackend::doUpdate()
{
    window()->update();
    update();
}

QVariant
MPVNoFBOBackend::getProperty(const QString& name) const
{
    return mpv::qt::get_property_variant(mpv, name);
}

void MPVNoFBOBackend::command(const QVariant& params)
{
    mpv::qt::command_variant(mpv, params);
}

void MPVNoFBOBackend::setProperty(const QString& name, const QVariant& value)
{
    mpv::qt::set_property_variant(mpv, name, value);
}

void MPVNoFBOBackend::setOption(const QString& name, const QVariant& value)
{
    mpv::qt::set_option_variant(mpv, name, value);
}

void MPVNoFBOBackend::launchAboutQt()
{
    QApplication* qapp = qobject_cast<QApplication*>(QCoreApplication::instance());
    qapp->aboutQt();
}

QVariant
MPVNoFBOBackend::playerCommand(const Enums::Commands& cmd)
{
    return playerCommand(cmd, QVariant("NoArgProvided"));
}

QVariant
MPVNoFBOBackend::playerCommand(const Enums::Commands& cmd,
    const QVariant& args)
{
    return MPVCommon::playerCommand(this, cmd, args);
}

void MPVNoFBOBackend::handleWindowChanged(QQuickWindow* win)
{
    if (!win)
        return;
    connect(win,
        &QQuickWindow::beforeSynchronizing,
        this,
        &MPVNoFBOBackend::sync,
        Qt::DirectConnection);
    connect(win,
        &QQuickWindow::sceneGraphInvalidated,
        this,
        &MPVNoFBOBackend::cleanup,
        Qt::DirectConnection);
    connect(win,
        &QQuickWindow::frameSwapped,
        this,
        &MPVNoFBOBackend::swapped,
        Qt::DirectConnection);
    win->setClearBeforeRendering(false);
}

void MPVNoFBOBackend::toggleOnTop()
{
    onTop = !onTop;
    Utils::AlwaysOnTop(window()->winId(), onTop);
}

bool MPVNoFBOBackend::event(QEvent* event)
{
    if (event->type() == QEvent::User) {
        on_mpv_events();
    }
    return QObject::event(event);
}

void MPVNoFBOBackend::on_mpv_events()
{
    while (mpv) {
        mpv_event* event = mpv_wait_event(mpv, 0);
        if (event->event_id == MPV_EVENT_NONE) {
            break;
        }
        handle_mpv_event(event);
    }
}

void MPVNoFBOBackend::updateDurationString(int numTime)
{
    QMetaMethod metaMethod = sender()->metaObject()->method(senderSignalIndex());
    MPVCommon::updateDurationString(this, numTime, metaMethod);
}

QVariantMap
MPVNoFBOBackend::getAudioDevices(const QVariant& drivers) const
{
    return MPVCommon::getAudioDevices(drivers);
}

void MPVNoFBOBackend::handle_mpv_event(mpv_event* event)
{
    MPVCommon::handle_mpv_event(this, event);
}

QString
MPVNoFBOBackend::getStats()
{
    return MPVCommon::getStats(this);
}
