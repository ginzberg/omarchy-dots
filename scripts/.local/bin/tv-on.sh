#!/bin/bash 

HARMONY_DIR="$HOME/.repos/harmonyHubCLI/"
HUB_IP="192.168.1.75"

echo "Starting 'Watch PC' Activity"
node "$HARMONY_DIR/harmonyHubCli.js" --hub "$HUB_IP" -a 'Watch PC'
