#!/bin/bash

# ==========================================
# 🌐 DNS INTELLIGENCE MODULE (SubPipe)
# ==========================================

run_dnsintel() {
    local input="$1"
    local output="$2"

    echo -e "${BLUE}[*] Running DNS Intelligence (SubPipe)...${RESET}"

    if ! command -v subpipe &>/dev/null; then
        echo "[WARN] subpipe not installed → skipping"
        return
    fi

    if [ -z "$SUBPIPE_API_KEY" ]; then
        echo "[WARN] SUBPIPE_API_KEY not set → skipping"
        return
    fi

    cat "$input" | subpipe > "$output" 2>/dev/null

    if [ -s "$output" ]; then
        echo "[OK] DNS vulnerabilities detected"
    else
        echo "[INFO] No DNS issues found"
    fi
}
