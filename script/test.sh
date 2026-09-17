#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_ROOT="$(mktemp -d /tmp/mambodot-test.XXXXXX)"

cleanup() {
    if [[ -d "$TEST_ROOT" && "$TEST_ROOT" == /tmp/mambodot-test.* ]]; then
        rm -rf -- "$TEST_ROOT"
    fi
}
trap cleanup EXIT

mkdir -p "$TEST_ROOT/bin"
# shellcheck disable=SC2016 # These lines form the generated mbcolor test double.
printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -euo pipefail' \
    'printf "%s|%s|%s|%s\n" "$1" "$2" "$3" "$4" >> "$MAMBODOT_TEST_LOG"' \
    'case "$2" in hyprlua) extension=lua; source_dir="$MAMBODOT_TEST_PROJECT/dot/hypr/.config/hypr/themes" ;; hyprlang) extension=conf; source_dir="$MAMBODOT_TEST_PROJECT/dot/hypr/.config/hypr/themes" ;; waybar) extension=css; source_dir="$MAMBODOT_TEST_PROJECT/dot/waybar/.config/waybar" ;; esac' \
    'mkdir -p "$4"' \
    'if [[ "${MAMBODOT_TEST_GENERATE_NEW:-0}" == 1 ]]; then printf "new\n" > "$4/$1.$extension"; else cp -- "$source_dir/$1.$extension" "$4/$1.$extension"; fi' \
    > "$TEST_ROOT/bin/mbcolor"
chmod +x "$TEST_ROOT/bin/mbcolor"

export MAMBODOT_TEST_LOG="$TEST_ROOT/calls.log"
export MAMBODOT_TEST_PROJECT="$PROJECT_DIR"
PATH="$TEST_ROOT/bin:$PATH" "$SCRIPT_DIR/mambodot.sh" update >/dev/null

mapfile -t calls < "$MAMBODOT_TEST_LOG"
[[ ${#calls[@]} -eq 12 ]]

themes=(mamboorchelight mamboorchedark mambooutbacklight mambooutbackdark)
call_index=0
for format in hyprlua hyprlang; do
    for theme in "${themes[@]}"; do
        [[ "${calls[$call_index]}" == "$theme|$format|--out|/tmp/mambodot-update."*"/hypr" ]]
        ((call_index += 1))
    done
done
for theme in "${themes[@]}"; do
    [[ "${calls[$call_index]}" == "$theme|waybar|--out|/tmp/mambodot-update."*"/waybar" ]]
    ((call_index += 1))
done

"$SCRIPT_DIR/mambodot.sh" --help | grep -q 'mambodot.sh link PACKAGE'
if "$SCRIPT_DIR/mambodot.sh" >/dev/null 2>&1; then
    echo 'mambodot.sh without a command should fail' >&2
    exit 1
fi
if PATH="$TEST_ROOT/bin:$PATH" "$SCRIPT_DIR/mambodot.sh" update extra >/dev/null 2>&1; then
    echo 'mambodot.sh update should reject arguments' >&2
    exit 1
fi
if PATH="/usr/bin:/bin" "$SCRIPT_DIR/mambodot.sh" update >/dev/null 2>&1; then
    echo 'mambodot.sh update should require mbcolor' >&2
    exit 1
fi

TEST_PROJECT="$TEST_ROOT/project"
mkdir -p \
    "$TEST_PROJECT/script" \
    "$TEST_PROJECT/dot/hypr/.config/hypr/themes" \
    "$TEST_PROJECT/dot/waybar/.config/waybar"
cp -- "$SCRIPT_DIR/mambodot.sh" "$TEST_PROJECT/script/mambodot.sh"
for theme in "${themes[@]}"; do
    printf 'old\n' > "$TEST_PROJECT/dot/hypr/.config/hypr/themes/$theme.lua"
    printf 'old\n' > "$TEST_PROJECT/dot/hypr/.config/hypr/themes/$theme.conf"
    printf 'old\n' > "$TEST_PROJECT/dot/waybar/.config/waybar/$theme.css"
done
late_target="$TEST_PROJECT/dot/waybar/.config/waybar/mambooutbackdark.css"
unrelated="$TEST_ROOT/unrelated.css"
printf 'keep\n' > "$unrelated"
rm -- "$late_target"
ln -s "$unrelated" "$late_target"
if MAMBODOT_TEST_GENERATE_NEW=1 PATH="$TEST_ROOT/bin:$PATH" \
    "$TEST_PROJECT/script/mambodot.sh" update >/dev/null 2>&1; then
    echo 'update should refuse a symlink before publishing any output' >&2
    exit 1
fi
[[ "$(cat "$TEST_PROJECT/dot/hypr/.config/hypr/themes/mamboorchelight.lua")" == old ]]
[[ "$(cat "$unrelated")" == keep ]]

STOW_HOME="$TEST_ROOT/stow-home"
mkdir -p "$STOW_HOME"
if HOME="$STOW_HOME" "$SCRIPT_DIR/mambodot.sh" link >/dev/null 2>&1; then
    echo 'link without packages should fail' >&2
    exit 1
fi
if HOME="$STOW_HOME" "$SCRIPT_DIR/mambodot.sh" unlink >/dev/null 2>&1; then
    echo 'unlink without packages should fail' >&2
    exit 1
fi
if HOME="$STOW_HOME" "$SCRIPT_DIR/mambodot.sh" link ../feh >/dev/null 2>&1; then
    echo 'link should reject traversal-style package names' >&2
    exit 1
fi
if HOME="$STOW_HOME" "$SCRIPT_DIR/mambodot.sh" link missing >/dev/null 2>&1; then
    echo 'link should reject unknown packages' >&2
    exit 1
fi

stow_output="$(HOME="$STOW_HOME" "$SCRIPT_DIR/mambodot.sh" link feh 2>&1)"
[[ "$stow_output" == *'Previewing link'*'Applying link'* ]]
[[ -d "$STOW_HOME/.config/feh" && ! -L "$STOW_HOME/.config/feh" ]]
[[ -L "$STOW_HOME/.config/feh/themes" ]]
[[ ! -e "$STOW_HOME/.config/avizo/config.ini" ]]
printf 'runtime\n' > "$STOW_HOME/.config/feh/runtime-state"
HOME="$STOW_HOME" "$SCRIPT_DIR/mambodot.sh" unlink feh >/dev/null 2>&1
[[ ! -e "$STOW_HOME/.config/feh/themes" ]]
[[ "$(cat "$STOW_HOME/.config/feh/runtime-state")" == runtime ]]

CONFLICT_HOME="$TEST_ROOT/conflict-home"
mkdir -p "$CONFLICT_HOME/.config/feh"
printf '%s\n' '--adopt' > "$CONFLICT_HOME/.stowrc"
printf 'home copy\n' > "$CONFLICT_HOME/.config/feh/themes"
repo_theme="$(cat "$PROJECT_DIR/dot/feh/.config/feh/themes")"
if HOME="$CONFLICT_HOME" "$SCRIPT_DIR/mambodot.sh" link feh >/dev/null 2>&1; then
    echo 'link should stop on a conflicting target' >&2
    exit 1
fi
[[ "$(cat "$CONFLICT_HOME/.config/feh/themes")" == 'home copy' ]]
[[ "$(cat "$PROJECT_DIR/dot/feh/.config/feh/themes")" == "$repo_theme" ]]

ALL_HOME="$TEST_ROOT/all-home"
mkdir -p "$ALL_HOME"
HOME="$ALL_HOME" "$SCRIPT_DIR/mambodot.sh" link all >/dev/null 2>&1
[[ -L "$ALL_HOME/.config/ags/app.tsx" ]]
[[ -L "$ALL_HOME/.config/nvim/init.lua" ]]
[[ -L "$ALL_HOME/.config/waybar/config.jsonc" ]]
HOME="$ALL_HOME" "$SCRIPT_DIR/mambodot.sh" unlink all >/dev/null 2>&1
[[ ! -e "$ALL_HOME/.config/nvim/init.lua" ]]

ags_config="$PROJECT_DIR/dot/ags/.config/ags"
ags bundle "$ags_config/app.tsx" "$TEST_ROOT/mambodot-ags" --root "$ags_config" >/dev/null
[[ -x "$TEST_ROOT/mambodot-ags" ]]

lua "$SCRIPT_DIR/test_hypr.lua" "$PROJECT_DIR"

session_exec="$PROJECT_DIR/dot/hypr/.config/hypr/exec.lua"
session_vars="$PROJECT_DIR/dot/hypr/.config/hypr/variables.lua"
shell_rc="$PROJECT_DIR/dot/zsh/.config/zsh/.zshrc"

[[ "$(grep -Fc 'dbus-update-activation-environment --systemd' "$session_exec")" -eq 1 ]]
grep -Fq 'XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE' "$session_exec"

if grep -Eq 'systemctl --user import-environment|hyprland-session.target' "$session_exec" ||
    grep -Eq 'XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE|KDE_SESSION_VERSION' "$session_vars" ||
    grep -Eq 'GTK_IM_MODULE|QT_IM_MODULE|XMODIFIERS|XDG_CURRENT_DESKTOP' "$shell_rc"; then
    echo 'session environment ownership regressed' >&2
    exit 1
fi

wallpaper_config="$PROJECT_DIR/dot/hypr/.config/hypr/hyprpaper.conf"
[[ "$(grep -Fc 'wallpaper {' "$wallpaper_config")" -eq 1 ]]
grep -Eq '^[[:space:]]*monitor[[:space:]]*=[[:space:]]*$' "$wallpaper_config"
monitor_config="$PROJECT_DIR/dot/hypr/.config/hypr/hyprland.lua"
grep -Fq 'output = ""' "$monitor_config"
grep -Fq 'position = "auto"' "$monitor_config"

grep -Eq '^auth[[:space:]]+include[[:space:]]+login$' \
    "$PROJECT_DIR/system/hosts/fa507xv/etc/pam.d/hyprlock"
grep -Eq '^-auth[[:space:]]+optional[[:space:]]+pam_gnome_keyring\.so$' \
    "$PROJECT_DIR/system/hosts/fa507xv/etc/pam.d/hyprlock"

echo 'MamboDot checks passed'
