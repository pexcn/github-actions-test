#!/bin/sh

git clone https://github.com/rssnsj/portfwd
cd portfwd/src
export CC="ccache gcc"
make

ls -al /builder/.cache/ccache
echo
echo
echo
find /builder/.cache/ccache
