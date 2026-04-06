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

    # --------------------------------------
    # 🧹 CLEANUP OLD FILES
    # --------------------------------------
    rm -f "$input.live"

    # --------------------------------------
    # 🌐 HTTPX LIVE PROBING
    # --------------------------------------
    echo -e "${GREEN}[httpx] Probing live hosts...${RESET}"

    if [ "$VERBOSE" = true ]; then
        httpx \
            -retries 2 \
            -timeout 10 \
            -mc 200,204,301,302,401,403,405,500,502,503,504 \
            -l "$input" \
            -o "$input.live"
    else
        httpx \
            -silent \
            -retries 2 \
            -timeout 10 \
            -mc 200,204,301,302,401,403,405,500,502,503,504 \
            -l "$input" \
            -o "$input.live" \
            > /dev/null 2>&1
    fi

    if [ ! -s "$input.live" ]; then
        echo "[ERROR] No live hosts found"
        exit 1
    fi

    echo "[OK] Live hosts ready"

    # --------------------------------------
    # 🔍 TEMPLATE VALIDATION
    # --------------------------------------
    if [ ! -d "$TEMPLATE_DIR" ] || [ -z "$(ls -A "$TEMPLATE_DIR" 2>/dev/null)" ]; then
        echo "[ERROR] Nuclei templates missing or empty at $TEMPLATE_DIR"
        echo "[FIX] Run: nf --update"
        exit 1
    fi

    # --------------------------------------
    # ⚡ NUCLEI SCAN (DAST + FILTERED)
    # --------------------------------------
    echo -e "${GREEN}[Nuclei] Running DAST-focused scan...${RESET}"

    if ! nuclei \
        -l "$input.live" \
        -t "$TEMPLATE_DIR" \
        -dast \
        -tags xss,sqli,ssrf,lfi,rce,idor,auth-bypass \
        -severity critical,high,medium \
        -rl "$RATE_LIMIT" \
        -jsonl \
        -silent \
        -no-meta \
        -o "$output"; then

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
