#!/bin/bash

validate_urls() {
    local input="$1"
    local output="$2"

    sort -u "$input" | uro > "$output"

    if [ ! -s "$output" ]; then
        echo "[ERROR] No valid URLs found"
        exit 1
    fi
}

run_nuclei() {
    local input="$1"
    local output="$2"

    httpx -silent -l "$input" > "$input.live"

    if [ ! -s "$input.live" ]; then
        echo "[ERROR] No live hosts"
        exit 1
    fi

    nuclei -l "$input.live" \
        -severity critical,high,medium,low \
        -jsonl > "$output"
}
