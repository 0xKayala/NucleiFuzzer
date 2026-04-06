#!/bin/bash

# ==========================================
# 🕸️ CRAWLING MODULE (PARALLEL + SMART MERGE)
# ==========================================

crawl() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Crawling $target${RESET}"

    TMP_DIR=$(mktemp -d)

    # ==========================================
    # ⚡ PARALLEL CRAWLING
    # ==========================================

    # Hakrawler
    echo -e "${GREEN}[Hakrawler] Crawling...${RESET}"
    (echo "$target" | hakrawler -d 3 -subs -u > "$TMP_DIR/hakrawler.txt" 2>/dev/null) &

    # Katana
    echo -e "${GREEN}[Katana] Deep crawling...${RESET}"
    (echo "$target" | katana -d 3 -silent -follow-redirects > "$TMP_DIR/katana.txt" 2>/dev/null) &

    # Wait for both tools
    wait

    # ==========================================
    # 🧩 MERGE RESULTS
    # ==========================================

    cat "$TMP_DIR"/*.txt 2>/dev/null >> "$output_file"

    # ==========================================
    # 🧠 SMART FILTERING (HIGH VALUE URLS)
    # ==========================================

    echo -e "${CYAN}[*] Filtering crawl results...${RESET}"

    FILTERED_FILE="$TMP_DIR/filtered.txt"

    if declare -f smart_filter_urls >/dev/null; then
        smart_filter_urls "$output_file" "$FILTERED_FILE"
        mv "$FILTERED_FILE" "$output_file"
    fi

    # ==========================================
    # 📉 PERFORMANCE CONTROL (LIMIT SIZE)
    # ==========================================

    TOTAL=$(wc -l < "$output_file")

    if [ "$TOTAL" -gt 2000 ]; then
        echo "[*] Large crawl dataset ($TOTAL URLs) → limiting to 1200"
        head -n 1200 "$output_file" > "$output_file.tmp"
        mv "$output_file.tmp" "$output_file"
        TOTAL=1200
    fi

    # ==========================================
    # 🛡️ FALLBACK
    # ==========================================

    if [ ! -s "$output_file" ]; then
        echo "[WARN] No URLs found, adding root domain"
        echo "$target" >> "$output_file"
    fi

    # ==========================================
    # 🧹 CLEANUP
    # ==========================================

    rm -rf "$TMP_DIR"

    echo -e "${GREEN}[✔] Crawling completed (${TOTAL} URLs)${RESET}"
}
