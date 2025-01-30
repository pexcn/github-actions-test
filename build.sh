#!/bin/bash

echo "value: $ADD_KERNELSU"

add_kernelsu() {
  [ $ADD_KERNELSU = true ] || return 0

  echo "add kernelsu..."
}

add_kernelsu
echo $?
