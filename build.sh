#!/bin/bash

BUILD_DIR="build"

rm -rf $BUILD_DIR

cp -r docs_orig $BUILD_DIR

ruby convert.rb

cd $BUILD_DIR

SKIP_API=1 \
  rbenv exec bundle exec \
  jekyll build
