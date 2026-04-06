#!/bin/bash

# ==========================================
# ⚡ SCANNING MODULE (DAST + CLEAN)
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

run_nuclei() {
    local input="$1"
    local output="$2"

    echo -e "${GREEN}[httpx] Probing live hosts...${RESET}"

    httpx -silent \
        -mc 200,204,301,302,401,403,405,500,502,503,504 \
        -l "$input" \
        -o "$input.live"

    if [ ! -s "$input.live" ]; then
        echo "[ERROR] No live hosts found"
        exit 1
    fi

    # ==========================================
    # 🔍 TEMPLATE CHECK (CRITICAL FIX)
    # ==========================================

    DAST_DIR="$TEMPLATE_DIR/dast"

    if [ ! -d "$DAST_DIR" ] || [ -z "$(ls -A "$DAST_DIR" 2>/dev/null)" ]; then
        echo "[WARN] DAST templates not found → fallback to tags"

        TEMPLATE_MODE="-tags xss,sqli,ssrf,lfi,rce"
    else
        TEMPLATE_MODE="-t $DAST_DIR"
    fi    

    echo -e "${GREEN}[Nuclei] Running DAST-focused scan...${RESET}"

    nuclei \
        -l "$input.live" \
        -t "$TEMPLATE_DIR/dast/" \
        -severity critical,high,medium \
        -rl "$RATE_LIMIT" \
        -jsonl \
        -silent \
        -o "$output"

    # ==========================================
    # ✅ OUTPUT VALIDATION
    # ==========================================        

    if [ ! -s "$output" ]; then
        echo "[WARN] No vulnerabilities found"
    else
        echo "[OK] Nuclei scan completed"
    fi
}
