#!/bin/sh

echo $ENABLE_FEATURE

if [[ "$ENABLE_FEATURE" == "false" ]]; then
  echo "disabled."
else
  echo "enabled."
fi
