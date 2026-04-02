#!/bin/bash

# ANSI color codes
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
RESET='\033[0m'

# ASCII art
echo -e "${RED}"
cat << "EOF"
                           __     _ ____                          
         ____  __  _______/ /__  (_) __/_  __________  ___  _____
        / __ \/ / / / ___/ / _ \/ / /_/ / / /_  /_  / / _ \/ ___/
       / / / / /_/ / /__/ /  __/ / __/ /_/ / / /_/ /_/  __/ /    
      /_/ /_/\__,_/\___/_/\___/_/_/  \__,_/ /___/___/\___/_/   v2.5.1
      
                                     Made by Satya Prakash (0xKayala)
EOF
echo -e "${RESET}"

# Default settings
OUTPUT_FOLDER="./output"
HOME_DIR=$(eval echo ~"$USER")
EXCLUDED_EXTENSIONS="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"
LOG_FILE="$OUTPUT_FOLDER/nucleifuzzer.log"
VERBOSE=false
KEEP_TEMP=false
RATE_LIMIT=50
RESULT_FILE=""

# Help menu
display_help() {
    echo -e "NucleiFuzzer: A Powerful Automation Tool for Web Vulnerability Scanning\n"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help              Display this help menu"
    echo "  -d, --domain <domain>   Scan a single domain"
    echo "  -f, --file <filename>   Scan multiple domains/URLs from a file"
    echo "  -o, --output <folder>   Output folder (default: ./output)"
    echo "  -t, --templates <path>  Custom Nuclei templates directory"
    echo "  -v, --verbose           Enable verbose output (logs to terminal)"
    echo "  -k, --keep-temp         Keep temporary files after execution"
    echo "  -r, --rate <limit>      Set rate limit for Nuclei (default: 50)"
    exit 0
}

# Log function
log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
    if [ "$VERBOSE" = true ] || [ "$level" = "ERROR" ]; then
        echo -e "${YELLOW}[$level]${RESET} $message"
    fi
}

# Check prerequisites
check_prerequisite() {
    local tool="$1"
    local install_command="$2"
    if ! command -v "$tool" &> /dev/null; then
        log "INFO" "Installing $tool..."
        if ! eval "$install_command"; then
            log "ERROR" "Failed to install $tool. Exiting."
            exit 1
        fi
        if [ "$tool" = "uro" ] && [ -f "$HOME/.local/bin/uro" ]; then
            export PATH="$HOME/.local/bin:$PATH"
            log "INFO" "Added $HOME/.local/bin to PATH."
        fi
    fi
}

# Check Python module
check_python_module() {
    local module="$1"
    if ! python3 -c "import $module" &>/dev/null; then
        log "INFO" "Installing Python module: $module"
        pip3 install --break-system-packages "$module" || log "ERROR" "Failed to install $module"
    fi
}

# Clone repositories
clone_repo() {
    local repo_url="$1"
    local target_dir="$2"
    if [ ! -d "$target_dir" ]; then
        log "INFO" "Cloning $repo_url to $target_dir..."
        if ! git clone "$repo_url" "$target_dir"; then
            log "ERROR" "Failed to clone $repo_url. Exiting."
            exit 1
        fi
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) display_help ;;
        -d|--domain) DOMAIN="$2"; shift 2 ;;
        -f|--file) FILENAME="$2"; shift 2 ;;
        -o|--output) OUTPUT_FOLDER="$2"; shift 2 ;;
        -t|--templates) TEMPLATE_DIR="$2"; shift 2 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -k|--keep-temp) KEEP_TEMP=true; shift ;;
        -r|--rate) RATE_LIMIT="$2"; shift 2 ;;
        *) log "ERROR" "Unknown option: $1"; display_help ;;
    esac
done

# Validate input
if [ -z "$DOMAIN" ] && [ -z "$FILENAME" ]; then
    log "ERROR" "Please provide a domain (-d) or file (-f)."
    display_help
fi

# Setup
mkdir -p "$OUTPUT_FOLDER"
echo "" > "$LOG_FILE"
TEMPLATE_DIR=${TEMPLATE_DIR:-"$HOME_DIR/nuclei-templates"}

# Suggest venv usage
if [[ "$VIRTUAL_ENV" == "" ]]; then
    log "WARNING" "You are not using a Python virtual environment. It is recommended."
fi

# Ensure Go bin path is in PATH
if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
    export PATH="$HOME/go/bin:$PATH"
    log "INFO" "Added $HOME/go/bin to PATH."
fi

# Dependency installation
check_prerequisite "python3" "sudo apt install -y python3"
check_prerequisite "pip3" "sudo apt install -y python3-pip"
check_python_module "requests"
check_python_module "urllib3"
check_prerequisite "nuclei" "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
check_prerequisite "httpx" "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
check_prerequisite "uro" "pip3 install --break-system-packages uro"
check_prerequisite "katana" "go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
check_prerequisite "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
check_prerequisite "gauplus" "go install github.com/bp0lr/gauplus@latest"
check_prerequisite "hakrawler" "go install github.com/hakluke/hakrawler@latest"
clone_repo "https://github.com/0xKayala/ParamSpider" "$HOME_DIR/ParamSpider"
clone_repo "https://github.com/projectdiscovery/nuclei-templates.git" "$HOME_DIR/nuclei-templates"

# Validate input format
validate_input() {
    local input="$1"
    if [[ "$input" =~ ^https?://[a-zA-Z0-9.-]+(/.*)?$ ]]; then
        echo "$input"
    elif [[ "$input" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo "http://$input"
    else
        log "ERROR" "Invalid input: $input"
        return 1
    fi
}

# URL collection
collect_urls() {
    local target="$1"
    local output_file="$2"
    local validated_target=$(validate_input "$target") || return 1

    log "INFO" "Starting URL collection for $validated_target..."

    echo -e "${GREEN}Collecting URLs for $validated_target...${RESET} using ParamSpider"
    python3 "$HOME_DIR/ParamSpider/paramspider.py" -d "$target" --exclude "$EXCLUDED_EXTENSIONS" --level high --quiet -o "$output_file.tmp" &&
    cat "$output_file.tmp" >> "$output_file" && rm -f "$output_file.tmp"

    echo -e "${GREEN}Collecting URLs for $validated_target...${RESET} using Waybackurls"
    echo "$validated_target" | waybackurls >> "$output_file"

    echo -e "${GREEN}Collecting URLs for $validated_target...${RESET} using Gauplus"
    echo "$validated_target" | gauplus -subs -b "$EXCLUDED_EXTENSIONS" >> "$output_file"

    echo -e "${GREEN}Collecting URLs for $validated_target...${RESET} using Hakrawler"
    echo "$validated_target" | hakrawler -d 3 -subs -u >> "$output_file"

    echo -e "${GREEN}Collecting URLs for $validated_target...${RESET} using Katana"
    echo "$validated_target" | katana -d 3 -silent -rl 10 >> "$output_file"
}

# Validate & deduplicate URLs
validate_urls() {
    local input_file="$1"
    local output_file="$2"
    if [ ! -s "$input_file" ]; then
        log "ERROR" "No URLs found in $input_file."
        exit 1
    fi
    echo -e "${GREEN}Deduplicating URLs from $input_file...${RESET}"
    sort -u "$input_file" | uro > "$output_file"
}

# Run nuclei
run_nuclei() {
    local url_file="$1"
    echo -e "${GREEN}Running Nuclei on URLs from $url_file...${RESET}"
    httpx -silent -mc 200,204,301,302,401,403,405,500,502,503,504 -l "$url_file" |
        nuclei -t "$TEMPLATE_DIR" -dast -rl "$RATE_LIMIT" -o "$RESULT_FILE"
}

# Main logic
if [ -n "$DOMAIN" ]; then
    DOMAIN_RAW="${DOMAIN//[^a-zA-Z0-9.-]/_}"
    RAW_FILE="$OUTPUT_FOLDER/${DOMAIN_RAW}_raw.txt"
    VALIDATED_FILE="$OUTPUT_FOLDER/${DOMAIN_RAW}_validated.txt"
    RESULT_FILE="$OUTPUT_FOLDER/${DOMAIN_RAW}_nuclei_results.txt"
    collect_urls "$DOMAIN" "$RAW_FILE"
    validate_urls "$RAW_FILE" "$VALIDATED_FILE"
    run_nuclei "$VALIDATED_FILE"
elif [ -n "$FILENAME" ]; then
    if [ ! -f "$FILENAME" ]; then
        log "ERROR" "File $FILENAME not found."
        exit 1
    fi
    TOTAL_LINES=$(wc -l < "$FILENAME")
    COUNT=0
    RAW_FILE="$OUTPUT_FOLDER/all_raw.txt"
    VALIDATED_FILE="$OUTPUT_FOLDER/all_validated.txt"
    RESULT_FILE="$OUTPUT_FOLDER/all_nuclei_results.txt"
    echo "" > "$RAW_FILE"
    while IFS= read -r line; do
        ((COUNT++))
        echo -e "${YELLOW}[Progress]${RESET} Processing $COUNT/$TOTAL_LINES: $line"
        collect_urls "$line" "$RAW_FILE"
    done < "$FILENAME"
    validate_urls "$RAW_FILE" "$VALIDATED_FILE"
    run_nuclei "$VALIDATED_FILE"
fi

# Cleanup
if [ "$KEEP_TEMP" = false ]; then
    log "INFO" "Cleaning up temporary files..."
    rm -f "$OUTPUT_FOLDER"/*_raw.txt "$OUTPUT_FOLDER"/*_validated.txt 2>/dev/null
fi

log "INFO" "Scanning completed. Results saved in $RESULT_FILE."
echo -e "${RED}NucleiFuzzing is completed! Check $RESULT_FILE for results.${RESET}"
