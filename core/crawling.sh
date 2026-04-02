#!/bin/bash

crawl_urls() {
    local target="$1"
    local output_file="$2"

    echo "[*] Crawling $target"

    # Hakrawler
    echo "$target" | hakrawler -d 3 -subs -u >> "$output_file"

    # Katana
    echo "$target" | katana -d 3 -silent -rl 10 >> "$output_file"
}

validate_urls() {
    local input_file="$1"
    local output_file="$2"

    if [ ! -s "$input_file" ]; then
        echo "[ERROR] No URLs found!"
        exit 1
    fi

    echo "[*] Deduplicating URLs..."

    sort -u "$input_file" | uro > "$output_file"
}
