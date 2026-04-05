#!/bin/bash

recon() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Recon started for $target${RESET}"

    # ParamSpider
    python3 "$HOME/ParamSpider/paramspider.py" \
        -d "$target" \
        --exclude "$EXCLUDED_EXTENSIONS" \
        --quiet \
        -o "$output_file.tmp" 2>/dev/null

    if [ -f "$output_file.tmp" ]; then
        cat "$output_file.tmp" >> "$output_file"
        rm -f "$output_file.tmp"
    else
        echo "[WARN] ParamSpider failed"
    fi

    # Passive recon
    echo "$target" | waybackurls >> "$output_file" 2>/dev/null
    echo "$target" | gauplus -subs >> "$output_file" 2>/dev/null
}
