#!/usr/bin/env bash
# Boot iPhone Duo (if needed) and run WifyRadarTests with a short summary.
#
# Usage:
#   ./scripts/test.sh
#   ./scripts/test.sh PersistentHistoryMergerTests
#   ./scripts/test.sh PersistentHistoryMergerTests/mergeAppliesDeletes
#   ./scripts/test.sh --without-building ShareParticipantMatchingTests
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCHEME="WifyRadar"
SIM_NAME="${WIFYRADAR_SIM:-iPhone Duo}"
LOG="${WIFYRADAR_TEST_LOG:-/tmp/wifyradar-test.log}"
WITHOUT_BUILDING=0
FILTERS=()

for arg in "$@"; do
  case "$arg" in
    --without-building|-w) WITHOUT_BUILDING=1 ;;
    -*)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
    *) FILTERS+=("-only-testing:WifyRadarTests/${arg}") ;;
  esac
done

udid_for_sim() {
  xcrun simctl list devices available \
    | awk -v name="$SIM_NAME" '
        index($0, name) && $0 !~ /unavailable/ {
          if (match($0, /\([0-9A-Fa-f-]{36}\)/)) {
            print substr($0, RSTART + 1, RLENGTH - 2)
            exit
          }
        }
      '
}

UDID="$(udid_for_sim)"
if [[ -z "$UDID" ]]; then
  echo "No available simulator named '${SIM_NAME}'. Check: xcrun simctl list devices available" >&2
  exit 1
fi

STATE="$(xcrun simctl list devices \
  | awk -v id="$UDID" 'index($0, id) {
      if (match($0, /\((Booted|Shutdown|Booting|Creating)\)/)) {
        print substr($0, RSTART + 1, RLENGTH - 2)
        exit
      }
    }')"

if [[ "$STATE" != "Booted" ]]; then
  echo "Booting ${SIM_NAME} (${UDID})…"
  xcrun simctl boot "$UDID" 2>/dev/null || true
  xcrun simctl bootstatus "$UDID" -b >/dev/null
fi

ACTION=(test)
if [[ "$WITHOUT_BUILDING" -eq 1 ]]; then
  ACTION=(test-without-building)
fi

echo "Testing on ${SIM_NAME} → ${LOG}"
set +e
xcodebuild "${ACTION[@]}" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=${UDID}" \
  "${FILTERS[@]}" \
  2>&1 | tee "$LOG" | rg --line-buffered -i 'error:|Test case|TEST SUCCEEDED|TEST FAILED|Testing failed|Executed [0-9]+ test'
status=${PIPESTATUS[0]}
set -e

if [[ "$status" -eq 0 ]]; then
  echo "OK (exit ${status})"
else
  echo "FAILED (exit ${status}). Full log: ${LOG}" >&2
fi
exit "$status"
