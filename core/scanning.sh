#!/bin/bash

run_nuclei() {
    local input_file="$1"

    echo "[*] Running HTTP probe..."

    httpx -silent \
        -mc 200,204,301,302,401,403,405,500,502,503,504 \
        -l "$input_file" > "$OUTPUT_FOLDER/live.txt"

    echo "[*] Running Nuclei scan..."

    nuclei \
        -t "$TEMPLATE_DIR" \
        -json \
        -rl "$RATE_LIMIT" \
        -l "$OUTPUT_FOLDER/live.txt" \
        -o "$JSON_FILE"
}
