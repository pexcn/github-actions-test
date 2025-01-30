#!/bin/sh

echo VAL: $ENABLE_FEATURE

[ "$ENABLE_FEATURE" = true ] || { echo "disabled."; exit 0; }
echo "enabled."
