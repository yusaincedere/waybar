#!/usr/bin/env bash

status="$(protonvpn status 2>/dev/null)"

# Detect connected state without matching "Disconnected"
if echo "$status" | grep -qiE 'Status:[[:space:]]*Connected|Connection Status:[[:space:]]*Connected|Connected to'; then
    class="connected"
else
    class="disconnected"
    status="Proton VPN disconnected"
fi

# Escape tooltip safely for Waybar JSON
tooltip="$(printf '%s' "$status" | python -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')"

printf '{"text":"󰖂","tooltip":"%s","class":"%s"}\n' "$tooltip" "$class"