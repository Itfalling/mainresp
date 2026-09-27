#!/usr/bin/env bash
# Runs engine-free logic tests with the standalone Luau CLI.
# Requires `luau` on PATH (https://github.com/luau-lang/luau/releases).
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="$(mktemp -t biy_bundle_XXXX.luau)"
python3 tests/build_harness.py > "$OUT"
"${LUAU:-luau}" "$OUT"
