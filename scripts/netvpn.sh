#!/usr/bin/env bash

CACHE_FILE="/tmp/waybar-public-ip-cache"
CACHE_TTL=60

vpn_status="$(protonvpn status 2>/dev/null)"

# VPN status
if echo "$vpn_status" | grep -qiE 'Status:[[:space:]]*Connected|Connection Status:[[:space:]]*Connected|Connected to'; then
    vpn_icon=""
    vpn_state="connected"
else
    vpn_icon=""
    vpn_state="disconnected"
    vpn_status="Proton VPN disconnected"
fi

# Default route interface
iface="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -n1)"

# Local IP
local_ip="$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)"

[ -z "$iface" ] && iface="offline"
[ -z "$local_ip" ] && local_ip="none"

# Public IP with small cache, so Waybar does not spam requests
now="$(date +%s)"
public_ip=""

if [ -f "$CACHE_FILE" ]; then
    cache_time="$(awk 'NR==1 {print $1}' "$CACHE_FILE")"
    cache_ip="$(awk 'NR==2 {print $1}' "$CACHE_FILE")"

    if [ -n "$cache_time" ] && [ $((now - cache_time)) -lt "$CACHE_TTL" ]; then
        public_ip="$cache_ip"
    fi
fi

if [ -z "$public_ip" ]; then
    public_ip="$(curl -4 -s --max-time 2 https://api.ipify.org 2>/dev/null)"
    if [ -n "$public_ip" ]; then
        printf "%s\n%s\n" "$now" "$public_ip" > "$CACHE_FILE"
    else
        public_ip="unknown"
    fi
fi

# Network icon: generic, no "wired" text
if [ "$iface" = "offline" ]; then
    net_icon="󰖪"
    class="offline"
elif [[ "$iface" == wl* ]]; then
    net_icon=""
    class="$vpn_state"
else
    net_icon="󰖩"
    class="$vpn_state"
fi

text="${net_icon} ${vpn_icon}"

tooltip="Interface: ${iface}
Local IP: ${local_ip}
Public IP: ${public_ip}

VPN: ${vpn_state}
${vpn_status}

Left click: VPN connect/disconnect
Right click: Proton VPN status"

tooltip="$(printf '%s' "$tooltip" | python -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
