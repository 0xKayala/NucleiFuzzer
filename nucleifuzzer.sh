#!/bin/bash

# ==========================================
# 🔥 NucleiFuzzer v3.0 - AI Powered Scanner
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

show_banner() {
echo -e "${RED}"
cat << "EOF"
                           __     _ ____                          
         ____  __  _______/ /__  (_) __/_  __________  ___  _____
        / __ \/ / / / ___/ / _ \/ / /_/ / / /_  /_  / / _ \/ ___/
       / / / / /_/ / /__/ /  __/ / __/ /_/ / / /_/ /_/  __/ /    
      /_/ /_/\__,_/\___/_/\___/_/_/  \__,_/ /___/___/\___/_/   v3.0
      
                ⚡ AI-Powered NucleiFuzzer | 0xKayala
EOF
echo -e "${RESET}"
}

# =========================
# 📌 HELP MENU
# =========================

show_help() {
show_banner
echo -e "${CYAN}Usage:${RESET} nf [options]"
echo ""
echo -e "${GREEN}Options:${RESET}"
echo "  -h, --help              Show this help menu"
echo "  -d, --domain <domain>   Scan single domain"
echo "  -f, --file <file>       Scan multiple domains"
echo "  -o, --output <folder>   Output directory (default: ./output)"
echo "  -t, --templates <path>  Nuclei templates path"
echo "  -r, --rate <rate>       Rate limit (default: 50)"
echo "  -v, --verbose           Enable verbose output"
echo "  -k, --keep-temp         Keep temporary files"
echo "      --ai                Enable AI analysis"
echo ""
exit 0
}

# =========================
# 📦 BASE DIR DETECTION
# =========================

SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# =========================
# 🛑 MODULE CHECK
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
# 🧾 LOG FUNCTION
# =========================

log() {
    local level="$1"
    local message="$2"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"

    if [ "$VERBOSE" = true ] || [ "$level" = "ERROR" ]; then
        echo -e "${YELLOW}[$level]${RESET} $message"
    fi
}

# =========================
# ⚙️ DEFAULTS
# =========================

VERBOSE=false
KEEP_TEMP=false
AI_MODE=false

# =========================
# ⚙️ ARG PARSER
# =========================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help ;;
        -d|--domain) DOMAIN="$2"; shift 2 ;;
        -f|--file) FILENAME="$2"; shift 2 ;;
        -o|--output) OUTPUT_DIR="$2"; shift 2 ;;
        -t|--templates) TEMPLATE_DIR="$2"; shift 2 ;;
        -r|--rate) RATE_LIMIT="$2"; shift 2 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -k|--keep-temp) KEEP_TEMP=true; shift ;;
        --ai) AI_MODE=true; shift ;;
        *) echo "[ERROR] Unknown option: $1"; show_help ;;
    esac
done

# =========================
# 🚫 VALIDATION
# =========================

if [ -z "$DOMAIN" ] && [ -z "$FILENAME" ]; then
    show_help
fi

# =========================
# 🛠️ SETUP
# =========================

mkdir -p "$OUTPUT_DIR"

LOG_FILE="$OUTPUT_DIR/nucleifuzzer.log"
RAW_FILE="$OUTPUT_DIR/raw.txt"
VALIDATED_FILE="$OUTPUT_DIR/validated.txt"
JSON_FILE="$OUTPUT_DIR/results.json"
HTML_FILE="$OUTPUT_DIR/report.html"
AI_FILE="$OUTPUT_DIR/ai_analysis.txt"

> "$RAW_FILE"
> "$LOG_FILE"

show_banner
echo -e "${GREEN}[*] Starting Scan Engine...${RESET}"

# =========================
# 🚀 SINGLE DOMAIN
# =========================

if [ -n "$DOMAIN" ]; then
    recon "$DOMAIN" "$RAW_FILE"
    crawl "$DOMAIN" "$RAW_FILE"

# =========================
# 🚀 MULTI DOMAIN
# =========================

elif [ -n "$FILENAME" ]; then

    if [ ! -f "$FILENAME" ]; then
        log "ERROR" "File not found: $FILENAME"
        exit 1
    fi

    TOTAL=$(wc -l < "$FILENAME")
    COUNT=0

    while IFS= read -r domain; do
        ((COUNT++))
        echo -e "${CYAN}[*] [$COUNT/$TOTAL] Processing: $domain${RESET}"

        recon "$domain" "$RAW_FILE"
        crawl "$domain" "$RAW_FILE"

    done < "$FILENAME"
fi

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
# 🧹 CLEANUP
# =========================

if [ "$KEEP_TEMP" = false ]; then
    rm -f "$RAW_FILE" "$VALIDATED_FILE" "$VALIDATED_FILE.live" 2>/dev/null
fi

# =========================
# ✅ FINAL OUTPUT
# =========================

echo ""
echo "======================================"
echo -e "${GREEN}✅ Scan Completed Successfully${RESET}"
echo "📁 JSON Report : $JSON_FILE"
echo "🌐 HTML Report : $HTML_FILE"
[ "$AI_MODE" = true ] && echo "🧠 AI Report   : $AI_FILE"
echo "======================================"
