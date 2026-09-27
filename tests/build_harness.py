#!/usr/bin/env python3
"""
Bundles the project's pure-logic Luau modules into ONE script that runs
under the standalone `luau` CLI with a minimal Roblox mock, then appends
tests/logic_tests.luau.  Usage:

    python3 tests/build_harness.py > /tmp/bundle.luau && luau /tmp/bundle.luau

This does NOT replace testing in Roblox Studio — it only exercises code
paths that don't need the engine (configs, DataSchema repair, math, utils).
"""
import os, sys, json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TREES = {
    "ReplicatedStorage/Shared": "src/ReplicatedStorage/Shared",
    "ServerScriptService/Server": "src/ServerScriptService/Server",
}

def walk(base):
    out = {}
    for dirpath, _, files in os.walk(base):
        for f in files:
            if f.endswith(".luau"):
                full = os.path.join(dirpath, f)
                rel = os.path.relpath(full, base)
                out[rel] = open(full, encoding="utf-8").read()
    return out

modules = []
for mount, rel in TREES.items():
    for path, src in walk(os.path.join(ROOT, rel)).items():
        name = path[:-5]
        for suffix in (".server", ".client"):
            if name.endswith(suffix):
                name = name[: -len(suffix)]
        modules.append((mount + "/" + name, src))

print(open(os.path.join(ROOT, "tests", "mock_roblox.luau"), encoding="utf-8").read())
print("local __SOURCES = {")
def long_string(text):
    level = 1
    while ("]" + "=" * level + "]") in text:
        level += 1
    eq = "=" * level
    # A leading newline after [==[ is skipped by Lua, so add one to preserve the first line.
    return "[" + eq + "[\n" + text + "]" + eq + "]"

for path, src in modules:
    print(f"  [{json.dumps(path)}] = {long_string(src)},")
print("}")
print("__mountSources(__SOURCES)")
print(open(os.path.join(ROOT, "tests", "logic_tests.luau"), encoding="utf-8").read())
