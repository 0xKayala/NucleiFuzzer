#!/bin/bash

# ==========================================
# 🔥 NucleiFuzzer v3 - AI Powered Scanner
# Author: Satya Prakash (0xKayala)
# ==========================================

# =========================
# 🎨 COLORS & BANNER
# =========================

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
CYAN='\033[96m'
RESET='\033[0m'

echo -e "${RED}"
cat << "EOF"
                           __     _ ____                          
         ____  __  _______/ /__  (_) __/_  __________  ___  _____
        / __ \/ / / / ___/ / _ \/ / /_/ / / /_  /_  / / _ \/ ___/
       / / / / /_/ / /__/ /  __/ / __/ /_/ / / /_/ /_/  __/ /    
      /_/ /_/\__,_/\___/_/\___/_/_/  \__,_/ /___/___/\___/_/   v3
      
                ⚡ AI-Powered NucleiFuzzer | 0xKayala
EOF
echo -e "${RESET}"

# =========================
# 📦 BASE DIR (AUTO DETECT)
# =========================

SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# =========================
# 🛑 SAFETY CHECK
# =========================

if [ ! -d "$BASE_DIR/core" ]; then
    echo "[ERROR] Core modules not found!"
    echo "Resolved BASE_DIR: $BASE_DIR"
    exit 1
fi

# =========================
# 📦 LOAD MODULES
# =========================

source "$BASE_DIR/config/config.sh"
source "$BASE_DIR/core/recon.sh"
source "$BASE_DIR/core/crawling.sh"
source "$BASE_DIR/core/scanning.sh"
source "$BASE_DIR/core/reporting.sh"
source "$BASE_DIR/core/ai.sh"

# =========================
# 📌 HELP MENU
# =========================

display_help() {
    echo "Usage: nf -d domain.com [--ai]"
    exit 0
}

# =========================
# ⚙️ ARGUMENT PARSER
# =========================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--domain) DOMAIN="$2"; shift 2 ;;
        --ai) AI_MODE=true; shift ;;
        *) display_help ;;
    esac
done

if [ -z "$DOMAIN" ]; then
    display_help
fi

# =========================
# 🛠️ SETUP
# =========================

mkdir -p "$OUTPUT_DIR"

RAW_FILE="$OUTPUT_DIR/raw.txt"
VALIDATED_FILE="$OUTPUT_DIR/validated.txt"
JSON_FILE="$OUTPUT_DIR/results.json"
HTML_FILE="$OUTPUT_DIR/report.html"
AI_FILE="$OUTPUT_DIR/ai.txt"

> "$RAW_FILE"

echo -e "${GREEN}[*] Starting Scan Engine...${RESET}"

# =========================
# 🔍 RECON
# =========================
recon "$DOMAIN" "$RAW_FILE"

# =========================
# 🕷️ CRAWLING
# =========================
crawl "$DOMAIN" "$RAW_FILE"

# =========================
# 🔍 VALIDATION
# =========================
validate_urls "$RAW_FILE" "$VALIDATED_FILE"

# =========================
# ⚡ SCANNING
# =========================
run_nuclei "$VALIDATED_FILE" "$JSON_FILE"

# =========================
# 📊 REPORTING
# =========================
group_by_severity "$JSON_FILE"
generate_html_report "$JSON_FILE" "$HTML_FILE"

# =========================
# 🧠 AI
# =========================
if [ "$AI_MODE" = true ]; then
    run_ai_analysis "$JSON_FILE" "$AI_FILE"
fi

# =========================
# ✅ DONE
# =========================

echo ""
echo "======================================"
echo -e "${GREEN}✅ Scan Completed Successfully${RESET}"
echo "📁 JSON Report : $JSON_FILE"
echo "🌐 HTML Report : $HTML_FILE"
[ "$AI_MODE" = true ] && echo "🧠 AI Report   : $AI_FILE"
echo "======================================"
