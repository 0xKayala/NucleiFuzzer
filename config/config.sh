#!/bin/bash

# ==========================================
# ⚙️ GLOBAL CONFIGURATION (PRO v3.3)
# ==========================================

# ------------------------------------------
# 📁 OUTPUT SETTINGS
# ------------------------------------------

OUTPUT_DIR="${OUTPUT_DIR:-./output}"
RATE_LIMIT="${RATE_LIMIT:-50}"

# ------------------------------------------
# 📦 NUCLEI CONFIG
# ------------------------------------------

TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/nuclei-templates}"

# ------------------------------------------
# 🏠 SYSTEM PATHS
# ------------------------------------------

HOME_DIR="$HOME"
BASE_DIR="${BASE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# ------------------------------------------
# 🔌 PLUGIN SYSTEM CONFIG (NEW)
# ------------------------------------------

PLUGIN_DIR="$BASE_DIR/plugins"

# Enable/Disable plugins (space-separated)
ENABLED_PLUGINS="${ENABLED_PLUGINS:-subpipe ai_filter js_analyzer}"

# ------------------------------------------
# 🌐 DNS INTEL CONFIG
# ------------------------------------------

SUBPIPE_API_KEY="${SUBPIPE_API_KEY:-}"

# ------------------------------------------
# 🤖 AI CONFIG (NEW)
# ------------------------------------------

# AI Providers (optional)
OPENAI_API_KEY="${OPENAI_API_KEY:-}"
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
CLAUDE_API_KEY="${CLAUDE_API_KEY:-}"

# AI Mode
AI_MODE="${AI_MODE:-smart}"   # smart | aggressive | off

# ------------------------------------------
# ⚡ SCAN MODE CONFIG
# ------------------------------------------

DEFAULT_MODE="${DEFAULT_MODE:-auto}"   # auto | fast | deep

FAST_RATE=200
FAST_CONCURRENCY=80

DEEP_RATE="${RATE_LIMIT}"
DEEP_CONCURRENCY=50

# ------------------------------------------
# 🎯 SMART URL FILTERING (HIGH SIGNAL)
# ------------------------------------------

EXCLUDED_EXTENSIONS="\
png,jpg,jpeg,gif,svg,webp,ico,\
css,js,map,\
woff,woff2,eot,ttf,otf,\
mp4,mp3,avi,mov,wmv,flv,mkv,\
pdf,doc,docx,xls,xlsx,ppt,pptx,\
zip,rar,7z,tar,gz,iso,\
exe,bin,dll,deb,rpm,\
txt,log,\
apk,ipa,\
swf"

# ------------------------------------------
# 🎯 HIGH VALUE ENDPOINT KEYWORDS
# ------------------------------------------

HIGH_VALUE_KEYWORDS="\
api,auth,login,admin,user,account,\
token,session,redirect,callback,\
file,upload,download,search,\
id,query,debug,test"

# ------------------------------------------
# 🎯 PARAMETER PATTERN
# ------------------------------------------

PARAM_PATTERN="=|\?|&"

# ------------------------------------------
# 🎨 COLORS
# ------------------------------------------

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
CYAN='\033[96m'
RESET='\033[0m'

# ------------------------------------------
# 🌐 URL NORMALIZATION
# ------------------------------------------

normalize_url() {
    local url="$1"

    if [[ "$url" != http* ]]; then
        url="http://$url"
    fi

    echo "$url"
}

# ------------------------------------------
# 🧠 SMART FILTER FUNCTIONS
# ------------------------------------------

filter_param_urls() {
    local input="$1"
    local output="$2"

    grep -aE "$PARAM_PATTERN" "$input" > "$output" 2>/dev/null
}

filter_high_value_urls() {
    local input="$1"
    local output="$2"

    grep -aEi "$(echo "$HIGH_VALUE_KEYWORDS" | tr ',' '|')" "$input" > "$output" 2>/dev/null
}

smart_filter_urls() {
    local input="$1"
    local output="$2"

    TEMP_FILE="$(mktemp)"

    grep -aEi "$PARAM_PATTERN|$(echo "$HIGH_VALUE_KEYWORDS" | tr ',' '|')" "$input" \
        | sort -u > "$TEMP_FILE" 2>/dev/null

    if [ ! -s "$TEMP_FILE" ]; then
        echo "[WARN] Smart filter too aggressive → fallback to original URLs"
        cp "$input" "$TEMP_FILE"
    fi

    mv "$TEMP_FILE" "$output"
}

# ------------------------------------------
# 🧠 AI FILTER WRAPPER (NEW)
# ------------------------------------------

ai_filter_urls() {
    local input="$1"
    local output="$2"

    # If AI disabled → fallback
    if [ "$AI_MODE" = "off" ]; then
        cp "$input" "$output"
        return
    fi

    # If Gemini CLI exists → use it
    if command -v gemini &>/dev/null && [ -n "$GEMINI_API_KEY" ]; then
        echo "[AI] Using Gemini for URL filtering..."

        gemini "Analyze URLs from $input and return only high-risk endpoints (params, auth, api)" \
            < "$input" > "$output" 2>/dev/null

    else
        # Fallback to smart filter
        smart_filter_urls "$input" "$output"
    fi
}

# ------------------------------------------
# ⚡ PERFORMANCE HELPERS
# ------------------------------------------

limit_urls() {
    local input="$1"
    local output="$2"
    local limit="${3:-1000}"

    head -n "$limit" "$input" > "$output"
}

# ------------------------------------------
# 🛠️ ENVIRONMENT FIX (WSL + GO)
# ------------------------------------------

export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"

# ------------------------------------------
# 📁 AUTO-CREATE OUTPUT DIRECTORY
# ------------------------------------------

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR" 2>/dev/null
fi
