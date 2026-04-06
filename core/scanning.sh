#!/bin/bash

# ==========================================
# ⚡ SCANNING MODULE (DAST + CLEAN + PRO)
# ==========================================

# ==========================================
# 🔍 URL VALIDATION & DEDUP
# ==========================================

validate_urls() {
    local input="$1"
    local output="$2"

    echo -e "${BLUE}[*] Deduplicating URLs...${RESET}"

    sort -u "$input" | uro > "$output"

    if [ ! -s "$output" ]; then
        echo "[ERROR] No valid URLs found"
        exit 1
    fi
}

# ==========================================
# 🚀 MAIN SCANNING FUNCTION
# ==========================================

run_nuclei() {
    local input="$1"
    local output="$2"
    local FAST_MODE="$3"
    local DEEP_MODE="$4"

    LIVE_FILE="${input}.live"

    # --------------------------------------
    # 🧹 CLEANUP OLD FILES
    # --------------------------------------
    rm -f "$LIVE_FILE"

    # --------------------------------------
    # 🌐 HTTPX LIVE PROBING
    # --------------------------------------
    echo -e "${GREEN}[httpx] Probing live hosts...${RESET}"

    httpx \
        -silent \
        -retries 2 \
        -timeout 10 \
        -mc 200,204,301,302,401,403,405,500,502,503,504 \
        -l "$input" \
        -o "$LIVE_FILE" \
        > /dev/null 2>&1

    if [ ! -s "$LIVE_FILE" ]; then
        echo "[ERROR] No live hosts found"
        exit 1
    fi

    echo "[OK] Live hosts ready"

    # --------------------------------------
    # 🧠 SMART MODE ENGINE
    # --------------------------------------
    URL_COUNT=$(wc -l < "$LIVE_FILE")

    if [ "$FAST_MODE" = true ]; then
        MODE="FAST"
    elif [ "$DEEP_MODE" = true ]; then
        MODE="DEEP"
    else
        if [ "$URL_COUNT" -gt 400 ]; then
            MODE="FAST"
        else
            MODE="DEEP"
        fi
    fi

    echo "[*] Scan Mode: $MODE ($URL_COUNT URLs)"

    if [ "$MODE" = "FAST" ]; then
        RATE=200
        CONCURRENCY=80
    else
        RATE="$RATE_LIMIT"
        CONCURRENCY=50
    fi

    # --------------------------------------
    # 🔍 TEMPLATE VALIDATION
    # --------------------------------------
    if [ ! -d "$TEMPLATE_DIR" ] || [ -z "$(ls -A "$TEMPLATE_DIR" 2>/dev/null)" ]; then
        echo "[ERROR] Nuclei templates missing or empty at $TEMPLATE_DIR"
        echo "[FIX] Run: nf --update"
        exit 1
    fi

    # --------------------------------------
    # ⚡ NUCLEI SCAN (DAST ONLY - FASTEST)
    # --------------------------------------
    echo -e "${GREEN}[Nuclei] Running DAST-focused scan...${RESET}"

    if ! nuclei \
        -l "$LIVE_FILE" \
        -t "$TEMPLATE_DIR" \
        -dast \
        -severity critical,high,medium \
        -rl "$RATE" \
        -c "$CONCURRENCY" \
        -jsonl \
        -silent \
        -no-meta \
        2>/dev/null \
        | tee "$output" \
        | jq -r '"[VULN] \(.info.severity) | \(.info.name) | \(.host)"'
    then
        echo "[ERROR] Nuclei scan failed"
        exit 1
    fi

    # --------------------------------------
    # 📊 OUTPUT VALIDATION + SUMMARY
    # --------------------------------------
    if [ ! -s "$output" ]; then
        echo "[WARN] No vulnerabilities found"
    else
        echo "[OK] Nuclei scan completed"

        echo -e "${CYAN}[*] Scan Summary:${RESET}"

        CRIT=$(grep -c '"severity":"critical"' "$output")
        HIGH=$(grep -c '"severity":"high"' "$output")
        MED=$(grep -c '"severity":"medium"' "$output")

        echo "Critical: $CRIT"
        echo "High    : $HIGH"
        echo "Medium  : $MED"
    fi
}
