#!/bin/bash

# ANSI color codes
RED='\033[91m'
RESET='\033[0m'

# ASCII art
echo -e "${RED}"
cat << "EOF"
                     __     _ ____                         
   ____  __  _______/ /__  (_) __/_  __________  ___  _____
  / __ \/ / / / ___/ / _ \/ / /_/ / / /_  /_  / / _ \/ ___/
 / / / / /_/ / /__/ /  __/ / __/ /_/ / / /_/ /_/  __/ /    
/_/ /_/\__,_/\___/_/\___/_/_/  \__,_/ /___/___/\___/_/   v1.0.3

                               Made by Satya Prakash (0xKayala)
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

# Get the current user's home directory
home_dir=$(eval echo ~"$USER")

excluded_extentions="png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"

# Check if ParamSpider is already cloned and installed
if [ ! -d "$home_dir/ParamSpider" ]; then
    echo "Cloning ParamSpider..."
    git clone https://github.com/0xKayala/ParamSpider "$home_dir/ParamSpider"
fi

# Check if nuclei fuzzing-templates are already cloned.
if [ ! -d "$home_dir/nuclei-templates" ]; then
    echo "Cloning fuzzing-templates..."
    git clone https://github.com/projectdiscovery/nuclei-templates.git "$home_dir/nuclei-templates"
fi

# Check if nuclei is installed, if not, install it
if ! command -v nuclei -up &> /dev/null; then
    echo "Installing Nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
fi

# Check if httpx is installed, if not, install it
if ! command -v httpx -up &> /dev/null; then
    echo "Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
fi

if ! command -v uro -up &> /dev/null; then
    echo "Installing uro..."
    pip3 install uro
fi

# Parse command line arguments
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

# Step 1: Ask the user to enter the domain name or specify the file
if [ -z "$domain" ] && [ -z "$filename" ]; then
    echo "Please provide a domain with -d or a file with -f option."
    display_help
fi

# Combined output file for all domains
output_file="output/allurls.yaml"

# Step 2: Get the vulnerable parameters based on user input
if [ -n "$domain" ]; then
    echo "Running ParamSpider on $domain"
    python3 "$home_dir/ParamSpider/paramspider.py" -d "$domain" --exclude "$excluded_extentions" --level high --quiet -o "output/$domain.yaml"
elif [ -n "$filename" ]; then
    echo "Running ParamSpider on URLs from $filename"
    while IFS= read -r line; do
        python3 "$home_dir/ParamSpider/paramspider.py" -d "$line" --exclude "$excluded_extentions" --level high --quiet -o "output/${line}.yaml"
        cat "output/${line}.yaml" >> "$output_file"  # Append to the combined output file
    done < "$filename"
fi

# Step 3: Check whether URLs were collected or not
if [ -n "$domain" ] && [ ! -s "output/$domain.yaml" ]; then
    echo "No URLs found for the domain $domain. Exiting..."
    exit 1
elif [ -n "$filename" ] && [ ! -s "$output_file" ]; then
    echo "No URLs found in the file $filename. Exiting..."
    exit 1
fi

# Step 4: Run the Nuclei Fuzzing templates on the collected URLs
echo "Running Nuclei on collected URLs"
temp_file=$(mktemp)
if [ -n "$domain" ]; then
    # Use a temporary file to store the sorted and unique URLs
    sort "output/$domain.yaml" | uro > "$temp_file"
    httpx -silent -mc 200,301,302,403 -l "$temp_file" | nuclei -t "$home_dir/nuclei-templates" -dast -rl 05
elif [ -n "$filename" ]; then
    sort "$output_file" | uro > "$temp_file"
    httpx -silent -mc 200,301,302,403 -l "$temp_file" | nuclei -t "$home_dir/nuclei-templates" -dast -rl 05
fi
rm "$temp_file"  # Remove the temporary file

# Step 6: End with a general message as the scan is completed
echo "Scanning is completed - Happy Fuzzing"
