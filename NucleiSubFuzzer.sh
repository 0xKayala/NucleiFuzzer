#!/bin/bash

# ANSI color codes
RED='\033[91m'
RESET='\033[0m'

# ASCII art
echo -e "${RED}"
cat << "EOF"
    _   __           __     _ ____                         
   / | / /_  _______/ /__  (_) __/_  __________  ___  _____
  /  |/ / / / / ___/ / _ \/ / /_/ / / /_  /_  / / _ \/ ___/
 / /|  / /_/ / /__/ /  __/ / __/ /_/ / / /_/ /_/  __/ /    
/_/ |_/\__,_/\___/_/\___/_/_/  \__,_/ /___/___/\___/_/   v1.1.0

                               Made by 0xKayala and buddy4130
EOF
echo -e "${RESET}"

# Help menu
display_help() {
    echo -e "NucleiFuzzer is a Powerful Automation tool for detecting XSS, SQLi, SSRF, Open-Redirect, etc. vulnerabilities in Web Applications\n\n"
    echo -e "Usage: $0 [options]\n\n"
    echo "Options:"
    echo "  -h, --help              Display help information"
    echo "  -d, --domain <domain>   Single domain to scan for XSS, SQLi, SSRF, Open-Redirect, etc. vulnerabilities"
    echo "  -f, --file <filename>   File containing multiple domains/URLs to scan"
    exit 0
}

home_dir=$(eval echo ~"$USER")

excluded_extentions="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"

if [ ! -d "$home_dir/ParamSpider" ]; then
    echo "Cloning ParamSpider..."
    git clone https://github.com/0xKayala/ParamSpider "$home_dir/ParamSpider"
fi

if [ ! -d "$home_dir/nuclei-templates" ]; then
    echo "Cloning fuzzing-templates..."
    git clone https://github.com/0xKayala/nuclei-templates.git "$home_dir/nuclei-templates"
fi

if ! command -v nuclei &> /dev/null; then
    echo "Installing Nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
fi

if ! command -v httpx &> /dev/null; then
    echo "Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
fi

if ! command -v subfinder &> /dev/null; then
    echo "Installing subfinder..."
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
fi

while [[ $# -gt 0 ]]
do
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
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

if [ -z "$domain" ] && [ -z "$filename" ]; then
    echo "Please provide a domain with -d or a file with -f option."
    display_help
fi

output_file="output/allurls.yaml"

run_scans() {
    local target_domain="$1"
    local output_dir="output/$target_domain"
    mkdir -p "$output_dir"

    echo "Running ParamSpider on $target_domain"
    python3 "$home_dir/ParamSpider/paramspider.py" -d "$target_domain" --exclude "$excluded_extentions" --level high --quiet -o "$output_dir/urls.yaml"
    
    if [ ! -s "$output_dir/urls.yaml" ]; then
        echo "No URLs found for the domain $target_domain. Skipping..."
        return
    fi

    echo "Running Nuclei on collected URLs for $target_domain"
    temp_file=$(mktemp)
    sort "$output_dir/urls.yaml" | uniq > "$temp_file"
    httpx -silent -mc 200,301,302,403 -l "$temp_file" | nuclei -t "$home_dir/nuclei-templates" -dast -rl 05
    rm "$temp_file"  # Remove the temporary file
}

if [ -n "$domain" ]; then
    echo "Finding subdomains for $domain"
    subfinder -d "$domain" -silent -o "output/${domain}_subdomains.txt"
    while IFS= read -r subdomain; do
        run_scans "$subdomain"
    done < "output/${domain}_subdomains.txt"
elif [ -n "$filename" ]; then
    echo "Running ParamSpider on URLs from $filename"
    while IFS= read -r line; do
        echo "Finding subdomains for $line"
        subfinder -d "$line" -silent -o "output/${line}_subdomains.txt"
        while IFS= read -r subdomain; do
            run_scans "$subdomain"
        done < "output/${line}_subdomains.txt"
    done < "$filename"
fi

echo "Scanning is completed - Happy Fuzzing"
