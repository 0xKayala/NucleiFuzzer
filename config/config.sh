#!/bin/bash

# ==========================================
# ⚙️ GLOBAL CONFIGURATION
# ==========================================

OUTPUT_DIR="${OUTPUT_DIR:-./output}"
RATE_LIMIT="${RATE_LIMIT:-50}"
TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/nuclei-templates}"
HOME_DIR="$HOME"

EXCLUDED_EXTENSIONS="png,jpg,jpeg,gif,svg,css,js,woff,woff2,ttf,mp4,pdf"

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

# Ensure PATH (WSL FIX)
export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"
