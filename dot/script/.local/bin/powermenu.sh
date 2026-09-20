#!/usr/bin/env bash
set -euo pipefail

readonly WINDOWS_ENTRY="Windows Boot Manager (on /dev/nvme1n1p1)"

usage() {
    printf 'Usage: %s [shutdown|hibernate|reboot|windows|suspend|logout|lock]\n' "${0##*/}"
}

run_action() {
    case "$1" in
        shutdown) systemctl poweroff ;;
        hibernate) systemctl hibernate ;;
        reboot) systemctl reboot ;;
        windows)
            pkexec /usr/bin/grub-reboot "$WINDOWS_ENTRY"
            if ! systemctl reboot; then
                pkexec /usr/bin/grub-editenv /boot/grub/grubenv unset next_entry
                return 1
            fi
            ;;
        suspend) systemctl suspend ;;
        logout) hyprshutdown ;;
        lock) /usr/bin/hyprlock ;;
        *)
            printf 'Unknown power action: %s\n' "$1" >&2
            return 2
            ;;
    esac
}

if (($# > 1)); then
    usage >&2
    exit 2
fi

if (($# == 1)); then
    if [[ $1 == --help || $1 == -h ]]; then
        usage
        exit 0
    fi
    run_action "$1"
    exit
fi

chosen=$(printf '%s\n' \
    ' Shutdown' \
    ' Hibernate' \
    ' Reboot' \
    ' Reboot to Windows' \
    ' Suspend' \
    ' Logout' \
    ' Lock' | rofi -dmenu -i -p 'Power Menu') || exit 0

case "$chosen" in
    ' Shutdown') run_action shutdown ;;
    ' Hibernate') run_action hibernate ;;
    ' Reboot') run_action reboot ;;
    ' Reboot to Windows') run_action windows ;;
    ' Suspend') run_action suspend ;;
    ' Logout') run_action logout ;;
    ' Lock') run_action lock ;;
    '') ;;
    *) printf 'Unknown power selection: %s\n' "$chosen" >&2; exit 2 ;;
esac
