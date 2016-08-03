#!/bin/bash

timestamp=$(date "+%Y%m%d_%H%M%S")
temp_dir="/tmp/apache-spark-docs-ja/${timestamp}"

mkdir -p $temp_dir

version="1.6.0"

git co "v${version}"
./build.sh

cp -r build/_site "${temp_dir}/${version}"

git co gh-pages
rm -rf "${version}"
cp -r "${temp_dir}/${version}" .
