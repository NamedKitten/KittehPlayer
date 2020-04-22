SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd $SOURCE_DIR
find . -name "*.qml" -exec qmlfmt -w {} \;
find . -name "*.cpp" -o -name "*.hpp" -o -name "*.c" -o -name "*.h" -exec clang-format90 -style mozilla -i {} \;
popdi i
