#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOT_DIR="$PROJECT_DIR/dot"

usage() {
    printf '%s\n' \
        'Usage:' \
        '  mambodot.sh update' \
        '  mambodot.sh link PACKAGE...|all' \
        '  mambodot.sh unlink PACKAGE...|all' \
        '' \
        'Commands:' \
        '  update         Regenerate tracked colour artifacts with mbcolor' \
        '  link PACKAGE   Preview and link selected Stow packages' \
        '  unlink PACKAGE Preview and unlink selected Stow packages'
}

PACKAGES=()

select_packages() {
    if [[ $# -eq 0 ]]; then
        echo '[!] Select at least one package or use all.' >&2
        return 2
    fi
    if [[ "$1" == all ]]; then
        if [[ $# -ne 1 ]]; then
            echo '[!] all cannot be combined with package names.' >&2
            return 2
        fi
        mapfile -t PACKAGES < <(
            find "$DOT_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort
        )
        [[ ${#PACKAGES[@]} -gt 0 ]] || {
            echo '[!] No Stow packages found.' >&2
            return 1
        }
        return
    fi

    local package
    for package in "$@"; do
        if [[ ! "$package" =~ ^[[:alnum:]_][[:alnum:]_.-]*$ ]] ||
            [[ ! -d "$DOT_DIR/$package" ]] || [[ -L "$DOT_DIR/$package" ]]; then
            echo "[!] Unknown Stow package: $package" >&2
            return 2
        fi
        PACKAGES+=("$package")
    done
}

run_stow() {
    local mode="$1"
    shift
    local target="${HOME:-}"
    local action label

    command -v stow >/dev/null 2>&1 || {
        echo '[!] GNU Stow is required.' >&2
        return 1
    }
    if [[ "$target" != /* || "$target" == / || ! -d "$target" ]]; then
        echo "[!] Refusing unsafe or missing Stow target: $target" >&2
        return 1
    fi
    if [[ "$mode" == link ]]; then
        action=--restow
        label='link'
    else
        action=--delete
        label='unlink'
    fi

    local clean_home
    clean_home="$(mktemp -d /tmp/mambodot-stow.XXXXXX)"
    (
        # shellcheck disable=SC2329 # Invoked by the EXIT trap.
        cleanup_stow_home() {
            if [[ -d "$clean_home" && "$clean_home" == /tmp/mambodot-stow.* ]]; then
                rm -rf -- "$clean_home"
            fi
        }
        trap cleanup_stow_home EXIT
        cd "$clean_home"

        printf '[*] Previewing %s: %s\n' "$label" "$*"
        HOME="$clean_home" stow --simulate --verbose --no-folding \
            --dir "$DOT_DIR" --target "$target" "$action" "$@"

        printf '[*] Applying %s: %s\n' "$label" "$*"
        HOME="$clean_home" stow --verbose --no-folding \
            --dir "$DOT_DIR" --target "$target" "$action" "$@"
    )
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
    link|unlink)
        command="$1"
        shift
        select_packages "$@"
        run_stow "$command" "${PACKAGES[@]}"
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
