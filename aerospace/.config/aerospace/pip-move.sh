#!/bin/bash

current_workspace=$(aerospace list-workspaces --focused)

# Make PiP window follow workspace change
aerospace list-windows --all | grep -E "(Picture-in-Picture|Picture in Picture|Bild-i-bild)" | awk '{print $1}' | while read window_id; do
    if [ -n "$window_id" ]; then
        aerospace move-node-to-workspace --window-id "$window_id" "$current_workspace"
    fi
done
