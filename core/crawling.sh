#!/bin/bash

# ==========================================
# 🕸️ CRAWLING MODULE (STABLE + AI + PLUGIN READY)
# ==========================================

crawl() {
    local target="$1"
    local output_file="$2"

    target=$(normalize_url "$target")

    echo -e "${BLUE}[*] Crawling $target${RESET}"

    TMP_DIR=$(mktemp -d)

    RAW_FILE="$TMP_DIR/raw.txt"
    CLEAN_FILE="$TMP_DIR/clean.txt"
    FILTERED_FILE="$TMP_DIR/filtered.txt"
    JS_FILE="$TMP_DIR/js.txt"

    # ------------------------------------------
    # ⚡ PARALLEL CRAWLING
    # ------------------------------------------

    echo -e "${GREEN}[Hakrawler] Crawling...${RESET}"
    (echo "$target" | hakrawler -d 3 -subs -u > "$TMP_DIR/hakrawler.txt" 2>/dev/null) &

    echo -e "${GREEN}[Katana] Deep crawling...${RESET}"
    (echo "$target" | katana -d 3 -silent -follow-redirects > "$TMP_DIR/katana.txt" 2>/dev/null) &

    wait

    # ------------------------------------------
    # 🧩 SAFE MERGE (FIXED)
    # ------------------------------------------

    touch "$RAW_FILE"

    for f in "$TMP_DIR"/*.txt; do
        [ -f "$f" ] && strings "$f" >> "$RAW_FILE"
    done

    # ------------------------------------------
    # 🧹 CLEAN + NORMALIZE
    # ------------------------------------------

    grep -aE 'https?://' "$RAW_FILE" \
        | sed 's/[]["<> ]//g' \
        | sort -u > "$CLEAN_FILE"

    if [ ! -s "$CLEAN_FILE" ]; then
        echo "[WARN] No crawl results → fallback"
        cp "$RAW_FILE" "$CLEAN_FILE"
    fi

    # ------------------------------------------
    # 📜 JS FILE EXTRACTION (AI READY)
    # ------------------------------------------

    grep -aEi '\.js(\?|$)' "$CLEAN_FILE" > "$JS_FILE" 2>/dev/null

    if [ -s "$JS_FILE" ]; then
        COUNT=$(wc -l < "$JS_FILE")
        echo "[*] JS files detected: $COUNT"
        export JS_URLS="$JS_FILE"
    fi

    # ------------------------------------------
    # 🧠 SMART + AI FILTERING
    # ------------------------------------------

    echo -e "${CYAN}[*] Applying intelligent filtering...${RESET}"

    if declare -f smart_filter_urls >/dev/null; then
        smart_filter_urls "$CLEAN_FILE" "$FILTERED_FILE"
    else
        cp "$CLEAN_FILE" "$FILTERED_FILE"
    fi

    # AI filtering
    if declare -f ai_filter_urls >/dev/null; then
        AI_FILE="$TMP_DIR/ai_filtered.txt"
        ai_filter_urls "$FILTERED_FILE" "$AI_FILE"

        [ -s "$AI_FILE" ] && mv "$AI_FILE" "$FILTERED_FILE"
    fi

    # Fallback protection
    if [ ! -s "$FILTERED_FILE" ]; then
        echo "[WARN] Filtering too aggressive → fallback"
        cp "$CLEAN_FILE" "$FILTERED_FILE"
    fi

    # ------------------------------------------
    # 🔌 POST-CRAWL PLUGINS
    # ------------------------------------------

    export RAW_URLS="$FILTERED_FILE"

    if declare -f run_plugins >/dev/null; then
        run_plugins "post_crawl"
    fi

    # ------------------------------------------
    # 📦 FINAL OUTPUT (FIXED)
    # ------------------------------------------

    cat "$FILTERED_FILE" >> "$output_file"

    TOTAL=$(wc -l < "$output_file")

    # ------------------------------------------
    # 🛡️ FALLBACK
    # ------------------------------------------

    if [ ! -s "$output_file" ]; then
        echo "[WARN] No URLs found, adding root domain"
        echo "$target" >> "$output_file"
        TOTAL=1
    fi

    # ------------------------------------------
    # 🧹 CLEANUP
    # ------------------------------------------

    rm -rf "$TMP_DIR"

    echo -e "${GREEN}[✔] Crawling completed (${TOTAL} URLs)${RESET}"
}
