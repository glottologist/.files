#!/usr/bin/env bash
EWW="eww -c $HOME/.config/eww/"

if [[ ! $(pidof eww) ]]; then
    ${EWW} daemon
    sleep 1
fi

NB_MONITORS=($(hyprctl monitors -j | jq -r '.[] | .id'))
for i in "${!NB_MONITORS[@]}"; do
    ${EWW} open "bar$i"
    [[ $i == 0 ]] && ${EWW} open-many sidebar notifications
done
