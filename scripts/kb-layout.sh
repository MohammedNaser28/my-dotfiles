#!/usr/bin/env bash
layouts=$(niri msg -j keyboard-layouts)
idx=$(echo "$layouts" | jq -r '.current_idx')
name=$(echo "$layouts" | jq -r ".names[$idx]")

if [ "$1" = "--cycle" ]; then
  total=$(echo "$layouts" | jq -r '.names | length')
  next=$(( (idx + 1) % total ))
  next_name=$(echo "$layouts" | jq -r ".names[$next]")
  niri msg action switch-layout "$next_name"
  exit 0
fi

case "$name" in
  "English (US)") icon="US" ;;
  "Arabic") icon="AR" ;;
  *) icon="${name:0:2}" ;;
esac
echo "{\"text\":\"$icon\",\"tooltip\":\"$name\",\"class\":\"lang-$icon\"}"
