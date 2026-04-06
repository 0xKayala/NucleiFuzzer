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
    
    if [ "$VERBOSE" = true ]; then
        httpx -mc 200,204,301,302,401,403,405,500,502,503,504 \
            -l "$input" \
            -o "$input.live"
    else
        httpx -silent \
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

    # ==========================================
    # 🔍 TEMPLATE CHECK (CRITICAL FIX)
    # ==========================================

    if [ ! -d "$TEMPLATE_DIR" ] || [ -z "$(ls -A "$TEMPLATE_DIR" 2>/dev/null)" ]; then
        echo "[ERROR] Nuclei templates missing or empty at $TEMPLATE_DIR"
        echo "[FIX] Run: nf --update"
        exit 1
    fi

    echo -e "${GREEN}[Nuclei] Running DAST-focused scan...${RESET}"

    nuclei \
        -l "$input.live" \
        -t "$TEMPLATE_DIR" \
        -dast \
        -tags xss,sqli,ssrf,lfi,rce,idor,auth-bypass,cve,takeover,exposure,config,wordpress \
        -severity critical,high,medium \
        -rl "$RATE_LIMIT" \
        -jsonl \
        -silent \
        -no-meta \
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
