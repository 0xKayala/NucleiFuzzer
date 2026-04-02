#!/bin/bash

# =========================
# 🎨 COLORS & BANNER
# =========================

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
RESET='\033[0m'

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

# =========================
# 📦 LOAD MODULES
# =========================

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

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
    echo -e "NucleiFuzzer v3 - AI Powered Web Scanner\n"
    echo "Usage: nf [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show help"
    echo "  -d, --domain <domain>   Scan single domain"
    echo "  -f, --file <file>       Scan multiple domains"
    echo "  -o, --output <folder>   Output folder"
    echo "  -t, --templates <path>  Nuclei templates path"
    echo "  -r, --rate <rate>       Rate limit (default: 50)"
    echo "  -v, --verbose           Verbose mode"
    echo "  -k, --keep-temp         Keep temp files"
    echo "      --ai                Enable AI analysis"
    exit 0
}

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
# ⚙️ ARGUMENT PARSER
# =========================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) display_help ;;
        -d|--domain) DOMAIN="$2"; shift 2 ;;
        -f|--file) FILENAME="$2"; shift 2 ;;
        -o|--output) OUTPUT_FOLDER="$2"; shift 2 ;;
        -t|--templates) TEMPLATE_DIR="$2"; shift 2 ;;
        -r|--rate) RATE_LIMIT="$2"; shift 2 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -k|--keep-temp) KEEP_TEMP=true; shift ;;
        --ai) AI_MODE=true; shift ;;
        *) log "ERROR" "Unknown option: $1"; display_help ;;
    esac
done

# =========================
# 🚫 INPUT VALIDATION
# =========================

if [ -z "$DOMAIN" ] && [ -z "$FILENAME" ]; then
    log "ERROR" "Provide -d (domain) or -f (file)"
    display_help
fi

# =========================
# 🛠️ SETUP
# =========================

mkdir -p "$OUTPUT_FOLDER"
echo "" > "$LOG_FILE"

TEMPLATE_DIR=${TEMPLATE_DIR:-"$HOME_DIR/nuclei-templates"}

RAW_FILE="$OUTPUT_FOLDER/raw.txt"
VALIDATED_FILE="$OUTPUT_FOLDER/validated.txt"
JSON_FILE="$OUTPUT_FOLDER/results.json"
HTML_FILE="$OUTPUT_FOLDER/report.html"

echo "" > "$RAW_FILE"

# =========================
# 🔧 DEPENDENCY CHECK
# =========================

check_prerequisite() {
    local tool="$1"
    local install_cmd="$2"

    if ! command -v "$tool" &> /dev/null; then
        log "INFO" "Installing $tool..."
        eval "$install_cmd"
    fi
}

check_prerequisite "jq" "sudo apt install -y jq"
check_prerequisite "httpx" "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
check_prerequisite "nuclei" "go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"

# =========================
# 🚀 MAIN ENGINE
# =========================

echo -e "${GREEN}[*] Starting Scan Engine...${RESET}"

# SINGLE DOMAIN
if [ -n "$DOMAIN" ]; then
    collect_urls "$DOMAIN" "$RAW_FILE"
    crawl_urls "$DOMAIN" "$RAW_FILE"

# MULTI DOMAIN
elif [ -n "$FILENAME" ]; then

    if [ ! -f "$FILENAME" ]; then
        log "ERROR" "File not found: $FILENAME"
        exit 1
    fi

    TOTAL=$(wc -l < "$FILENAME")
    COUNT=0

    while IFS= read -r domain; do
        ((COUNT++))
        echo -e "${YELLOW}[*] [$COUNT/$TOTAL] Processing: $domain${RESET}"

        collect_urls "$domain" "$RAW_FILE"
        crawl_urls "$domain" "$RAW_FILE"

    done < "$FILENAME"
fi

# =========================
# 🔍 VALIDATION
# =========================

validate_urls "$RAW_FILE" "$VALIDATED_FILE"

# =========================
# ⚡ SCANNING
# =========================

run_nuclei "$VALIDATED_FILE"

# =========================
# 📊 REPORTING
# =========================

group_by_severity
generate_html_report

# =========================
# 🧠 AI ANALYSIS
# =========================

if [ "$AI_MODE" = true ]; then
    run_ai_analysis
fi

# =========================
# 🧹 CLEANUP
# =========================

if [ "$KEEP_TEMP" = false ]; then
    rm -f "$RAW_FILE" "$VALIDATED_FILE"
fi

# =========================
# ✅ FINAL OUTPUT
# =========================

echo ""
echo "======================================"
echo -e "${GREEN}✅ Scan Completed Successfully${RESET}"
echo "📁 JSON Report : $JSON_FILE"
echo "🌐 HTML Report : $HTML_FILE"

if [ "$AI_MODE" = true ]; then
    echo "🧠 AI Report   : $OUTPUT_FOLDER/ai_analysis.txt"
fi

echo "======================================"
