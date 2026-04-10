#!/usr/bin/env bash
# Event socket wakes us up instantly on focus change.
# Command socket confirms the new active window class.

EVT_SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
CMD_SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket.sock"

python3 - "$EVT_SOCKET" "$CMD_SOCKET" <<'EOF'
import sys, socket, os, select, subprocess, time, json

evt_path = sys.argv[1]
cmd_path = sys.argv[2]

# Connect to event socket BEFORE launching rofi — no missed events
es = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    es.connect(evt_path)
except Exception:
    subprocess.Popen(["rofi", "-show", "drun", "-normal-window"])
    sys.exit(0)

proc  = subprocess.Popen(["rofi", "-show", "drun", "-normal-window"])
pid   = proc.pid
start = time.monotonic()

def active_class():
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(0.1)
    try:
        s.connect(cmd_path)
        s.sendall(b"j/activewindow")
        data = b""
        while True:
            chunk = s.recv(4096)
            if not chunk:
                break
            data += chunk
        return json.loads(data).get("class", "").lower()
    except Exception:
        return ""
    finally:
        s.close()

buf = ""
while True:
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        sys.exit(0)

    readable, _, _ = select.select([es], [], [], 0.5)
    if not readable:
        continue

    try:
        chunk = es.recv(4096).decode("utf-8", errors="ignore")
    except Exception:
        break
    if not chunk:
        break

    buf += chunk
    while "\n" in buf:
        line, buf = buf.split("\n", 1)
        if "activewindow" not in line:
            continue
        if time.monotonic() - start < 0.3:
            continue
        cls = active_class()
        if cls and cls != "rofi":
            try:
                os.kill(pid, 15)
            except ProcessLookupError:
                pass
            sys.exit(0)
EOF
