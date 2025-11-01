#!/bin/bash

# Steam game launcher wrapper for dynamic monitor-based settings
# Usage in Steam launch options: /home/rallen/steam-game-launcher.sh %command%

# Detect current mode
if hyprctl monitors | grep -q "HDMI-A-1"; then
    # Couch mode (TV active)
    export WIDTH=3840
    export HEIGHT=2160
    echo "Launching in couch mode: ${WIDTH}x${HEIGHT}"
else
    # Desk mode (only DP-1)
    export WIDTH=2560
    export HEIGHT=1440
    echo "Launching in desk mode: ${WIDTH}x${HEIGHT}"
fi

# Run gamescope with dynamic resolution (adjust flags as needed for HDR, etc.)
echo "Running: gamescope -w $WIDTH -h $HEIGHT -f $@"
gamescope -w $WIDTH -h $HEIGHT -f --hdr-enable "$@"

# After game exits, ensure Steam is fullscreen in couch mode
if hyprctl monitors | grep -q "HDMI-A-1"; then
    STEAM_ADDR=$(hyprctl clients | grep "class: steam" | head -1 | awk '{print $1}')
    if [ -n "$STEAM_ADDR" ]; then
        hyprctl dispatch fullscreen "$STEAM_ADDR"
    fi
fi
