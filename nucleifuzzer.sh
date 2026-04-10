#!/bin/bash

# ==========================================
# 🔥 NUCLEIFUZZER v3.3 - AI OFFENSIVE ENGINE
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
# 🎯 ASCII BANNER (UPGRADED)
# =========================
show_banner() {
echo -e "${RED}"
cat << "EOF"

███╗   ██╗██╗   ██╗ ██████╗██╗     ███████╗██╗███████╗██╗   ██╗███████╗███████╗███████╗██████╗ 
████╗  ██║██║   ██║██╔════╝██║     ██╔════╝██║██╔════╝██║   ██║╚══███╔╝╚══███╔╝██╔════╝██╔══██╗
██╔██╗ ██║██║   ██║██║     ██║     █████╗  ██║█████╗  ██║   ██║  ███╔╝   ███╔╝ █████╗  ██████╔╝
██║╚██╗██║██║   ██║██║     ██║     ██╔══╝  ██║██╔══╝  ██║   ██║ ███╔╝   ███╔╝  ██╔══╝  ██╔══██╗
██║ ╚████║╚██████╔╝╚██████╗███████╗███████╗██║██║     ╚██████╔╝███████╗███████╗███████╗██║  ██║
╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝╚═╝╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
                                                                                               
                                               ⚡ NucleiFuzzer v3.3 (AI + Plugins + Smart Recon)
                                                  Burp Suite CLI + AI Intelligence Engine

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
echo "  -d, --domain <domain>"
echo "  -f, --file <file>"
echo "  --ai          Enable AI analysis"
echo "  --fast        Fast scan"
echo "  --deep        Deep scan"
echo "  --doctor      Run diagnostics"
echo "  --update      Update tools"
echo ""
exit 0
}

# =========================
# 📦 BASE DIR
# =========================
SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(dirname "$SCRIPT_PATH")"
[[ "$BASE_DIR" == "/usr/bin" ]] && BASE_DIR="/opt/nucleifuzzer"

# =========================
# 🔌 LOAD MODULES
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
# 🔌 PLUGIN SYSTEM (IMPROVED)
# =========================
load_plugins() {
    PLUGIN_DIR="$BASE_DIR/plugins"
    if [ -d "$PLUGIN_DIR" ]; then
        for plugin in "$PLUGIN_DIR"/*.sh; do
            [ -f "$plugin" ] && source "$plugin"
        done
    fi
}

run_plugins() {
    local hook="$1"
    for fn in $(declare -F | awk '{print $3}' | grep "^plugin_${hook}"); do
        $fn
    done
}

load_plugins

# =========================
# ⚙️ FLAGS
# =========================
AI_MODE=false
FAST_MODE=false
DEEP_MODE=false
DOCTOR_MODE=false
UPDATE_MODE=false

# =========================
# ⚙️ ARG PARSER
# =========================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--domain) DOMAIN="$2"; shift 2 ;;
        -f|--file) FILENAME="$2"; shift 2 ;;
        --ai) AI_MODE=true; shift ;;
        --fast) FAST_MODE=true; shift ;;
        --deep) DEEP_MODE=true; shift ;;
        --doctor) DOCTOR_MODE=true; shift ;;
        --update) UPDATE_MODE=true; shift ;;
        *) show_help ;;
    esac
done

# =========================
# 🩺 MODES
# =========================
[ "$DOCTOR_MODE" = true ] && run_doctor && exit 0
[ "$UPDATE_MODE" = true ] && run_update && exit 0

# =========================
# 🚫 VALIDATION
# =========================
[ -z "$DOMAIN" ] && [ -z "$FILENAME" ] && show_help

# =========================
# 🔧 DEPENDENCIES
# =========================
setup_dependencies

# =========================
# 📁 OUTPUT
# =========================
mkdir -p "$OUTPUT_DIR"

RAW_FILE="$OUTPUT_DIR/raw.txt"
VALIDATED_FILE="$OUTPUT_DIR/validated.txt"
JSON_FILE="$OUTPUT_DIR/results.json"
HTML_FILE="$OUTPUT_DIR/report.html"
AI_FILE="$OUTPUT_DIR/ai.txt"

> "$RAW_FILE"

show_banner
echo -e "${GREEN}[*] Starting Scan Engine...${RESET}"

# =========================
# 🔎 RECON + CRAWL
# =========================
if [ -n "$DOMAIN" ]; then
    recon "$DOMAIN" "$RAW_FILE"
    crawl "$DOMAIN" "$RAW_FILE"
else
    while read -r domain; do
        recon "$domain" "$RAW_FILE"
        crawl "$domain" "$RAW_FILE"
    done < "$FILENAME"
fi

# =========================
# 🧠 AI URL FILTER (UPGRADED)
# =========================
if [ "$AI_MODE" = true ]; then
    echo "[*] AI-powered URL prioritization..."

    if command -v gemini &>/dev/null; then
        gemini "
Analyze these URLs and return ONLY high-value security endpoints:
- APIs
- auth/login/admin
- parameters
- sensitive paths
Remove noise like static files.

Return only URLs.
" < "$RAW_FILE" \
        | grep -aE '^https?://' > "$RAW_FILE.ai"
    fi

    [ -s "$RAW_FILE.ai" ] && mv "$RAW_FILE.ai" "$RAW_FILE"
fi

# =========================
# 🔍 VALIDATION
# =========================
validate_urls "$RAW_FILE" "$VALIDATED_FILE"

# =========================
# 🌐 SUBPIPE (DNS INTEL)
# =========================
if command -v subpipe &>/dev/null && [ -n "$SUBPIPE_API_KEY" ]; then
    echo "[*] Running SubPipe DNS analysis..."
    cat "$VALIDATED_FILE" | subpipe
fi

# =========================
# ⚡ SCAN
# =========================
run_nuclei "$VALIDATED_FILE" "$JSON_FILE" "$FAST_MODE" "$DEEP_MODE"

# =========================
# 📊 REPORT
# =========================
group_by_severity "$JSON_FILE"
generate_html_report "$JSON_FILE" "$HTML_FILE"

# =========================
# 🧠 AI ANALYSIS
# =========================
[ "$AI_MODE" = true ] && run_ai_analysis "$JSON_FILE" "$AI_FILE"

# =========================
# 🔌 POST-SCAN PLUGINS
# =========================
export JSON_FILE
run_plugins "post_scan"

# =========================
# ✅ DONE
# =========================
echo ""
echo "======================================"
echo -e "${GREEN}✅ Scan Completed${RESET}"
echo "📁 JSON : $JSON_FILE"
echo "🌐 HTML : $HTML_FILE"
[ "$AI_MODE" = true ] && echo "🧠 AI   : $AI_FILE"
echo "======================================"
