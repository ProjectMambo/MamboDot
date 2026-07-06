#!/bin/bash

if [ "$1" = "--toggle" ]; then
    if pgrep -x hypridle > /dev/null; then
        pkill hypridle
    else
        setsid hypridle > /dev/null 2>&1 &
    fi
    sleep 0.3   # brief pause so pgrep below reflects the new state reliably
fi

if pgrep -x hypridle > /dev/null; then
    STATUS="disabled"   # hypridle running = normal idle behavior = inhibitor OFF
    CLASS="disabled"
else
    STATUS="enabled"    # hypridle not running = inhibitor ON, staying awake
    CLASS="enabled"
fi

UPTIME=$(uptime -p | sed 's/^up //')
ICON="󰅶"

TOOLTIP="Uptime: ${UPTIME}
Idle Inhibitor: ${STATUS}"

jq -nc --arg text "$ICON" --arg tooltip "$TOOLTIP" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'