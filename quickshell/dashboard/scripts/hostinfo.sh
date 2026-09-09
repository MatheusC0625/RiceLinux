#!/usr/bin/env bash
distro=$(awk -F'"' '/PRETTY_NAME/{print $2}' /etc/os-release)
wm="${XDG_CURRENT_DESKTOP:-Hyprland}"
up=$(LC_ALL=C uptime -p 2>/dev/null | sed 's/^up //')

python3 - "$distro" "$wm" "$up" <<'EOF'
import json, sys
distro, wm, up = sys.argv[1:4]
print(json.dumps({"distro": distro, "wm": wm, "uptime": up}))
EOF
