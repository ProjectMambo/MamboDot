#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOT_DIR="$PROJECT_DIR/dot"

usage() {
    printf '%s\n' \
        'Usage:' \
        '  mambodot.sh doctor' \
        '  mambodot.sh link PACKAGE...|all' \
        '  mambodot.sh unlink PACKAGE...|all' \
        '' \
        'Commands:' \
        '  doctor         Report missing packages and disabled services' \
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

doctor_machine() {
    local packages="$PROJECT_DIR/manifest/packages.tsv"
    local services="$PROJECT_DIR/manifest/services.tsv"
    local manifest source item installed status=0
    local -a check_command
    local -A installed_arch=() installed_aur=() installed_flatpak=()

    for manifest in "$packages" "$services"; do
        if [[ ! -f "$manifest" ]] ||
            ! awk -F '\t' 'NF != 2 || $1 == "" || $2 == "" { exit 1 }' "$manifest"; then
            echo "[!] Invalid manifest: $manifest" >&2
            return 2
        fi
    done

    for item in pacman flatpak systemctl; do
        if ! command -v "$item" >/dev/null 2>&1; then
            echo "[!] Required command not found: $item" >&2
            return 1
        fi
    done

    while read -r item; do installed_arch["$item"]=1; done < <(pacman -Qqn)
    while read -r item; do installed_aur["$item"]=1; done < <(pacman -Qqm)
    while read -r item; do installed_flatpak["$item"]=1; done \
        < <(flatpak list --app --columns=application)

    while IFS=$'\t' read -r source item; do
        case "$source" in
            arch) installed="${installed_arch[$item]+yes}" ;;
            aur) installed="${installed_aur[$item]+yes}" ;;
            flatpak) installed="${installed_flatpak[$item]+yes}" ;;
            *)
                echo "[!] Unknown package source: $source" >&2
                return 2
                ;;
        esac
        if [[ -z "$installed" ]]; then
            echo "[!] Missing $source package: $item" >&2
            status=1
        fi
    done < "$packages"

    while IFS=$'\t' read -r source item; do
        case "$source" in
            system) check_command=(systemctl is-enabled --quiet "$item") ;;
            user) check_command=(systemctl --user is-enabled --quiet "$item") ;;
            *)
                echo "[!] Unknown service scope: $source" >&2
                return 2
                ;;
        esac
        if ! "${check_command[@]}" >/dev/null 2>&1; then
            echo "[!] Disabled $source service: $item" >&2
            status=1
        fi
    done < "$services"

    if [[ $status -eq 0 ]]; then
        echo '[*] Machine matches the package and service manifests.'
    fi
    return "$status"
}

case "${1:-}" in
    doctor)
        shift
        if [[ $# -ne 0 ]]; then
            echo '[!] doctor does not accept arguments.' >&2
            usage >&2
            exit 2
        fi
        doctor_machine
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
