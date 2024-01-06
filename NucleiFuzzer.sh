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
/_/ /_/\__,_/\___/_/\___/_/_/  \__,_/ /___/___/\___/_/   v1.0.2

                               Made by Satya Prakash (0xKayala)
EOF
echo -e "${RESET}"

# Help menu
display_help() {
    cat <<EOF

NucleiFuzzer is a Powerful Automation tool for detecting vulnerabilities in Web Applications

Usage: $0 [options]

Options:
  -h, --help              Display help information
  -d, --domain <domain>   Single domain to scan for vulnerabilities
  -f, --file <filename>   File containing multiple domains/URLs to scan

EOF
    exit 0
}

# Get the current user's home directory
home_dir=$(eval echo ~$USER)

# Function to clone a repository if not already cloned
clone_repo() {
    local repo_url=$1
    local repo_dir=$2
    if [ ! -d "$home_dir/$repo_dir" ]; then
        echo "Cloning $repo_dir..."
        git clone "$repo_url" "$home_dir/$repo_dir"
    fi
}

# Clone required repositories
clone_repo "https://github.com/0xKayala/ParamSpider" "ParamSpider"
clone_repo "https://github.com/0xKayala/fuzzing-templates.git" "fuzzing-templates"

# Function to install a tool if not already installed
install_tool() {
    local tool_name=$1
    if ! command -v $tool_name &> /dev/null; then
        echo "Installing $tool_name..."
        go install -v "github.com/projectdiscovery/$tool_name/v3/cmd/$tool_name@latest"
    fi
}

# Install required tools
install_tool "nuclei"
install_tool "httpx"

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
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Step 2: Ask the user to enter the domain name or specify the file
if [ -z "$domain" ] && [ -z "$filename" ]; then
    echo "Please provide a domain with -d or a file with -f option."
    display_help
fi

# Combined output file for all domains
output_file="output/allurls.txt"


# Step 3: Get the vulnerable parameters based on user input
run_paramspider() {
    local input=$1
    local output=$2
    python3 "$home_dir/ParamSpider/paramspider.py" -d "$input" --exclude png,jpg,gif,jpeg,swf,woff,gif,svg --level high --quiet -o "$output"
}


if [ -n "$domain" ]; then
    echo "Running ParamSpider on $domain"
    run_paramspider "$domain" "output/$domain.txt"
elif [ -n "$filename" ]; then
    echo "Running ParamSpider on URLs from $filename"
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ]; then
            run_paramspider "$line" "output/$line.txt"
            cat "output/$line.txt" >> "$output_file"
        fi
    done < "$filename"
fi

# Step 4: Check whether URLs were collected or not
if [ ! -s "output/$domain.txt" ] && [ ! -s "$output_file" ]; then
    echo "No URLs Found. Exiting..."
    exit 1
fi

# Step 5: Run the Nuclei Fuzzing templates on the collected URLs
echo "Running Nuclei on collected URLs"
if [ -n "$domain" ]; then
    sort "output/$domain.txt" | uniq | tee "output/$domain.txt" | httpx -silent -mc 200,301,302 | nuclei -t "$home_dir/fuzzing-templates" -rl 05
elif [ -n "$filename" ]; then
    sort "$output_file" | uniq | tee "$output_file" | httpx -silent -mc 200,301,302 | nuclei -t "$home_dir/fuzzing-templates" -rl 05
fi

# Step 6: End with a general message as the scan is completed
echo "Scan is completed - Happy Fuzzing"

