#!/usr/bin/env sh

# see https://github.com/MisterDA/love-release for installation instructions
# on linux you'll probably need to install fakeroot and libzip

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN:${unameOut}"
esac

echo "Running on ${machine}"

if [ "${machine}" = "Linux" ]; then
    releaseType="-D"
else
    releaseType="-M"
fi

love-release ${releaseType}
