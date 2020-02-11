#!/bin/sh
# This is a hacky way to dump bottles from PR because Travis doesn't support artifacts 
base_url="https://api.bintray.com/content/autobrew/bottles/el-capitain/pr-${TRAVIS_PULL_REQUEST}"
user="autobrewbot:$(rev <<< 415365001622ff1dc7292748041cac5b4d834b52)"
for bottle in *.bottle*.*; do
target_url="$base_url/$bottle?publish=1&override=1"
curl --user "$user" --upload-file "$bottle" "$target_url"
done
