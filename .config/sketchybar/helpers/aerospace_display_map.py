#!/usr/bin/env python3
# Maps aerospace monitor IDs to sketchybar (macOS) display IDs.
# Why: aerospace numbers monitors independently from macOS, so passing
# aerospace's monitor ID as sketchybar's `display=` puts items on the
# wrong physical screen. Output: one line per aerospace monitor in
# `<aerospace-id>|<sketchybar-display-id>` format.
import json
import re
import subprocess


def main():
    aero = json.loads(subprocess.check_output(
        ["aerospace", "list-monitors", "--json"]))
    sysp = json.loads(subprocess.check_output(
        ["system_profiler", "SPDisplaysDataType", "-json"]))

    displays = []
    for gpu in sysp.get("SPDisplaysDataType", []):
        for d in gpu.get("spdisplays_ndrvs", []) or []:
            displays.append({
                "name": d.get("_name", ""),
                "main": d.get("spdisplays_main") == "spdisplays_yes",
                "builtin": d.get("spdisplays_connection_type")
                == "spdisplays_internal",
            })

    # macOS display IDs: main is 1, others follow.
    ordered = sorted(displays, key=lambda d: (0 if d["main"] else 1))
    sb_id = {id(d): i + 1 for i, d in enumerate(ordered)}

    def is_builtin(name):
        return bool(re.search(r"built[- ]?in|color lcd|retina", name, re.I))

    for am in aero:
        aid = am["monitor-id"]
        aname = am["monitor-name"]
        target = None
        for d in ordered:
            if is_builtin(aname) and d["builtin"]:
                target = d
                break
            if (not is_builtin(aname) and not d["builtin"]
                    and aname.lower() in d["name"].lower()):
                target = d
                break
        if target is None:
            for d in ordered:
                if ((is_builtin(aname) and d["builtin"])
                        or (not is_builtin(aname) and not d["builtin"])):
                    target = d
                    break
        print(f"{aid}|{sb_id[id(target)] if target else aid}")


if __name__ == "__main__":
    main()
