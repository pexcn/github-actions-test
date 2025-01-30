#!/bin/sh

echo $ENABLE_FEATURE

[ $ENABLE_FEATURE ] || {
  echo "disabled."
  exit 0
}

echo "enabled."
