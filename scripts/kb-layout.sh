#!/usr/bin/env bash
layouts=$(niri msg -j keyboard-layouts)
idx=$(echo "$layouts" | jq -r '.current_idx')
name=$(echo "$layouts" | jq -r ".names[$idx]")

if [ "$1" = "--cycle" ]; then
  niri msg action switch-layout next
  exit 0
fi

case "$name" in
  "English (US)") icon="US" ;;
  "Arabic") icon="AR" ;;
  *) icon="${name:0:2}" ;;
esac
echo "{\"text\":\"$icon\",\"tooltip\":\"$name\",\"class\":\"lang-$icon\"}"
