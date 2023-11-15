#!/usr/bin/env sh

STATUS_LABEL=$(lsappinfo info -only StatusLabel "Slack")
ICON="󰒱"

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"

    if [[ $LABEL == "" ]]; then
        ICON_COLOR="0xffa6e3a1"
    elif [[ $LABEL == "•" ]]; then
        ICON_COLOR="0xfff9e2af"
    elif [[ $LABEL =~ ^[0-9]+$ ]]; then
        ICON_COLOR="0xfff38ba8"
    else
        exit 0
    fi
else
  exit 0
fi

sketchybar --set $NAME icon=$ICON label="${LABEL}" icon.color=${ICON_COLOR}
