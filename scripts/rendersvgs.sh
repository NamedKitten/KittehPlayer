#!/usr/bin/env bash

set -x
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd ${SOURCE_DIR}/../src/qml/icons

for file in `find . -name "*.svg"`; do
    rendersvg "$file" "$(echo $file | sed s/.svg/.png/)"
done