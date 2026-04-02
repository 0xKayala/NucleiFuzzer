#!/bin/bash

validate_input() {
    local input="$1"

    if [[ "$input" =~ ^https?:// ]]; then
        echo "$input"
    elif [[ "$input" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo "http://$input"
    else
        echo "[ERROR] Invalid input: $input"
        return 1
    fi
}

collect_urls() {
    local target="$1"
    local output_file="$2"

    local validated_target
    validated_target=$(validate_input "$target") || return 1

    echo "[*] Recon started for $validated_target"

    # ParamSpider
    python3 "$HOME_DIR/ParamSpider/paramspider.py" \
        -d "$target" \
        --exclude "$EXCLUDED_EXTENSIONS" \
        --level high \
        --quiet \
        -o "$output_file.tmp"

    cat "$output_file.tmp" >> "$output_file"
    rm -f "$output_file.tmp"

    # Wayback
    echo "$validated_target" | waybackurls >> "$output_file"

    # Gauplus
    echo "$validated_target" | gauplus -subs -b "$EXCLUDED_EXTENSIONS" >> "$output_file"
}
