#!/bin/bash

PROCESS="test"
LOG="/var/log/monitoring.log"
TARGET_URL="https://test.com/monitoring/test/api"
LAST_PID_FILE="/tmp/$PROCESS.pid"

to_log() {
    echo "$(date "+%d-%m-%Y %H:%M:%S") $1" >> "$LOG"
}

while true; do
    try_pid=$(pgrep -x "$PROCESS")
    if [ -n "$try_pid" ]; then
        if curl -s --head --request GET "$TARGET_URL" | grep -q "200 OK"; then
            curl -s -X GET "$TARGET_URL" > /dev/null
        else
            to_log "[ERROR] Monitoring server is unreachable."
        fi

        if [ -f "$LAST_PID_FILE" ]; then
            last_pid=$(cat "$LAST_PID_FILE")
            if [ "$try_pid" != "$last_pid" ]; then
                to_log "[INFO] Process $PROCESS was restarted."
                echo "$try_pid" > "$LAST_PID_FILE"
            fi
        else
            echo "$try_pid" > "$LAST_PID_FILE"
        fi
    fi

    sleep 60
done
