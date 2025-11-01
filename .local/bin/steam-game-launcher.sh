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
gamescope -w $WIDTH -h $HEIGHT "$@"
