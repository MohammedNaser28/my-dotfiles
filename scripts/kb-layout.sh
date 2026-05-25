#!/usr/bin/env bash
layouts=$(niri msg -j keyboard-layouts)
idx=$(echo "$layouts" | jq -r '.current_idx')
name=$(echo "$layouts" | jq -r ".names[$idx]")
case "$name" in
  "English (US)") icon="US" ;;
  "Arabic") icon="AR" ;;
  *) icon="${name:0:2}" ;;
esac
echo "{\"text\":\"$icon\",\"tooltip\":\"$name\",\"class\":\"lang-$icon\"}"
