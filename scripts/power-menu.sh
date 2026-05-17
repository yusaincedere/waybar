#!/bin/bash

choice=$(printf "Shutdown\nReboot\nLogout" | wofi --dmenu --prompt "Power Menu")

case "$choice" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
esac
