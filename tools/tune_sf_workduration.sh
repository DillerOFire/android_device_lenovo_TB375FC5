#!/system/bin/sh
# Tune AOSP SurfaceFlinger WorkDuration values without rebooting.
# Usage: tune_sf_workduration.sh <late_sf_ns> <early_sf_ns> <late_app_ns>

set -eu

usage() {
    echo "Usage: $0 <late_sf_ns> <early_sf_ns> <late_app_ns>" >&2
    exit 2
}

[ "$#" -eq 3 ] || usage

for value in "$@"; do
    case "$value" in
        ''|*[!0-9]*) usage ;;
    esac
    [ "$value" -gt 0 ] 2>/dev/null || usage
    [ "$value" -le 1000000000 ] 2>/dev/null || usage
 done

# SurfaceFlinger requires late.sf.duration <= early.sf.duration.
[ "$1" -le "$2" ] || {
    echo "late_sf_ns must not exceed early_sf_ns" >&2
    exit 2
}

setprop debug.sf.late.sf.duration "$1"
setprop debug.sf.early.sf.duration "$2"
setprop debug.sf.late.app.duration "$3"

# Reloads early.sf and earlyGl.sf from early.sf, and early/earlyGl app
# durations from late.app, matching SurfaceFlinger's native reload contract.
dumpsys SurfaceFlinger --reload-vsync-timing
