#!/bin/bash

# Получаем уровень батареи
BATTERY=$(pmset -g batt | grep -o '[0-9]\+%')

# Получаем уровень громкости
VOLUME=$(osascript -e 'output volume of (get volume settings)')

# Обновляем label в SketchyBar
sketchybar --set system_island label="Battery: ${BATTERY} | Vol: ${VOLUME}%"