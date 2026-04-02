#!/bin/bash

run_ai_analysis() {
    local json="$1"
    local output="$2"

    if [ ! -f "$json" ]; then
        echo "[ERROR] No JSON found"
        return
    fi

    CRITICAL=$(grep -c '"severity":"critical"' "$json")

    {
        echo "AI Analysis"
        echo "Critical: $CRITICAL"

        if [ "$CRITICAL" -gt 0 ]; then
            echo "⚠️ Immediate action required"
        fi

    } > "$output"
}
