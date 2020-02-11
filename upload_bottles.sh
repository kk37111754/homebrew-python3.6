#!/bin/sh
# This is a hacky way to dump bottles from PR because Travis doesn't support artifacts
org="autobrew"
repo="bottles"
base_url="https://api.bintray.com/content/${org}/${repo}/el-capitain/pr-${TRAVIS_PULL_REQUEST}"
user="autobrewbot:$(rev <<< 415365001622ff1dc7292748041cac5b4d834b52)"
for bottle in *.bottle*.*; do
# Note replacing -- with -: https://github.com/Homebrew/brew/pull/4612#commitcomment-29995348
target_url="$base_url/${bottle/--/-}?publish=1&override=1"
echo "Publishing to http://dl.bintray.com/${org}/${repo}/${bottle/--/-}"
curl --user "$user" --upload-file "$bottle" "$target_url"
done
