#!/bin/bash

# ==========================================
# 🔥 NucleiFuzzer v3.0 - AI Powered Scanner
# Author: Satya Prakash (0xKayala)
# ==========================================

# =========================
# 🎨 COLORS
# =========================
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
CYAN='\033[96m'
RESET='\033[0m'

# =========================
# 🎯 BANNER
# =========================
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
echo "  -h, --help              Show help"
echo "  -d, --domain <domain>   Scan single domain"
echo "  -f, --file <file>       Scan multiple domains"
echo "  -o, --output <folder>   Output directory"
echo "  -t, --templates <path>  Nuclei templates path"
echo "  -r, --rate <rate>       Rate limit (default: 50)"
echo "  -v, --verbose           Verbose mode"
echo "  -k, --keep-temp         Keep temp files"
echo "      --ai                Enable AI analysis"
echo "      --doctor            Run diagnostics"
echo "      --update            Smart update engine"
echo "      --fast              Fast scan mode"
echo "      --deep              Deep scan mode"
echo ""
exit 0
}

# =========================
# 📦 BASE DIR RESOLUTION (CRITICAL FIX)
# =========================
SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(dirname "$SCRIPT_PATH")"

# If installed globally → use /opt
if [[ "$BASE_DIR" == "/usr/bin" ]]; then
    BASE_DIR="/opt/nucleifuzzer"
fi

# =========================
# 🛑 MODULE CHECK
# =========================
if [ ! -d "$BASE_DIR/core" ]; then
    echo "[ERROR] Core modules not found at $BASE_DIR"
    echo "[FIX] Reinstall tool using install.sh"
    exit 1
fi

# =========================
# ⚙️ DEFAULT FLAGS
# =========================
VERBOSE=false
KEEP_TEMP=false
AI_MODE=false
DOCTOR_MODE=false
UPDATE_MODE=false
FAST_MODE=false
DEEP_MODE=false

# =========================
# 🧾 LOG FUNCTION
# =========================
log() {
    local level="$1"
    local message="$2"

    [ -z "$LOG_FILE" ] && LOG_FILE="/tmp/nf.log"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"

    if [ "$VERBOSE" = true ] || [ "$level" = "ERROR" ]; then
        echo -e "${YELLOW}[$level]${RESET} $message"
    fi
}

# =========================
# 📦 LOAD MODULES
# =========================
source "$BASE_DIR/config/config.sh"
source "$BASE_DIR/core/deps.sh"
source "$BASE_DIR/core/doctor.sh"
source "$BASE_DIR/core/update.sh"
source "$BASE_DIR/core/recon.sh"
source "$BASE_DIR/core/crawling.sh"
source "$BASE_DIR/core/scanning.sh"
source "$BASE_DIR/core/reporting.sh"
source "$BASE_DIR/core/ai.sh"

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
        --doctor) DOCTOR_MODE=true; shift ;;
        --update) UPDATE_MODE=true; shift ;;
        --fast) FAST_MODE=true; shift ;;
        --deep) DEEP_MODE=true; shift ;;
        *) echo "[ERROR] Unknown option: $1"; show_help ;;
    esac
done

# =========================
# 🩺 DOCTOR MODE
# =========================
if [ "$DOCTOR_MODE" = true ]; then
    show_banner
    run_doctor
    exit 0
fi

# =========================
# ⬆️ UPDATE MODE
# =========================
if [ "$UPDATE_MODE" = true ]; then
    show_banner
    run_update
    exit 0
fi

# =========================
# 🚫 INPUT VALIDATION
# =========================
if [ -z "$DOMAIN" ] && [ -z "$FILENAME" ]; then
    show_help
fi

# =========================
# 🔧 DEPENDENCIES CHECK
# =========================
setup_dependencies

# =========================
# 📁 OUTPUT SETUP
# =========================
OUTPUT_DIR="${OUTPUT_DIR:-./output}"
mkdir -p "$OUTPUT_DIR"

LOG_FILE="$OUTPUT_DIR/nf.log"
RAW_FILE="$OUTPUT_DIR/raw.txt"
VALIDATED_FILE="$OUTPUT_DIR/validated.txt"
JSON_FILE="$OUTPUT_DIR/results.json"
HTML_FILE="$OUTPUT_DIR/report.html"
AI_FILE="$OUTPUT_DIR/ai.txt"

touch "$LOG_FILE"
> "$RAW_FILE"

# =========================
# 🚀 START
# =========================
show_banner
echo -e "${GREEN}[*] Starting Scan Engine...${RESET}"

# =========================
# 🔎 RECON + CRAWL
# =========================
if [ -n "$DOMAIN" ]; then
    recon "$DOMAIN" "$RAW_FILE"
    crawl "$DOMAIN" "$RAW_FILE"

elif [ -n "$FILENAME" ]; then
    while IFS= read -r domain; do
        echo -e "${CYAN}[*] Processing: $domain${RESET}"
        recon "$domain" "$RAW_FILE"
        crawl "$domain" "$RAW_FILE"
    done < "$FILENAME"
fi

# =========================
# 🔍 VALIDATION
# =========================
validate_urls "$RAW_FILE" "$VALIDATED_FILE"

# =========================
# ⚡ SCANNING (MODE-AWARE)
# =========================
run_nuclei "$VALIDATED_FILE" "$JSON_FILE" "$FAST_MODE" "$DEEP_MODE"

# =========================
# 📊 REPORTING
# =========================
if [ -s "$JSON_FILE" ]; then
    group_by_severity "$JSON_FILE"
    generate_html_report "$JSON_FILE" "$HTML_FILE"
else
    echo "[WARN] No JSON results to process"
fi

# =========================
# 🧠 AI ANALYSIS
# =========================
if [ "$AI_MODE" = true ] && [ -s "$JSON_FILE" ]; then
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
