#!/bin/bash

# ANSI color codes
RED='\033[91m'
GREEN='\033[92m'
RESET='\033[0m'

# ASCII art
echo -e "${RED}"
cat << "EOF"
                     __     _ ____                          
   ____  __  _______/ /__  (_) __/_  __________  ___  _____
  / __ \/ / / / ___/ / _ \/ / /_/ / / /_  /_  / / _ \/ ___/
 / / / / /_/ / /__/ /  __/ / __/ /_/ / / /_/ /_/  __/ /    
/_/ /_/\__,_/\___/_/\___/_/_/  \__,_/ /___/___/\___/_/   v2.1

                               Made by Satya Prakash (0xKayala)
EOF
echo -e "${RESET}"

# Help menu
display_help() {
    echo -e "NucleiFuzzer: A Powerful Automation Tool for Web Vulnerability Scanning\n"
    echo -e "Usage: $0 [options]\n"
    echo "Options:"
    echo "  -h, --help              Display help information"
    echo "  -d, --domain <domain>   Single domain to scan for vulnerabilities"
    echo "  -f, --file <filename>   File containing multiple domains/URLs to scan"
    echo "  -o, --output <folder>   Specify output folder for scan results (default: ./output)"
    exit 0
}

# Default output folder
output_folder="./output"

# Get the current user's home directory
home_dir=$(eval echo ~"$USER")

# Excluded extensions
excluded_extensions="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"

# Check prerequisites
check_prerequisite() {
    local tool=$1
    local install_command=$2
    if ! command -v "$tool" &> /dev/null; then
        echo "Installing $tool..."
        eval "$install_command"
    fi
}

check_prerequisite "nuclei" "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
check_prerequisite "httpx" "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
check_prerequisite "uro" "pip3 install uro"

# Clone repositories if not present
clone_repo() {
    local repo_url=$1
    local target_dir=$2
    if [ ! -d "$target_dir" ]; then
        echo "Cloning $repo_url..."
        git clone "$repo_url" "$target_dir"
    fi
}

clone_repo "https://github.com/0xKayala/ParamSpider" "$home_dir/ParamSpider"
clone_repo "https://github.com/projectdiscovery/nuclei-templates.git" "$home_dir/nuclei-templates"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            display_help
            ;;
        -d|--domain)
            domain="$2"
            shift
            shift
            ;;
        -f|--file)
            filename="$2"
            shift
            shift
            ;;
        -o|--output)
            output_folder="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Validate input
if [ -z "$domain" ] && [ -z "$filename" ]; then
    echo -e "${RED}Error: Please provide a domain (-d) or a file (-f).${RESET}"
    display_help
fi

# Ensure output folder exists
mkdir -p "$output_folder"

# Step 1: Run ParamSpider to collect URLs
run_paramspider() {
    local target=$1
    local output_file=$2
    echo -e "${GREEN}Running ParamSpider on $target...${RESET}"
    python3 "$home_dir/ParamSpider/paramspider.py" -d "$target" --exclude "$excluded_extensions" --level high --quiet -o "$output_file"
}

if [ -n "$domain" ]; then
    run_paramspider "$domain" "$output_folder/$domain.yaml"
elif [ -n "$filename" ]; then
    while IFS= read -r line; do
        run_paramspider "$line" "$output_folder/${line}.yaml"
        cat "$output_folder/${line}.yaml" >> "$output_folder/all_urls.yaml"
    done < "$filename"
fi

# Step 2: Validate collected URLs
validate_urls() {
    local input_file=$1
    local validated_file=$2
    if [ ! -s "$input_file" ]; then
        echo -e "${RED}Error: No URLs found in $input_file. Exiting...${RESET}"
        exit 1
    fi
    sort "$input_file" | uro > "$validated_file"
}

if [ -n "$domain" ]; then
    validate_urls "$output_folder/$domain.yaml" "$output_folder/${domain}_validated.yaml"
elif [ -n "$filename" ]; then
    validate_urls "$output_folder/all_urls.yaml" "$output_folder/all_validated.yaml"
fi

# Step 3: Run Nuclei templates
run_nuclei() {
    local url_file=$1
    echo -e "${GREEN}Running Nuclei on URLs from $url_file...${RESET}"
    httpx -silent -mc 200,301,302,403 -l "$url_file" | nuclei -t "$home_dir/nuclei-templates" -rl 05 -o "$output_folder/nuclei_results.txt"
}

if [ -n "$domain" ]; then
    run_nuclei "$output_folder/${domain}_validated.yaml"
elif [ -n "$filename" ]; then
    run_nuclei "$output_folder/all_validated.yaml"
fi

# Step 4: Completion message
echo -e "${GREEN}NucleiFuzzing is completed. Results are saved in $output_folder.${RESET}"
