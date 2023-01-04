#!/usr/bin/env sh

# Check if the commit message file is empty
if [ -z "$1" ]; then
  # Get the default commit message
  echo "!Added changes" >"$1"
fi
