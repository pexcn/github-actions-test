#!/bin/bash

echo "value: $ADD_KERNELSU"

add_kernelsu() {
  [ "$ADD_KERNELSU" = true ] || exit 0

  echo "add kernelsu..."
}

add_kernelsu
