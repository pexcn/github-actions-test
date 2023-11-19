#!/bin/sh

test() {
  [ X$TEST = X1 ] || return 0
  echo ok
}

test
