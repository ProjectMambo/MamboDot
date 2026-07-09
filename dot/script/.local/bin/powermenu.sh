#!/usr/bin/env bash

order=(" Shutdown" " Hibernate" " Reboot" " Reboot to Windows" " Suspend" " Logout" " Lock")
declare -A actions=(
    [" Shutdown"]="systemctl poweroff"
    [" Hibernate"]="systemctl hibernate"
    [" Reboot"]="systemctl reboot"
    [" Reboot to Windows"]="sudo grub-reboot 'Windows Boot Manager (on /dev/nvme1n1p1)' && systemctl reboot"
    [" Suspend"]="systemctl suspend"
    [" Logout"]="hyprshutdown"
    [" Lock"]="/usr/bin/hyprlock"
)

choices=$(printf "%b\n" "${order[@]}") 
chosen=$(echo -e "$choices" | rofi -dmenu -i -p "Power Menu")

if [[ -n "${actions[$chosen]}" ]]; then
    eval "${actions[$chosen]}"
fi