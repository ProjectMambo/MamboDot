#!/bin/bash

# Query GPU: name, load, temp (comma-only separator, no space-splitting)
IFS=',' read -r NAME LOAD TEMP <<< "$(nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu --format=csv,noheader,nounits)"

NAME=$(echo "$NAME" | sed 's/^ *//;s/ *$//')
LOAD=$(echo "$LOAD" | sed 's/^ *//;s/ *$//')
TEMP=$(echo "$TEMP" | sed 's/^ *//;s/ *$//')

# Process list
PROC_LINES=$(nvidia-smi | grep -E '[0-9]+MiB \|$')

APP_LIST=""
while read -r line; do
    [ -z "$line" ] && continue
    pid=$(echo "$line" | awk '{print $5}')
    name=$(ps -p "$pid" -o comm= 2>/dev/null)
    [ -z "$name" ] && continue

    if [ "$name" = "java" ]; then
        cmdline=$(tr '\0' ' ' < /proc/"$pid"/cmdline 2>/dev/null)
        if echo "$cmdline" | grep -qi "minecraft"; then
            name="Minecraft"
        fi
    fi

    APP_LIST="${APP_LIST}${name}\n"
done <<< "$PROC_LINES"

# Dedup first, then number
APPS=$(echo -e "$APP_LIST" | awk '!seen[$0]++' | sed '/^$/d' | awk '{print NR". "$0}')
[ -z "$APPS" ] && APPS="None"

TOOLTIP="${NAME}
Load: ${LOAD}% | Temp: ${TEMP}°C
Apps:
${APPS}"

jq -nc --arg text "${LOAD}%" --arg tooltip "$TOOLTIP" \
    '{text: $text, tooltip: $tooltip}'