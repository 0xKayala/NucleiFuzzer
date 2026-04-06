#!/bin/bash

# ==========================================
# ⚙️ GLOBAL CONFIGURATION (PRO VERSION)
# ==========================================

# Output settings
OUTPUT_DIR="${OUTPUT_DIR:-./output}"
RATE_LIMIT="${RATE_LIMIT:-50}"

# Nuclei templates path
TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/nuclei-templates}"

# Home directory
HOME_DIR="$HOME"

# ==========================================
# 🎯 SMART URL FILTERING (HIGH SIGNAL)
# ==========================================

# 🚫 EXCLUDED EXTENSIONS (Noise Reduction)
# Goal: Remove static, binary, and non-attack-surface files

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

# ==========================================
# 🎯 HIGH VALUE ENDPOINT KEYWORDS (FOR FUTURE FILTERING)
# ==========================================

# These are NOT exclusions — used for prioritization later
HIGH_VALUE_KEYWORDS="\
api,auth,login,admin,user,account,\
token,session,redirect,callback,\
file,upload,download,search,\
id,query,debug,test"

# ==========================================
# 🎯 PARAMETER PATTERN (ATTACK SURFACE)
# ==========================================

# Used to identify dynamic endpoints
PARAM_PATTERN="=|\?|&"

# ==========================================
# 🎨 COLORS
# ==========================================

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
CYAN='\033[96m'
RESET='\033[0m'

# ==========================================
# 🌐 URL NORMALIZATION
# ==========================================

normalize_url() {
    local url="$1"

    if [[ "$url" != http* ]]; then
        url="http://$url"
    fi

    echo "$url"
}

# ==========================================
# 🧠 SMART FILTER FUNCTIONS (FUTURE-READY)
# ==========================================

# Extract parameterized URLs (high value)
filter_param_urls() {
    local input="$1"
    local output="$2"

    grep -aE "$PARAM_PATTERN" "$input" > "$output" 2>/dev/null
}

# Extract high-value endpoints (auth/api/admin/etc)
filter_high_value_urls() {
    local input="$1"
    local output="$2"

    grep -aEi "$(echo "$HIGH_VALUE_KEYWORDS" | tr ',' '|')" "$input" > "$output" 2>/dev/null
}

# Combine smart filtering (optional future use)
smart_filter_urls() {
    local input="$1"
    local output="$2"

    TEMP_FILE="$(mktemp)"

    # Step 1: Apply filtering safely
    grep -aEi "$PARAM_PATTERN|$(echo "$HIGH_VALUE_KEYWORDS" | tr ',' '|')" "$input" \
        | sort -u > "$TEMP_FILE" 2>/dev/null

    # Step 2: Fallback if empty
    if [ ! -s "$TEMP_FILE" ]; then
        echo "[WARN] Smart filter too aggressive → fallback to original URLs"
        cp "$input" "$TEMP_FILE"
    fi

    mv "$TEMP_FILE" "$output"
}

# ------------------------------------------
# ⚡ PERFORMANCE HELPERS
# ------------------------------------------

# Limit huge URL lists (prevents slow scans)
limit_urls() {
    local input="$1"
    local output="$2"
    local limit="${3:-1000}"

    head -n "$limit" "$input" > "$output"
}

# ==========================================
# 🛠️ ENVIRONMENT FIX (WSL + GO + PIPX)
# ==========================================

export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"

# ==========================================
# 📁 AUTO-CREATE OUTPUT DIRECTORY
# ==========================================

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR" 2>/dev/null
fi
