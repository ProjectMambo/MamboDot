#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(realpath "$SCRIPT_DIR/../../")"
EXTENSIONS_FILE="$PROJECT_DIR/dot/code-oss/.config/Code - OSS/User/extensions.txt"

usage() {
    echo 'Usage: install_extensions.sh'
}

if [[ $# -ne 0 ]]; then
    if [[ $# -eq 1 && ("$1" == -h || "$1" == --help) ]]; then
        usage
        exit 0
    fi
    usage >&2
    exit 2
fi

command -v code-oss >/dev/null 2>&1 || {
    echo '[!] code-oss is required.' >&2
    exit 1
}
[[ -f "$EXTENSIONS_FILE" ]] || {
    echo "[!] Extension list not found: $EXTENSIONS_FILE" >&2
    exit 1
}

declare -A installed=()
installed_output="$(code-oss --list-extensions)"
while IFS= read -r extension; do
    [[ -n "$extension" ]] && installed["${extension,,}"]=1
done <<< "$installed_output"

while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    if [[ ${installed["${extension,,}"]+yes} ]]; then
        echo "[*] Already installed: $extension"
    else
        echo "[*] Installing: $extension"
        code-oss --install-extension "$extension"
    fi
done < "$EXTENSIONS_FILE"

echo '[*] Code OSS extensions match the reviewed list.'
