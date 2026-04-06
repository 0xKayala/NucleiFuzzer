#!/bin/bash

# ==========================================
# ⚡ SCANNING MODULE (FINAL STABLE BUILD)
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
    TEMP_JSON="$(mktemp)"

    # --------------------------------------
    # 🧹 CLEANUP OLD FILES
    # --------------------------------------
    rm -f "$LIVE_FILE" "$TEMP_JSON"

    # --------------------------------------
    # 🌐 HTTPX LIVE PROBING
    # --------------------------------------
    echo -e "${GREEN}[httpx] Probing live hosts...${RESET}"

    httpx -silent -retries 2 -timeout 10 \
        -mc 200,204,301,302,401,403,405,500,502,503,504 \
        -l "$input" \
        -o "$LIVE_FILE" \
        > /dev/null 2>&1

    if [ ! -s "$LIVE_FILE" ]; then
        echo "[ERROR] No live hosts found"
        exit 1
    fi

    echo "[OK] Live hosts ready"

    URL_COUNT=$(wc -l < "$LIVE_FILE")

    # --------------------------------------
    # 🧠 SMART MODE ENGINE
    # --------------------------------------
    if [ "$FAST_MODE" = true ]; then
        MODE="FAST"
    elif [ "$DEEP_MODE" = true ]; then
        MODE="DEEP"
    else
        [ "$URL_COUNT" -gt 400 ] && MODE="FAST" || MODE="DEEP"
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
    # 🔍 TEMPLATE CHECK
    # --------------------------------------
    if [ ! -d "$TEMPLATE_DIR" ]; then
        echo "[ERROR] Templates missing → run nf --update"
        exit 1
    fi

    # --------------------------------------
    # ⚡ NUCLEI SCAN (SAFE PIPELINE)
    # --------------------------------------
    echo -e "${GREEN}[Nuclei] Running DAST-focused scan...${RESET}"

    nuclei -l "$LIVE_FILE" \
        -t "$TEMPLATE_DIR" \
        -dast \
        -severity critical,high,medium \
        -rl "$RATE" \
        -c "$CONCURRENCY" \
        -jsonl -silent -no-meta 2>/dev/null \
        | grep -a '^{.*}' \
        | tee "$TEMP_JSON" \
        | jq -r '"[VULN] \(.info.severity) | \(.info.name) | \(.host)"'

    # --------------------------------------
    # 🔁 FALLBACK SCAN (SMART)
    # --------------------------------------
    if [ ! -s "$TEMP_JSON" ]; then
        echo "[INFO] No results → running fallback scan..."

        nuclei -l "$LIVE_FILE" \
            -tags xss,sqli,ssrf,lfi,rce \
            -severity medium,high \
            -rl "$RATE" \
            -jsonl -silent 2>/dev/null \
            | grep -a '^{.*}' \
            | tee "$TEMP_JSON" \
            | jq -r '"[VULN] \(.info.severity) | \(.info.name) | \(.host)"'
    fi

    # --------------------------------------
    # 📦 FINAL OUTPUT WRITE
    # --------------------------------------
    mv "$TEMP_JSON" "$output"

    # --------------------------------------
    # 📊 SUMMARY
    # --------------------------------------
    if [ ! -s "$output" ]; then
        echo "[WARN] No vulnerabilities found"
    else
        echo "[OK] Nuclei scan completed"

        echo -e "${CYAN}[*] Scan Summary:${RESET}"

        grep -o '"severity":"critical"' "$output" | wc -l | awk '{print "Critical:",$1}'
        grep -o '"severity":"high"' "$output" | wc -l | awk '{print "High    :",$1}'
        grep -o '"severity":"medium"' "$output" | wc -l | awk '{print "Medium  :",$1}'
    fi

    # --------------------------------------
    # 🧹 CLEANUP
    # --------------------------------------
    rm -f "$LIVE_FILE"
}
