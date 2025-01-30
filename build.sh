#!/bin/sh

echo $ENABLE_FEATURE

if $ENABLE_FEATURE; then
  echo "enabled."
else
  echo "disabled."
fi
