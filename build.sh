#!/bin/sh

echo $ENABLE_FEATURE

[ -n $ENABLE_FEATURE ] || {
  echo "disabled."
  exit 0
}

echo "enabled."
