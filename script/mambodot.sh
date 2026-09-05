#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
    printf '%s\n' \
        'Usage:' \
        '  mambodot.sh update' \
        '' \
        'Commands:' \
        '  update  Regenerate tracked colour artifacts with mbcolor'
}

update_colours() {
    if ! command -v mbcolor >/dev/null 2>&1; then
        echo '[!] mbcolor is required. Install MamboColour first.' >&2
        exit 1
    fi

    local hypr_dir="$PROJECT_DIR/dot/hypr/.config/hypr/themes"
    local waybar_dir="$PROJECT_DIR/dot/waybar/.config/waybar"
    local temporary
    temporary="$(mktemp -d /tmp/mambodot-update.XXXXXX)"
    local theme format
    local themes=(
        mamboorchelight
        mamboorchedark
        mambooutbacklight
        mambooutbackdark
    )

    for destination in "$hypr_dir" "$waybar_dir"; do
        if [[ ! -d "$destination" || -L "$destination" ]]; then
            echo "[!] Refusing missing or symlinked generated directory: $destination" >&2
            exit 1
        fi
        case "$(readlink -f "$destination")" in
            "$PROJECT_DIR"/*) ;;
            *)
                echo "[!] Refusing generated directory outside the project: $destination" >&2
                exit 1
                ;;
        esac
    done

    cleanup() {
        if [[ -d "$temporary" && "$temporary" == /tmp/mambodot-update.* ]]; then
            rm -rf -- "$temporary"
        fi
    }
    trap cleanup EXIT

    mkdir -p "$temporary/hypr" "$temporary/waybar"
    for format in hyprlua hyprlang; do
        for theme in "${themes[@]}"; do
            mbcolor "$theme" "$format" --out "$temporary/hypr"
        done
    done
    for theme in "${themes[@]}"; do
        mbcolor "$theme" waybar --out "$temporary/waybar"
    done

    for theme in "${themes[@]}"; do
        for extension in lua conf; do
            [[ -s "$temporary/hypr/$theme.$extension" ]] || {
                echo "[!] mbcolor did not generate $theme.$extension" >&2
                exit 1
            }
        done
        [[ -s "$temporary/waybar/$theme.css" ]] || {
            echo "[!] mbcolor did not generate $theme.css" >&2
            exit 1
        }
    done

    for theme in "${themes[@]}"; do
        for extension in lua conf; do
            [[ ! -L "$hypr_dir/$theme.$extension" ]] || {
                echo "[!] Refusing symlinked generated target: $hypr_dir/$theme.$extension" >&2
                exit 1
            }
        done
        [[ ! -L "$waybar_dir/$theme.css" ]] || {
            echo "[!] Refusing symlinked generated target: $waybar_dir/$theme.css" >&2
            exit 1
        }
    done

    for theme in "${themes[@]}"; do
        cp -- "$temporary/hypr/$theme.lua" "$hypr_dir/$theme.lua"
        cp -- "$temporary/hypr/$theme.conf" "$hypr_dir/$theme.conf"
        cp -- "$temporary/waybar/$theme.css" "$waybar_dir/$theme.css"
    done

    cleanup
    trap - EXIT
}

case "${1:-}" in
    update)
        shift
        if [[ $# -ne 0 ]]; then
            echo '[!] update does not accept arguments.' >&2
            usage >&2
            exit 2
        fi
        update_colours
        ;;
    -h|--help)
        usage
        ;;
    '')
        usage >&2
        exit 2
        ;;
    *)
        echo "[!] Unknown command: $1" >&2
        usage >&2
        exit 2
        ;;
esac
