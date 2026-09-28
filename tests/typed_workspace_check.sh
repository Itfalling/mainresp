#!/usr/bin/env bash
# Roblox API member check.
#
# luau-lsp in nonstrict mode does not flag writes to unknown properties, and
# the Rojo sourcemap types `workspace` from the project tree (hiding the real
# Workspace/Terrain API). An invalid Terrain property once crashed server boot
# this way. This script copies src/, forces --!strict, shadows `workspace`
# with a properly typed local, and reports ONLY "unknown member of a Roblox
# class" errors — the ones that are real runtime errors in Roblox.
#
# Usage: ROJO=rojo LUAU_LSP=luau-lsp DEFS=globalTypes.d.luau tests/typed_workspace_check.sh
set -euo pipefail
cd "$(dirname "$0")/.."
WORK="$(mktemp -d)"
cp -r src default.project.json "$WORK/"
find "$WORK/src" -name '*.luau' | while read -r file; do
	python3 - "$file" <<'PY'
import sys
path = sys.argv[1]
lines = open(path).read().split("\n")
if lines and lines[0].startswith("--!"):
    lines = lines[1:]
insert_at = 0
for i, line in enumerate(lines):
    if line.strip() == "]]":
        insert_at = i + 1
        break
shadow = []
if any("workspace" in l for l in lines):
    shadow = ['local workspace = (game:GetService("Workspace") :: any) :: Workspace']
lines = ["--!strict"] + lines[:insert_at] + shadow + lines[insert_at:]
open(path, "w").write("\n".join(lines))
PY
done
cd "$WORK"
"${ROJO:-rojo}" sourcemap default.project.json -o sourcemap.json >/dev/null
"${LUAU_LSP:-luau-lsp}" analyze --sourcemap=sourcemap.json --defs="${DEFS:?set DEFS to globalTypes.d.luau}" --platform=roblox src 2>&1 \
	| grep -E "not found in external type|is not a valid member" \
	| grep -vE "external type 'Instance'" \
	| sed "s#$WORK/##" | sort -u || true
