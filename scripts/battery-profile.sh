#!/bin/bash

BATTERY_PATH=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" | head -n 1)

if [ -z "$BATTERY_PATH" ]; then
    battery_icon="󰂑"
    capacity="?"
    battery_state="No battery"
    status="not found"
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
fi

profile=$(powerprofilesctl get 2>/dev/null)

case "$profile" in
    "power-saver")
        profile_icon="󰌪"
        profile_name="Power saver"
        ;;
    "balanced")
        profile_icon=""
        profile_name="Balanced"
        ;;
    "performance")
        profile_icon="󰓅"
        profile_name="Performance"
        ;;
    *)
        profile_icon="?"
        profile_name="Unknown"
        profile="unknown"
        ;;
esac

text="${battery_icon} ${capacity}% ${profile_icon}"
tooltip="Battery: ${capacity}%\nStatus: ${battery_state}\nPower profile: ${profile_name}\nLeft click: cycle power profile"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"