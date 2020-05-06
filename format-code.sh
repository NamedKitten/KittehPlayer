#!/usr/bin/env bash
set -x
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd $SOURCE_DIR
find . -name "*.qml" -exec qmlfmt -i 2 -w {} \;
clang-format -style=file -i $(find src -name "*.cpp" -o -name "*.hpp" -o -name "*.c" -o -name "*.h")
#find . -name "*.cpp" -o -name "*.hpp" -o -name "*.c" -o -name "*.h" -exec clang-format -style=file -i {} \;
popd
