#!/bin/bash

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

    echo -e "${BLUE}[*] Probing live hosts...${RESET}"
    httpx -silent -l "$input" > "$input.live"

    if [ ! -s "$input.live" ]; then
        echo "[ERROR] No live hosts found"
        exit 1
    fi

    echo -e "${BLUE}[*] Running Nuclei scan...${RESET}"

    nuclei -l "$input.live" \
        -severity critical,high,medium,low \
        -rl "$RATE_LIMIT" \
        -jsonl > "$output"

    if [ ! -s "$output" ]; then
        echo "[WARN] No vulnerabilities found"
    fi
}