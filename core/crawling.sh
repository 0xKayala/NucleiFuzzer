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
    echo "$target" | hakrawler -d 3 -subs -u 2>/dev/null >> "$TMP_FILE"

    # Katana
    echo "$target" | katana -d 3 -silent -follow-redirects 2>/dev/null >> "$TMP_FILE"

    # Merge results safely
    if [ -s "$TMP_FILE" ]; then
        cat "$TMP_FILE" >> "$output_file"
    else
        echo "[WARN] No URLs found, adding root domain"
        echo "$target" >> "$output_file"
    fi

    rm -f "$TMP_FILE"
}
