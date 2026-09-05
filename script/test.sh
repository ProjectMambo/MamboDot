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

"$SCRIPT_DIR/mambodot.sh" --help | grep -q 'mambodot.sh update'
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

grep -Fq '"$SCRIPT_DIR/mambodot.sh" update' "$SCRIPT_DIR/install.sh"
if grep -Eq 'mbfont|fc-cache|fc-list' "$SCRIPT_DIR/install.sh"; then
    echo 'MamboFont installation must remain outside MamboDot' >&2
    exit 1
fi

echo 'MamboDot provider checks passed'
