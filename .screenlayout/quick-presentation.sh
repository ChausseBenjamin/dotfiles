#!/bin/sh

mainmon="eDP"

# List monitors with xrandr
# Keep all linues that contain " connected"
# Remove the main monitor from the list
# Remove all disconnected monitors
# Delete empty lines
# Get the first non-main monitor
# Sanitize the output (keep only the monitor name)
othermon="$(xrandr | grep " connected" |
	sed "s/.*$mainmon\s.*//g;
       /^$/d;
       s/\([A-Z0-9]\+\) .*/\1/g" |
	head -n 1)"

xrandr --output "$mainmon" --auto --output "$othermon" --auto --above "$mainmon"

makewall
