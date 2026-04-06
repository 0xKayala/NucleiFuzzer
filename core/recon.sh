#!/bin/bash

# ==========================================
# 🔍 RECON MODULE (PARALLEL + SMART FILTER)
# ==========================================

recon() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Recon started for $target${RESET}"

    TMP_DIR=$(mktemp -d)

    # ==========================================
    # ⚡ PARALLEL URL COLLECTION
    # ==========================================

    # ParamSpider (safe execution)
    echo -e "${GREEN}[ParamSpider] Collecting URLs...${RESET}"
    if [ -f "$HOME/ParamSpider/paramspider.py" ]; then
        python3 "$HOME/ParamSpider/paramspider.py" \
            -d "$target" \
            --exclude "$EXCLUDED_EXTENSIONS" \
            --quiet \
            -o "$TMP_DIR/paramspider.txt" 2>/dev/null &
    else
        echo "[WARN] ParamSpider not found"
    fi

    # Waybackurls
    echo -e "${GREEN}[Waybackurls] Fetching URLs...${RESET}"
    (echo "$target" | waybackurls > "$TMP_DIR/wayback.txt" 2>/dev/null) &

    # Gauplus
    echo -e "${GREEN}[Gauplus] Collecting URLs...${RESET}"
    (echo "$target" | gauplus -subs > "$TMP_DIR/gau.txt" 2>/dev/null) &

    # Wait for all background jobs
    wait

    # ==========================================
    # 🧩 MERGE RESULTS
    # ==========================================

    cat "$TMP_DIR"/*.txt 2>/dev/null >> "$output_file"

    # ==========================================
    # 🧠 SMART FILTERING (HIGH VALUE URLS)
    # ==========================================

    echo -e "${CYAN}[*] Applying smart filtering...${RESET}"

    FILTERED_FILE="$TMP_DIR/filtered.txt"

    if declare -f smart_filter_urls >/dev/null; then
        smart_filter_urls "$output_file" "$FILTERED_FILE"
        mv "$FILTERED_FILE" "$output_file"
    fi

    # ==========================================
    # 📉 PERFORMANCE CONTROL (LIMIT SIZE)
    # ==========================================

    TOTAL=$(wc -l < "$output_file")

    if [ "$TOTAL" -gt 1500 ]; then
        echo "[*] Large dataset detected ($TOTAL URLs) → limiting to 1000"
        head -n 1000 "$output_file" > "$output_file.tmp"
        mv "$output_file.tmp" "$output_file"
        TOTAL=1000
    fi

    # ==========================================
    # 🛡️ FALLBACK PROTECTION
    # ==========================================

    if [ ! -s "$output_file" ]; then
        echo "[WARN] Recon produced no results, adding root"
        echo "$target" >> "$output_file"
    fi

    # ==========================================
    # 🧹 CLEANUP
    # ==========================================

    rm -rf "$TMP_DIR"

    echo -e "${GREEN}[✔] Recon completed (${TOTAL} URLs)${RESET}"
}
