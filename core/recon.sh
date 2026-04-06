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
    echo -e "${GREEN}[ParamSpider] Collecting URLs...${RESET}"
    if [ -f "$HOME/ParamSpider/paramspider.py" ]; then
        python3 "$HOME/ParamSpider/paramspider.py" \
            -d "$target" \
            --exclude "$EXCLUDED_EXTENSIONS" \
            --quiet \
            -o "$TMP_FILE" 2>/dev/null

        cat "$TMP_FILE" >> "$output_file"
        echo "[OK] ParamSpider completed"
    else
        echo "[WARN] ParamSpider not found"
    fi

    # Passive sources (safe)
    echo -e "${GREEN}[Waybackurls] Fetching URLs...${RESET}"
    echo "$target" | waybackurls >> "$output_file" 2>/dev/null

    echo -e "${GREEN}[Gauplus] Collecting URLs...${RESET}"
    echo "$target" | gauplus -subs >> "$output_file" 2>/dev/null

    rm -f "$TMP_FILE"

    # Fallback protection
    if [ ! -s "$output_file" ]; then
        echo "[WARN] Recon produced no results, adding root"
        echo "$target" >> "$output_file"
    fi
}
