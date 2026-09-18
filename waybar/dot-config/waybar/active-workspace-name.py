#!/usr/bin/env python3

import json
import os
import socket
import subprocess
import sys


REFRESH_EVENTS = {
    "workspacev2",
    "focusedmonv2",
    "renameworkspace",
    "changeworkspaceid",
    "monitoraddedv2",
    "monitorremovedv2",
    "configreloaded",
}


def active_workspace_name() -> str:
    result = subprocess.run(
        ["hyprctl", "-j", "activeworkspace"],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    return str(json.loads(result.stdout)["name"])


def emit(last_name: str | None) -> str | None:
    try:
        name = active_workspace_name()
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError, KeyError):
        return last_name

    if name != last_name:
        print(name, flush=True)
    return name


def main() -> int:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    instance = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not runtime_dir or not instance:
        print("Hyprland runtime environment is unavailable", file=sys.stderr)
        return 1

    last_name = emit(None)
    socket_path = os.path.join(runtime_dir, "hypr", instance, ".socket2.sock")

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as event_socket:
        event_socket.connect(socket_path)
        with event_socket.makefile("r", encoding="utf-8", errors="replace") as events:
            for line in events:
                event_name = line.partition(">>")[0]
                if event_name in REFRESH_EVENTS:
                    last_name = emit(last_name)

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
