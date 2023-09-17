#!/bin/bash

# ASCII art
printf "\e[91m
    _   __           __     _ ______
   / | / /_  _______/ /__  (_) ____/_  __________  ___  _____
  /  |/ / / / / ___/ / _ \/ / /_  / / / /_  /_  / / _ \/ ___/
 / /|  / /_/ / /__/ /  __/ / __/ / /_/ / / /_/ /_/  __/ /
/_/ |_/\__,_/\___/_/\___/_/_/    \__,_/ /___/___/\___/_/

                               Made by Satya Prakash (0xKayala)
\e[0m"

# Help menu
display_help() {
    echo -e "NucleiFuzzer is a Powerful Automation tool for detecting XSS, SQLi, SSRF, Open-Redirect, etc. vulnerabilities in Web Applications\n\n"
    echo -e "Usage: $0 [options]\n\n"
    echo "Options:"
    echo "  -h, --help              Display help information"
    echo "  -d, --domain <domain>   Domain to scan for XSS, SQLi, SSRF, Open-Redirect, etc. vulnerabilities"
    exit 0
}

# Get the current user's home directory
home_dir=$(eval echo ~$USER)
# Set the folder for paramspider
paramspider_dir="$home_dir/ParamSpider"
# Set the folder for fuzzing template
fuzzing_templates_dir="$home_dir/fuzzing-templates"
# Set output folder (default)
output_dir="output"

# Function to clone repo after checking if it exists
clone_repo() {
    local repo_url=$1
    local clone_dir=$2

    if [ ! -d "$clone_dir" ]; then
        echo "Cloning repository from $repo_url..."
        git clone $repo_url $clone_dir || { echo "Failed to clone repository. Exiting..."; exit 1; }
    fi
}

# Check if ParamSpider is already cloned and installed
clone_repo "https://github.com/0xKayala/ParamSpider" $paramspider_dir

# Check if fuzzing-templates is already cloned.
clone_repo "https://github.com/projectdiscovery/fuzzing-templates.git" $fuzzing_templates_dir

# Step 1: Parse command line arguments
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
        -o|--output)
            output_dir="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Step 2: Ask the user to enter the domain name
if [ -z "$domain" ]; then
    echo "Enter the domain name (eg: target.com):"
    read domain
fi

# Step 3: Get the vulnerable parameters of the given domain name using ParamSpider tool and save the output into a text file
echo "Running ParamSpider on $domain"
python3 "$home_dir/ParamSpider/paramspider.py" -d "$domain" --exclude png,jpg,gif,jpeg,swf,woff,gif,svg --level high --quiet -o $output_dir/$domain.txt

# Check whether URLs were collected or not
if [ ! -s $output_dir/$domain.txt ]; then
    echo "No URLs Found. Exiting..."
    exit 1
fi

# Step 4: Run the Nuclei Fuzzing templates on $domain.txt file
echo "Running Nuclei on $output_dir/$domain.txt"
nuclei -l $output_dir/$domain.txt -t "$home_dir/fuzzing-templates" -rl 05

# Step 5: End with a general message as the scan is completed
echo "Scan is completed - Happy Fuzzing"
