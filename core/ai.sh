#!/bin/bash

# ==========================================
# 🧠 AI ANALYSIS MODULE (ENHANCED)
# ==========================================

run_ai_analysis() {
    local json="$1"
    local output="$2"

    if [ ! -f "$json" ]; then
        echo "[ERROR] No data for AI analysis"
        return
    fi

    echo -e "${BLUE}[*] Running AI Analysis...${RESET}"

    CRITICAL=$(grep -c '"severity":"critical"' "$json")
    HIGH=$(grep -c '"severity":"high"' "$json")
    MEDIUM=$(grep -c '"severity":"medium"' "$json")

    {
        echo "====== AI SECURITY INSIGHTS ======"
        echo "Critical: $CRITICAL"
        echo "High: $HIGH"

        if [ "$CRITICAL" -gt 0 ]; then
            echo "⚠️ Immediate patch required"
        fi

        if grep -qi "idor" "$json"; then
            echo "💡 Possible IDOR → check access control"
        fi

        if grep -qi "xss" "$json"; then
            echo "💡 XSS → test payload variations"
        fi

    } > "$output"
}
