#!/bin/bash

# ==========================================
# 🕸️ CRAWLING MODULE (PARALLEL + AI + PLUGIN READY)
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
    # 🧩 MERGE RESULTS
    # ------------------------------------------

    cat "$TMP_DIR"/*.txt 2>/dev/null > "$RAW_FILE"

    # ------------------------------------------
    # 🧹 CLEAN + DEDUP
    # ------------------------------------------

    grep -E '^https?://' "$RAW_FILE" \
        | sort -u > "$CLEAN_FILE"

    if [ ! -s "$CLEAN_FILE" ]; then
        echo "[WARN] No crawl results → fallback"
        cp "$RAW_FILE" "$CLEAN_FILE"
    fi

    # ------------------------------------------
    # 📜 JS FILE EXTRACTION (NEW)
    # ------------------------------------------

    grep -Ei '\.js$' "$CLEAN_FILE" > "$JS_FILE" 2>/dev/null

    if [ -s "$JS_FILE" ]; then
        echo "[*] JS files detected: $(wc -l < "$JS_FILE")"
        export JS_URLS="$JS_FILE"
    fi

    # ------------------------------------------
    # 🧠 SMART + AI FILTERING
    # ------------------------------------------

    echo -e "${CYAN}[*] Applying intelligent filtering...${RESET}"

    # Step 1: Smart filter
    if declare -f smart_filter_urls >/dev/null; then
        smart_filter_urls "$CLEAN_FILE" "$FILTERED_FILE"
    else
        cp "$CLEAN_FILE" "$FILTERED_FILE"
    fi

    # Step 2: AI filter
    if declare -f ai_filter_urls >/dev/null; then
        AI_FILE="$TMP_DIR/ai_filtered.txt"
        ai_filter_urls "$FILTERED_FILE" "$AI_FILE"

        if [ -s "$AI_FILE" ]; then
            mv "$AI_FILE" "$FILTERED_FILE"
        fi
    fi

    # Step 3: Fallback
    if [ ! -s "$FILTERED_FILE" ]; then
        echo "[WARN] Filtering removed too much → fallback"
        cp "$CLEAN_FILE" "$FILTERED_FILE"
    fi

    # ------------------------------------------
    # 🔌 POST-CRAWL PLUGINS (NEW)
    # ------------------------------------------

    export RAW_URLS="$FILTERED_FILE"

    if declare -f run_plugins >/dev/null; then
        run_plugins "post_crawl"
    fi

    # ------------------------------------------
    # 📦 FINAL OUTPUT
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
