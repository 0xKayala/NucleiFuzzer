#!/bin/bash

# Default configuration

OUTPUT_FOLDER="./output"
HOME_DIR=$(eval echo ~"$USER")

EXCLUDED_EXTENSIONS="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff2,eot,ttf,otf,mp4,txt"

LOG_FILE="$OUTPUT_FOLDER/nucleifuzzer.log"

RATE_LIMIT=50
AI_MODE=false
VERBOSE=false
KEEP_TEMP=false

TEMPLATE_DIR="$HOME_DIR/nuclei-templates"

# Output files
RAW_FILE=""
VALIDATED_FILE=""
JSON_FILE=""
HTML_FILE=""
RESULT_FILE=""
