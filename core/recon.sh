#!/bin/bash

# ==========================================
# 🔍 RECON MODULE (PARALLEL + AI + PLUGIN READY)
# ==========================================

recon() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Recon started for $target${RESET}"

    TMP_DIR=$(mktemp -d)

    RAW_FILE="$TMP_DIR/raw.txt"
    CLEAN_FILE="$TMP_DIR/clean.txt"
    FILTERED_FILE="$TMP_DIR/filtered.txt"

    # ------------------------------------------
    # 🔌 PRE-RECON PLUGINS
    # ------------------------------------------
    if declare -f run_plugins >/dev/null; then
        run_plugins "pre_recon"
    fi

    # ==========================================
    # ⚡ PARALLEL URL COLLECTION
    # ==========================================

    echo -e "${GREEN}[ParamSpider] Collecting URLs...${RESET}"
    if [ -f "$HOME/ParamSpider/paramspider.py" ]; then
        python3 "$HOME/ParamSpider/paramspider.py" \
            -d "$target" \
            --exclude "$EXCLUDED_EXTENSIONS" \
            --quiet \
            -o "$TMP_DIR/paramspider.txt" 2>/dev/null &
    else
        echo "[WARN] ParamSpider not found"
    fi

    echo -e "${GREEN}[Waybackurls] Fetching URLs...${RESET}"
    (echo "$target" | waybackurls > "$TMP_DIR/wayback.txt" 2>/dev/null) &

    echo -e "${GREEN}[Gauplus] Collecting URLs...${RESET}"
    (echo "$target" | gauplus -subs > "$TMP_DIR/gau.txt" 2>/dev/null) &

    wait

    # ==========================================
    # 🧩 MERGE RESULTS
    # ==========================================

    cat "$TMP_DIR"/*.txt 2>/dev/null > "$RAW_FILE"

    # ==========================================
    # 🧹 CLEAN + NORMALIZE
    # ==========================================

    grep -E '^https?://' "$RAW_FILE" \
        | sort -u > "$CLEAN_FILE"

    if [ ! -s "$CLEAN_FILE" ]; then
        echo "[WARN] No valid URLs found → fallback to raw"
        cp "$RAW_FILE" "$CLEAN_FILE"
    fi

    # ==========================================
    # 🧠 SMART + AI FILTERING
    # ==========================================

    echo -e "${CYAN}[*] Applying intelligent filtering...${RESET}"

    # Step 1: Smart filter (baseline)
    if declare -f smart_filter_urls >/dev/null; then
        smart_filter_urls "$CLEAN_FILE" "$FILTERED_FILE"
    else
        cp "$CLEAN_FILE" "$FILTERED_FILE"
    fi

    # Step 2: AI filter (if enabled)
    if declare -f ai_filter_urls >/dev/null; then
        AI_FILE="$TMP_DIR/ai_filtered.txt"
        ai_filter_urls "$FILTERED_FILE" "$AI_FILE"

        if [ -s "$AI_FILE" ]; then
            mv "$AI_FILE" "$FILTERED_FILE"
        fi
    fi

    # Step 3: Fallback protection
    if [ ! -s "$FILTERED_FILE" ]; then
        echo "[WARN] Filtering removed too much → fallback to clean URLs"
        cp "$CLEAN_FILE" "$FILTERED_FILE"
    fi

    # ==========================================
    # 🔌 POST-RECON PLUGINS
    # ==========================================

    export RAW_URLS="$FILTERED_FILE"

    if declare -f run_plugins >/dev/null; then
        run_plugins "post_recon"
    fi

    # ==========================================
    # 📦 FINAL OUTPUT
    # ==========================================

    mv "$FILTERED_FILE" "$output_file"

    TOTAL=$(wc -l < "$output_file")

    # ==========================================
    # 🛡️ FALLBACK PROTECTION
    # ==========================================

    if [ ! -s "$output_file" ]; then
        echo "[WARN] Recon produced no results, adding root"
        echo "$target" >> "$output_file"
        TOTAL=1
    fi

    # ==========================================
    # 🧹 CLEANUP
    # ==========================================

    rm -rf "$TMP_DIR"

    echo -e "${GREEN}[✔] Recon completed (${TOTAL} URLs)${RESET}"
}
