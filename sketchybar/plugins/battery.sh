#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"
VOLUME=$(osascript -e 'output volume of (get volume settings)')
BATTERY_INFO=$(pmset -g batt)

output=""
width=105

# Проверяем наличие времени
if echo "$BATTERY_INFO" | grep -q "remaining"; then
  raw_time=$(echo "$BATTERY_INFO" | grep -Eo "\d+:\d+ remaining" | grep -Eo "\d+:\d+")
  if [ -n "$raw_time" ]; then
    IFS=':' read -r hours minutes <<< "$raw_time"
    output="${hours}h ${minutes}min"
    width=105
  fi
elif echo "$BATTERY_INFO" | grep -q "no estimate"; then
  output="Estimating..."
  width=145
fi

# Проверка на случай, если PERCENTAGE пуст
if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

# Выбор иконки по проценту
case "${PERCENTAGE}" in
  9[0-9]|100) ICON="" ;;
  [6-8][0-9]) ICON="" ;;
  [3-5][0-9]) ICON="" ;;
  [1-2][0-9]) ICON="" ;;
  *) ICON="" ;;
esac

# Если на зарядке — другая иконка и другая ширина
if [[ -n "$CHARGING" ]]; then
  ICON=""
  width=90
  output="$PERCENTAGE%"
else
  output="$output"
fi

# Отправляем в sketchybar
sketchybar --set "$NAME" icon="$ICON" label="$output" width=$width
