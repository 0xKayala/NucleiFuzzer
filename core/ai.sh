#!/bin/bash

# ==========================================
# 🧠 AI ANALYSIS & LOGIC ENGINE (v3.4)
# ==========================================

run_ai_analysis() {
    local json="$1"
    local output="$2"
    local js_file="$JS_URLS" # Exported from crawling.sh

    if [ ! -f "$json" ] || [ ! -s "$json" ]; then
        echo "[WARN] No data for AI analysis"
        return
    fi

    echo -e "${BLUE}[*] Running Deep AI Context Analysis...${RESET}"

    AI_PROVIDER="none"
    if command -v gemini &>/dev/null && [ -n "$GEMINI_API_KEY" ]; then
        AI_PROVIDER="gemini"
    fi

    if [ "$AI_PROVIDER" == "none" ]; then
        echo "[WARN] Gemini CLI not configured. Skipping Deep AI Analysis."
        return
    fi

    {
        echo "======================================"
        echo "🧠 DEEP AI SECURITY INSIGHTS"
        echo "======================================"
        echo ""
    } > "$output"

    # --------------------------------------
    # 🕵️‍♂️ Phase 1: JS Business Logic Extraction
    # --------------------------------------
    if [ -n "$js_file" ] && [ -s "$js_file" ]; then
        echo -e "${CYAN}[*] Analyzing JS files for hidden endpoints...${RESET}"
        
        # Analyze top 3 to save token limits
        head -n 3 "$js_file" > "$OUTPUT_DIR/top_js.txt"
        
        echo -e "### Hidden API Endpoints & Logic (Extracted from JS) ###\n" >> "$output"
        
        while read -r js_url; do
            [ -z "$js_url" ] && continue
            echo "[*] Fetching and analyzing: $js_url"
            
            # Fetch JS and send snippet to AI
            curl -sL "$js_url" | head -c 8000 | gemini "
            You are an expert bug bounty hunter. Read this JavaScript snippet. 
            Extract any hidden API endpoints, hardcoded secrets, AWS keys, or administrative paths. 
            Format as a bulleted list. Do not explain the code, just extract the vulnerabilities.
            " >> "$output"
            echo "" >> "$output"
        done < "$OUTPUT_DIR/top_js.txt"
    fi

    # --------------------------------------
    # 🎯 Phase 2: Vulnerability Chaining
    # --------------------------------------
    echo -e "${CYAN}[*] Generating Attack Chains...${RESET}"
    echo -e "\n### AI Attack Chaining Strategies ###\n" >> "$output"
    
    gemini "
    You are an elite penetration tester. Review this vulnerability report JSON.
    Identify how these vulnerabilities can be chained together (e.g., combining an Open Redirect with an SSRF).
    Provide a step-by-step exploitation strategy for the highest severity finding.
    " < "$json" >> "$output"

    echo -e "${GREEN}[OK] Deep AI analysis saved → $output${RESET}"
}
