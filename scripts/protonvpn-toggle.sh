#!/usr/bin/env bash

status="$(protonvpn status 2>/dev/null)"

# Max acceptable ping after VPN connects
MAX_PING=90

# Countries to try, Turkey excluded
countries=(BG GR RO DE NL FR CH PL)

is_connected() {
    echo "$status" | grep -qiE 'Status:[[:space:]]*Connected|Connection Status:[[:space:]]*Connected|Connected to'
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Proton VPN" "$1"
    fi
}

get_ping_ms() {
    ping -c 3 -W 2 1.1.1.1 2>/dev/null | awk -F'/' '/rtt|round-trip/ {print int($5)}'
}

shuffle_countries() {
    printf "%s\n" "${countries[@]}" | shuf
}

if is_connected; then
    notify "Disconnecting..."
    protonvpn disconnect >/dev/null 2>&1
    notify "Disconnected"
    exit 0
fi

notify "Connecting randomly, Turkey excluded..."

for country in $(shuffle_countries); do
    notify "Trying $country..."

    protonvpn disconnect >/dev/null 2>&1
    sleep 1

    if protonvpn connect --country "$country" >/dev/null 2>&1; then
        sleep 4

        ping_ms="$(get_ping_ms)"

        if [ -z "$ping_ms" ]; then
            ping_ms=9999
        fi

        echo "$country ping: ${ping_ms}ms"

        if [ "$ping_ms" -le "$MAX_PING" ]; then
            notify "Connected to $country — ${ping_ms}ms"
            exit 0
        fi

        notify "$country too slow: ${ping_ms}ms. Trying another..."
    else
        notify "$country failed. Trying another..."
    fi
done

protonvpn disconnect >/dev/null 2>&1
notify "Could not find a fast VPN country."
exit 1