#!/bin/bash

gpu_stats=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)

if [ -z "$gpu_stats" ]; then
    echo '{"text": "󰢮 N/A", "tooltip": "GPU not available", "class": "disabled"}'
    exit 0
fi

IFS=', ' read -r temp util mem_used mem_total <<< "$gpu_stats"

tooltip="GPU: ${util}%\nTemp: ${temp}°C\nVRAM: ${mem_used}/${mem_total} MB"

echo "{\"text\": \"${util}%\", \"tooltip\": \"${tooltip}\", \"class\": \"\"}"