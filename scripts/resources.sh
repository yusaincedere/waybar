#!/bin/bash

STATE_FILE="/tmp/waybar-cpu-stat"

# Read current CPU counters from /proc/stat
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat

idle_now=$((idle + iowait))
total_now=$((user + nice + system + idle + iowait + irq + softirq + steal))

# Default CPU value for first run
cpu="0"

if [ -f "$STATE_FILE" ]; then
    read -r prev_total prev_idle < "$STATE_FILE"

    total_delta=$((total_now - prev_total))
    idle_delta=$((idle_now - prev_idle))

    if [ "$total_delta" -gt 0 ]; then
        cpu=$(awk "BEGIN { printf \"%.0f\", 100 * ($total_delta - $idle_delta) / $total_delta }")
    fi
fi

# Save current counters for next run
echo "$total_now $idle_now" > "$STATE_FILE"

# RAM usage
mem_percent=$(free | awk '/Mem:/ {printf "%.0f", $3 / $2 * 100}')
mem_detail=$(free -h | awk '/Mem:/ {print $3 " / " $2}')

# Disk usage for home
disk_percent=$(df -P /home | awk 'NR==2 {gsub("%","",$5); print $5}')
disk_detail=$(df -h /home | awk 'NR==2 {print $3 " / " $2 " used, " $4 " free"}')

text=" ${cpu}%   ${mem_percent}%   ${disk_percent}%"
tooltip="CPU average: ${cpu}%\nRAM: ${mem_detail}\nHome: ${disk_detail}"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"