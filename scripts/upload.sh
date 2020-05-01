#!/bin/bash
set -e

export TEXT=`git log -1 --pretty=%B`
export UPLOADTOOL_BODY="$TEXT\nTravis CI build log: https://travis-ci.com/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID/"

wget https://github.com/probonopd/uploadtool/raw/master/upload.sh
bash upload.sh KittehPlayer*.AppImage*
echo "Done!"
