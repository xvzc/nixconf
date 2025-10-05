#!/usr/bin/env python3

import os
import sys
import socket
import subprocess
import json
from contextlib import contextmanager


ROFI_CMD = "rofi -show drun -calc-command \"echo -n '{result}' | wl-copy\""
HYPRLAND_CLIENTS_CMD = ["hyprctl", "clients", "-j"]


def sock_path():
    xdg = os.environ.get("XDG_RUNTIME_DIR")
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not xdg or not sig:
        print("Could not find socket path", file=sys.stderr)
        sys.exit(1)
    return os.path.join(xdg, "hypr", sig, ".socket2.sock")


def has_rofi():
    try:
        subprocess.check_output(["pidof", "rofi"])
        return True
    except Exception:
        pass

    return False


def kill_rofi():
    subprocess.run(
        ["pkill", "rofi"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def current_clients():
    return {
        x["address"][2:]: x
        for x in json.loads(subprocess.check_output(HYPRLAND_CLIENTS_CMD))
    }


def find_rofi(clients):
    for k in clients.keys():
        if clients[k]["class"] == "Rofi":
            return k

    return None


@contextmanager
def socket_context(*args, **kw):
    s = socket.socket(*args, **kw)
    try:
        yield s
    finally:
        s.close()


if has_rofi():
    kill_rofi()
    exit(0)

spath = sock_path()
with socket_context(socket.AF_UNIX, socket.SOCK_STREAM) as s:
    s.connect(spath)
    try:
        with s.makefile("r", encoding="utf-8", newline="\n", buffering=1) as f:
            kill_rofi()
            rofi = subprocess.Popen(ROFI_CMD, shell=True)

            while True:
                line = f.readline().strip()
                if "Rofi" in line or "rofi" in line:
                    break

            clients = current_clients()
            rofi_id = find_rofi(clients)

            while True:
                line = f.readline().strip()
                tokens = line.split(">>")
                event, message = tokens[0], tokens[1]

                if not line:
                    raise IOError()

                if rofi.poll():
                    break

                if event == "openwindow":
                    clients = current_clients()
                    rofi_id = find_rofi(clients)

                if event == "activewindowv2" and message != rofi_id:
                    break

                if event == "workspace":
                    break

    except Exception:
        pass
    finally:
        try:
            s.shutdown(socket.SHUT_RDWR)
        except OSError:
            pass

if rofi.poll() is None:
    rofi.kill()
