#!/bin/sh

git clone https://github.com/rssnsj/portfwd
cd portfwd/src
export CC="ccache gcc"
make
