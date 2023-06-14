#!/bin/bash

# ASCII art
echo -e "\e[91m
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

# Check if ParamSpider is already cloned..
if [ ! -d "$home_dir/ParamSpider" ]; then
    echo "Cloning ParamSpider..."
    git clone https://github.com/devanshbatham/ParamSpider.git "$home_dir/ParamSpider"
fi

# Check if fuzzing-templates is already cloned.
if [ ! -d "$home_dir/fuzzing-templates" ]; then
    echo "Cloning fuzzing-templates..."
    git clone https://github.com/projectdiscovery/fuzzing-templates.git "$home_dir/fuzzing-templates"
fi

# Check if nuclei is installed, if not, install it
if ! command -v nuclei &> /dev/null; then
    echo "Installing Nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
fi

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
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Step 2: Ask the user to enter the domain name
if [ -z "$domain" ]; then
    echo "Enter the domain name: target.com"
    read domain
fi

# Step 3: Get the vulnerable parameters of the given domain name using ParamSpider tool and save the output into a text file
echo "Running ParamSpider on $domain"
python3 "$home_dir/ParamSpider/paramspider.py" -d "$domain" --exclude png,jpg,gif,jpeg,swf,woff,gif,svg --level high --quiet -o paramspider_output.txt

# Check whether URLs were collected or not
if [ ! -s output/paramspider_output.txt ]; then
    echo "No URLs Found. Exiting..."
    exit 1
fi

# Step 4: Run the Nuclei Fuzzing templates on paramspider_output.txt file
echo "Running Nuclei on paramspider_output.txt"
nuclei -l output/paramspider_output.txt -t "$home_dir/fuzzing-templates" -rl 05

# Step 5: End with general message as the scan is completed
echo "Scan is completed - Happy Fuzzing"
