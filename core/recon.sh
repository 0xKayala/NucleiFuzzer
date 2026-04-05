#!/bin/bash

# ==========================================
# 🔍 RECON MODULE
# ==========================================

recon() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Recon started for $target${RESET}"

    TMP_FILE=$(mktemp)

    # ParamSpider (safe execution)
    if [ -f "$HOME/ParamSpider/paramspider.py" ]; then
        python3 "$HOME/ParamSpider/paramspider.py" \
            -d "$target" \
            --exclude "$EXCLUDED_EXTENSIONS" \
            --quiet \
            -o "$TMP_FILE" 2>/dev/null

        cat "$TMP_FILE" >> "$output_file" 2>/dev/null
    else
        echo "[WARN] ParamSpider not found"
    fi

    # Passive sources (safe)
    echo "$target" | waybackurls 2>/dev/null >> "$output_file"
    echo "$target" | gauplus -subs 2>/dev/null >> "$output_file"

    rm -f "$TMP_FILE"

    # Fallback protection
    if [ ! -s "$output_file" ]; then
        echo "[WARN] Recon produced no results, adding root"
        echo "$target" >> "$output_file"
    fi
}
