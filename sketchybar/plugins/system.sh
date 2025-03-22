#!/bin/bash

# Battery
BATTERY=$(pmset -g batt | grep -o '[0-9]\+%')

# Volume
VOLUME=$(osascript -e 'output volume of (get volume settings)')

# CPU
CPU=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')

# RAM usage
RAW=$(top -l 1 | grep PhysMem)
USED=$(echo "$RAW" | awk '{print $2}' | sed 's/M//')
FREE=$(echo "$RAW" | awk '{print $6}' | sed 's/M//')
TOTAL=$(echo "$USED + $FREE" | bc)
RAM_PERC=$(echo "scale=0; 100 * $USED / $TOTAL" | bc)

# SSD usage
SSD=$(df -H /System/Volumes/Data | awk 'NR==2 {print $5}')

# Вывод
sketchybar --set system_island label="CPU: ${CPU}%   RAM: ${RAM_PERC}%   SSD: ${SSD}     ${BATTERY}     ${VOLUME}%  "
