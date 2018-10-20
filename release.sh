#!/usr/bin/env sh

# see https://github.com/MisterDA/love-release for installation instructions
# on linux you'll probably need to install fakeroot and libzip

love-release # .love file
love-release -M # macos
love-release -W32 # windows 32bit
love-release -W64 # windows 64bit
love-release -D # linux debian package
