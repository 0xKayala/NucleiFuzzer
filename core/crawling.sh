#!/bin/bash

# ==========================================
# 🕸️ CRAWLING MODULE
# ==========================================

crawl() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Crawling $target${RESET}"

    TMP_FILE=$(mktemp)

    # Hakrawler
    echo -e "${GREEN}[Hakrawler] Crawling...${RESET}"
    echo "$target" | hakrawler -d 3 -subs -u >> "$TMP_FILE" 2>/dev/null

    # Katana
    echo -e "${GREEN}[Katana] Deep crawling...${RESET}"
    echo "$target" | katana -d 3 -silent -follow-redirects >> "$TMP_FILE" 2>/dev/null

    # Merge results safely
    if [ -s "$TMP_FILE" ]; then
        cat "$TMP_FILE" >> "$output_file"
    else
        echo "[WARN] No URLs found, adding root domain"
        echo "$target" >> "$output_file"
    fi

    rm -f "$TMP_FILE"
}
