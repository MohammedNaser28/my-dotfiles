#!/usr/bin/env bash
layouts=$(niri msg -j keyboard-layouts)
idx=$(echo "$layouts" | jq -r '.current_idx')
names=$(echo "$layouts" | jq -r '.names | length')
next=$(( (idx + 1) % names ))
name=$(echo "$layouts" | jq -r ".names[$next]")
niri msg action switch-layout "$name"