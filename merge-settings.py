#!/usr/bin/env python3
"""Merge templates/settings.json into a Claude Code settings file, keeping existing keys.

Usage: merge-settings.py <target settings.json>
"""
import json, os, sys

here = os.path.dirname(os.path.abspath(__file__))
target = sys.argv[1]
template = json.load(open(os.path.join(here, "templates", "settings.json")))

current = {}
if os.path.exists(target):
    with open(target) as f:
        current = json.load(f)

for key, value in template.items():
    if key == "permissions":
        perms = current.setdefault("permissions", {})
        allow = perms.setdefault("allow", [])
        for rule in value["allow"]:
            if rule not in allow:
                allow.append(rule)
    elif isinstance(value, dict):
        current.setdefault(key, {}).update(value)
    else:
        current[key] = value

os.makedirs(os.path.dirname(os.path.abspath(target)), exist_ok=True)
with open(target, "w") as f:
    json.dump(current, f, indent=2)
    f.write("\n")
print(f"updated {target}")
