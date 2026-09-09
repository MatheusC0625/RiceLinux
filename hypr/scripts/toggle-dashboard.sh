#!/usr/bin/env bash
if pgrep -f "quickshell -c dashboard" > /dev/null; then
    pkill -f "quickshell -c dashboard"
else
    nohup quickshell -c dashboard > /tmp/dashboard.log 2>&1 &
    disown
fi
