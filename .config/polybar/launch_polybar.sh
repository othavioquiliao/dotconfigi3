#!/bin/bash

# Terminate already running Polybar instances
killall -q polybar

# Wait until Polybar processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch Polybar on each connected monitor
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    echo "Launching Polybar on monitor: $m"
    MONITOR=$m polybar --reload toph &
  done
else
  polybar --reload toph &
fi
