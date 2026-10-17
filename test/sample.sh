#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/test.log"

log() {
    local level="$1"; shift
    printf '[%s] [%s] %s\n' "$(date -u +%FT%TZ)" "$level" "$*" | tee -a "$LOG_FILE"
}

die() {
    log ERROR "$*"
    exit 1
}

require_cmd() {
    command -v "$1" &>/dev/null || die "Required command not found: $1"
}

require_cmd nix
require_cmd git

check_builds() {
    local presets=("basic" "config" "coding" "markdown" "full")
    local failed=()

    for preset in "${presets[@]}"; do
        log INFO "Building preset: $preset"
        if nix build ".#$preset" --no-link 2>>"$LOG_FILE"; then
            log INFO "  OK: $preset"
        else
            log ERROR "  FAILED: $preset"
            failed+=("$preset")
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        die "Failed presets: ${failed[*]}"
    fi

    log INFO "All presets built successfully"
}

case "${1:-help}" in
    build)  check_builds ;;
    clean)  rm -f "$LOG_FILE"; log INFO "Cleaned log" ;;
    *)
        echo "Usage: $0 {build|clean}"
        exit 1
        ;;
esac
