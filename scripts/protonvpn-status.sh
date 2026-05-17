#!/usr/bin/env bash

CACHE_FILE="/tmp/waybar-vpn-public-ip"
CACHE_TTL=60

status="$(protonvpn status 2>/dev/null)"

if echo "$status" | grep -qiE 'Status:[[:space:]]*Connected|Connection Status:[[:space:]]*Connected|Connected to'; then
    class="connected"
    vpn_state="Connected"
else
    class="disconnected"
    vpn_state="Disconnected"
    status="Proton VPN disconnected"
fi

# Public IP cache so Waybar does not spam web requests
now="$(date +%s)"
public_ip="unknown"

if [ -f "$CACHE_FILE" ]; then
    cache_time="$(awk 'NR==1 {print $1}' "$CACHE_FILE")"
    cache_ip="$(awk 'NR==2 {print $1}' "$CACHE_FILE")"

    if [ -n "$cache_time" ] && [ $((now - cache_time)) -lt "$CACHE_TTL" ]; then
        public_ip="$cache_ip"
    fi
fi

if [ "$public_ip" = "unknown" ]; then
    fetched_ip="$(curl -4 -s --max-time 2 https://api.ipify.org 2>/dev/null)"

    if [ -n "$fetched_ip" ]; then
        public_ip="$fetched_ip"
        printf "%s\n%s\n" "$now" "$public_ip" > "$CACHE_FILE"
    fi
fi

tooltip="VPN: ${vpn_state}
Public IP: ${public_ip}

${status}

Left click: connect/disconnect
Right click: status"

tooltip="$(printf '%s' "$tooltip" | python -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')"

printf '{"text":"","tooltip":"%s","class":"%s"}\n' "$tooltip" "$class"