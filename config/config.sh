#!/bin/bash

# Default config

OUTPUT_DIR="./output"
RATE_LIMIT=50
TEMPLATE_DIR="$HOME/nuclei-templates"
EXCLUDED_EXTENSIONS="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff2,eot,ttf,otf,mp4,txt"

# Colors
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
RESET='\033[0m'

# Normalize URL
normalize_url() {
    local url="$1"
    if [[ "$url" != http* ]]; then
        url="http://$url"
    fi
    echo "$url"
}
