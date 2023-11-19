#!/bin/sh

test() {
  [ -n $TEST ] || return 0
  echo $TEST
  [ $TEST = 1 ] || return 0
  echo ok
}

test
