#!/bin/bash

crawl() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Crawling $target${RESET}"

    echo "$target" | hakrawler -d 3 -subs -u >> "$output_file" 2>/dev/null
    echo "$target" | katana -d 3 -silent -follow-redirects >> "$output_file" 2>/dev/null

    # Fallback
    if [ ! -s "$output_file" ]; then
        echo "[WARN] No URLs found, adding root domain"
        echo "$target" >> "$output_file"
    fi
}