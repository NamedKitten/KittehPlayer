SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd $SOURCE_DIR
qmlfmt -w src/qml/*.qml
clang-format -style mozilla -i src/*
popd
