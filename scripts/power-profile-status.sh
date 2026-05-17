#!/bin/bash

profile=$(powerprofilesctl get)

case "$profile" in
    "power-saver")
        echo "󰌪 Saver"
        ;;
    "balanced")
        echo " Balanced"
        ;;
    "performance")
        echo " Performance"
        ;;
    *)
        echo "$profile"
        ;;
esac
