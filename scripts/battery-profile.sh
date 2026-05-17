#!/bin/bash

BATTERY_PATH=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" | head -n 1)

if [ -z "$BATTERY_PATH" ]; then
    battery_text="No battery"
    battery_tooltip="Battery: not found"
else
    capacity=$(cat "$BATTERY_PATH/capacity")
    status=$(cat "$BATTERY_PATH/status")

    if [ "$capacity" -le 15 ]; then
        battery_icon=""
    elif [ "$capacity" -le 30 ]; then
        battery_icon=""
    elif [ "$capacity" -le 50 ]; then
        battery_icon=""
    elif [ "$capacity" -le 80 ]; then
        battery_icon=""
    else
        battery_icon=""
    fi

    case "$status" in
    "Charging")
        battery_icon=""
        battery_state="Charging"
        ;;
    "Full")
        battery_icon=""
        battery_state="Plugged"
        ;;
    "Not charging")
        battery_icon=""
        battery_state="Plugged"
        ;;
    "Discharging")
        battery_state="Battery"
        ;;
    *)
        battery_state="$status"
        ;;
esac

battery_text="${battery_icon} ${capacity}% ${battery_state}"
battery_tooltip="Battery: ${capacity}%\nStatus: ${status}"
fi

profile=$(powerprofilesctl get 2>/dev/null)

case "$profile" in
    "power-saver")
        profile_text="󰌪 Saver"
        ;;
    "balanced")
        profile_text=" Balanced"
        ;;
    "performance")
        profile_text=" Performance"
        ;;
    *)
        profile_text="Profile?"
        profile="unknown"
        ;;
esac

text="${battery_text}  ${profile_text}"
tooltip="${battery_tooltip}\nPower profile: ${profile}\nLeft click: cycle power profile"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"