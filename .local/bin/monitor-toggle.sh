#!/bin/bash

# Configurable keywords for sinks
DESK_SINK_KEYWORD="Schiit"
COUCH_SINK_KEYWORD="HDMI"
HYBRID_SINK_KEYWORD="HDMI"

# Configurable monitor names
DESK_MONITOR="DP-1"
TV_MONITOR="HDMI-A-1"

# Monitor config variables (defaults to current settings)
DESK_RES="2560x1440@480"
DESK_SCALE="1.25"
DESK_BITDEPTH_HDR="10"
DESK_BITDEPTH_SDR="8"
DESK_CM="cm"
DESK_HDR="hdr"
DESK_SDRBRIGHTNESS="1.4"
DESK_SDRSATUREATION="1.2"

TV_RES="3840x2160@120"
TV_SCALE="2"
TV_BITDEPTH_HDR="10"
TV_BITDEPTH_SDR="8"
TV_CM="cm"
TV_HDR="hdr"
TV_SDRBRIGHTNESS="1.4"
TV_SDRSATUREATION="1.2"

CURRENT_SINK=$(pactl get-default-sink)

mode=${1:-desk-mode}
COLORSPACE=${2:-sdr}

if [[ "$COLORSPACE" != "hdr" && "$COLORSPACE" != "sdr" ]]; then
    echo "Error: Invalid colorspace '$COLORSPACE'. Use 'hdr' or 'sdr'."
    exit 1
fi

# Build monitor configs dynamically
if [ "$COLORSPACE" = "sdr" ]; then
    DESK_CONFIG="$DESK_RES, auto, $DESK_SCALE, bitdepth, $DESK_BITDEPTH_SDR"
    TV_CONFIG="$TV_RES, auto, $TV_SCALE, bitdepth, $TV_BITDEPTH_SDR"
else
    DESK_CONFIG="$DESK_RES, auto, $DESK_SCALE, bitdepth, $DESK_BITDEPTH_HDR, $DESK_CM, $DESK_HDR, sdrbrightness, $DESK_SDRBRIGHTNESS, sdrsaturation, $DESK_SDRSATUREATION"
    TV_CONFIG="$TV_RES, auto, $TV_SCALE, bitdepth, $TV_BITDEPTH_HDR, $TV_CM, $TV_HDR, sdrbrightness, $TV_SDRBRIGHTNESS, sdrsaturation, $TV_SDRSATUREATION"
fi

case $mode in
    desk-mode)
        echo "Switching to desk-mode ($COLORSPACE):"
        echo "  Monitors: Enabling $DESK_MONITOR, then disabling $TV_MONITOR."
        if ! hyprctl keyword monitor $DESK_MONITOR, $DESK_CONFIG; then
            echo "Error: Failed to enable $DESK_MONITOR."
        fi
        sleep 0.5
        if ! hyprctl keyword monitor $TV_MONITOR, disabled; then
            echo "Error: Failed to disable $TV_MONITOR."
        fi
        echo "  Focusing on $DESK_MONITOR."
        if ! hyprctl dispatch focusmonitor $DESK_MONITOR; then
            echo "Error: Failed to focus $DESK_MONITOR."
        fi
        # Set default sink
        SINK=$(pactl list sinks | grep -i "$DESK_SINK_KEYWORD" | head -1 | awk '{print $2}')
        if [ -n "$SINK" ]; then
            echo "  Sink: Switching from '$CURRENT_SINK' to '$SINK'."
            if ! pactl set-default-sink "$SINK"; then
                echo "Error: Failed to set default sink."
            fi
            echo "  Moving active streams to new sink."
            MOVED=0
            for INPUT in $(pactl list sink-inputs short | awk '{print $1}'); do
                if pactl move-sink-input $INPUT "$SINK" 2>/dev/null; then
                    ((MOVED++))
                fi
            done
            echo "  Moved $MOVED active streams."
        else
            echo "Warning: No sink matching '$DESK_SINK_KEYWORD' found. Available sinks: $(pactl list sinks short | awk '{print $2}' | tr '\n' ' ')"
        fi
        # Handle Steam mode
        if pgrep -x steam > /dev/null; then
            if hyprctl clients | grep -q "title: Steam Big Picture Mode"; then
                echo "  Switching Steam to normal mode."
                steam steam://close/bigpicture &
            fi
        fi
        # Set window rules for Steam
        hyprctl keyword windowrulev2 "float,class:(steam)"
        # hyprctl keyword windowrulev2 "size 1100 700,class:(steam)"
        echo "Mode switch to desk-mode complete."
        ;;
    couch-mode)
        echo "Switching to couch-mode ($COLORSPACE):"
        echo "  Monitors: Enabling $TV_MONITOR, then disabling $DESK_MONITOR."
        if ! hyprctl keyword monitor $TV_MONITOR, $TV_CONFIG; then
            echo "Error: Failed to enable $TV_MONITOR."
        fi
        sleep 0.5
        if ! hyprctl keyword monitor $DESK_MONITOR, disabled; then
            echo "Error: Failed to disable $DESK_MONITOR."
        fi
        echo "  Focusing on $TV_MONITOR."
        if ! hyprctl dispatch focusmonitor $TV_MONITOR; then
            echo "Error: Failed to focus $TV_MONITOR."
        fi
        # Set default sink
        SINK=$(pactl list sinks | grep -i "$COUCH_SINK_KEYWORD" | head -1 | awk '{print $2}')
        if [ -n "$SINK" ]; then
            echo "  Sink: Switching from '$CURRENT_SINK' to '$SINK'."
            if ! pactl set-default-sink "$SINK"; then
                echo "Error: Failed to set default sink."
            fi
            echo "  Moving active streams to new sink."
            MOVED=0
            for INPUT in $(pactl list sink-inputs short | awk '{print $1}'); do
                if pactl move-sink-input $INPUT "$SINK" 2>/dev/null; then
                    ((MOVED++))
                fi
            done
            echo "  Moved $MOVED active streams."
        else
            echo "Warning: No sink matching '$COUCH_SINK_KEYWORD' found. Available sinks: $(pactl list sinks short | awk '{print $2}' | tr '\n' ' ')"
        fi
        # Handle Steam mode
        if pgrep -x steam > /dev/null; then
            if ! hyprctl clients | grep -q "title: Steam Big Picture Mode"; then
                echo "  Switching Steam to big-picture mode."
                steam steam://open/bigpicture &
                sleep 1
                echo "  Focusing on Steam."
                hyprctl dispatch focuswindow steam
            fi
        fi
        # Set window rules for Steam
        hyprctl keyword windowrulev2 "fullscreen,class:(steam)"
        echo "Mode switch to couch-mode complete."
        ;;
    hybrid-mode)
        echo "Switching to hybrid-mode ($COLORSPACE):"
        echo "  Monitors: Enabling $DESK_MONITOR and $TV_MONITOR."
        if ! hyprctl keyword monitor $DESK_MONITOR, $DESK_CONFIG; then
            echo "Error: Failed to enable $DESK_MONITOR."
        fi
        if ! hyprctl keyword monitor $TV_MONITOR, $TV_CONFIG; then
            echo "Error: Failed to enable $TV_MONITOR."
        fi
        echo "  Focusing on $DESK_MONITOR."
        if ! hyprctl dispatch focusmonitor $DESK_MONITOR; then
            echo "Error: Failed to focus $DESK_MONITOR."
        fi
        # Set default sink
        SINK=$(pactl list sinks | grep -i "$HYBRID_SINK_KEYWORD" | head -1 | awk '{print $2}')
        if [ -n "$SINK" ]; then
            echo "  Sink: Switching from '$CURRENT_SINK' to '$SINK'."
            if ! pactl set-default-sink "$SINK"; then
                echo "Error: Failed to set default sink."
            fi
            echo "  Moving active streams to new sink."
            MOVED=0
            for INPUT in $(pactl list sink-inputs short | awk '{print $1}'); do
                if pactl move-sink-input $INPUT "$SINK" 2>/dev/null; then
                    ((MOVED++))
                fi
            done
            echo "  Moved $MOVED active streams."
        else
            echo "Warning: No sink matching '$HYBRID_SINK_KEYWORD' found. Available sinks: $(pactl list sinks short | awk '{print $2}' | tr '\n' ' ')"
        fi
        # Set window rules for Steam
        hyprctl keyword windowrulev2 "fullscreen,class:(steam)"
        echo "Mode switch to hybrid-mode complete."
        ;;
    *)
        echo "Usage: $0 [desk-mode|couch-mode|hybrid-mode] [sdr|hdr]"
        exit 1
        ;;
esac
