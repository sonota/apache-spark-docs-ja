#!/bin/bash

update() {
local version="$1"; shift

timestamp=$(date "+%Y%m%d_%H%M%S")
temp_dir="/tmp/apache-spark-docs-ja/${timestamp}"

mkdir -p $temp_dir

git co "v${version}"
./build.sh

cp -r build/_site "${temp_dir}/${version}"

git co gh-pages
rm -rf "${version}"
cp -r "${temp_dir}/${version}" .
}

update "$1"
