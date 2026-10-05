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
        '  doctor         Report package, service, and managed dotfile drift' \
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

doctor_dotfiles() (
    local target="${HOME:-}"
    local source relative package target_path link_target resolved output clean_home retired
    local status=0
    local -A managed=()

    if [[ "$target" != /* || "$target" == / || ! -d "$target" ]]; then
        echo "[!] Refusing unsafe or missing Stow target: $target" >&2
        return 1
    fi

    while IFS= read -r -d '' source; do
        relative="${source#"$DOT_DIR/"}"
        package="${relative%%/*}"
        relative="${relative#*/}"
        target_path="$target/$relative"
        if [[ -e "$target_path" || -L "$target_path" ]]; then
            resolved="$(readlink -m -- "$target_path")"
            if [[ "$resolved" == "$(readlink -m -- "$source")" ]]; then
                managed["$package"]=1
            fi
        fi
    done < <(find "$DOT_DIR" -mindepth 2 \( -type f -o -type l \) -print0)

    # Keep migration checks bounded to the retired MamboColour files we own.
    for retired in \
        'hypr:.config/hypr/themes/mamboorchedark.conf' \
        'hypr:.config/hypr/themes/mamboorchedark.lua' \
        'hypr:.config/hypr/themes/mamboorchelight.conf' \
        'hypr:.config/hypr/themes/mamboorchelight.lua' \
        'hypr:.config/hypr/themes/mambooutbackdark.conf' \
        'hypr:.config/hypr/themes/mambooutbacklight.conf' \
        'hypr:.config/hypr/themes/mambooutbackdark.lua' \
        'hypr:.config/hypr/themes/mambooutbacklight.lua' \
        'waybar:.config/waybar/mamboorchedark.css' \
        'waybar:.config/waybar/mamboorchelight.css' \
        'waybar:.config/waybar/mambooutbackdark.css' \
        'waybar:.config/waybar/mambooutbacklight.css'; do
        package="${retired%%:*}"
        relative="${retired#*:}"
        target_path="$target/$relative"
        [[ -L "$target_path" ]] || continue
        link_target="$(readlink -- "$target_path")"
        if [[ "$link_target" != /* ]]; then
            link_target="$(dirname "$target_path")/$link_target"
        fi
        resolved="$(readlink -m -- "$link_target")"
        if [[ "$resolved" == "$(readlink -m -- "$DOT_DIR/$package/$relative")" ]]; then
            echo "[!] Retired Stow link: $target_path" >&2
            managed["$package"]=1
            status=1
        fi
    done

    if [[ ${#managed[@]} -eq 0 ]]; then
        return "$status"
    fi

    clean_home="$(mktemp -d /tmp/mambodot-doctor.XXXXXX)"
    # shellcheck disable=SC2329 # Invoked by the EXIT trap.
    cleanup_doctor_home() {
        if [[ -d "$clean_home" && "$clean_home" == /tmp/mambodot-doctor.* ]]; then
            rm -rf -- "$clean_home"
        fi
    }
    trap cleanup_doctor_home EXIT

    while IFS= read -r package; do
        [[ -d "$DOT_DIR/$package" ]] || continue
        if output="$(
            cd "$clean_home"
            HOME="$clean_home" stow --simulate --verbose --no-folding \
                --dir "$DOT_DIR" --target "$target" --stow "$package" 2>&1
        )"; then
            if ! grep -Eq '^(LINK|UNLINK|MKDIR|RMDIR|MV):' <<< "$output"; then
                continue
            fi
        fi
        echo "[!] Stow package drift: $package (run: mambodot.sh link $package)" >&2
        status=1
    done < <(printf '%s\n' "${!managed[@]}" | LC_ALL=C sort)

    return "$status"
)

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

    for item in pacman flatpak stow systemctl; do
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

    if ! doctor_dotfiles; then
        status=1
    fi

    if [[ $status -eq 0 ]]; then
        echo '[*] Machine matches the manifests and managed dotfiles.'
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
