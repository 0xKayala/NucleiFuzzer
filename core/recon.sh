#!/bin/bash

# ==========================================
# 🔍 RECON MODULE (STABLE + AI + PLUGIN READY)
# ==========================================

recon() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Recon started for $target${RESET}"

    TMP_DIR=$(mktemp -d)

    RAW_FILE_TMP="$TMP_DIR/raw.txt"
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
    fi

    echo -e "${GREEN}[Waybackurls] Fetching URLs...${RESET}"
    (echo "$target" | waybackurls > "$TMP_DIR/wayback.txt" 2>/dev/null) &

    echo -e "${GREEN}[Gauplus] Collecting URLs...${RESET}"
    (echo "$target" | gauplus -subs > "$TMP_DIR/gau.txt" 2>/dev/null) &

    wait

    # ==========================================
    # 🧩 SAFE MERGE (FIXED)
    # ==========================================

    for f in "$TMP_DIR"/*.txt; do
        [ -f "$f" ] && strings "$f" >> "$RAW_FILE_TMP"
    done

    # ==========================================
    # 🧹 CLEAN + NORMALIZE (SAFE)
    # ==========================================

    grep -aE '^https?://' "$RAW_FILE_TMP" \
        | sort -u > "$CLEAN_FILE"

    if [ ! -s "$CLEAN_FILE" ]; then
        echo "[WARN] No valid URLs found → fallback to raw"
        cp "$RAW_FILE_TMP" "$CLEAN_FILE"
    fi

    # ==========================================
    # 🧠 SMART + AI FILTERING
    # ==========================================

    echo -e "${CYAN}[*] Applying intelligent filtering...${RESET}"

    if declare -f smart_filter_urls >/dev/null; then
        smart_filter_urls "$CLEAN_FILE" "$FILTERED_FILE"
    else
        cp "$CLEAN_FILE" "$FILTERED_FILE"
    fi

    # AI filtering (optional)
    if declare -f ai_filter_urls >/dev/null; then
        AI_FILE="$TMP_DIR/ai_filtered.txt"
        ai_filter_urls "$FILTERED_FILE" "$AI_FILE"

        [ -s "$AI_FILE" ] && mv "$AI_FILE" "$FILTERED_FILE"
    fi

    # Fallback
    if [ ! -s "$FILTERED_FILE" ]; then
        echo "[WARN] Filtering too aggressive → fallback"
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
    # 📦 FINAL OUTPUT (FIXED)
    # ==========================================

    cat "$FILTERED_FILE" >> "$output_file"

    TOTAL=$(wc -l < "$output_file")

    # ==========================================
    # 🛡️ FALLBACK
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
