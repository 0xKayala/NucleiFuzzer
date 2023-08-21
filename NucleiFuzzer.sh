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
    echo "  -h, --help               Display help information" 
    echo "  -d, --domain <domain>    Single domain to scan"
    echo "  -l, --list <file>        File containing a list of domains to scan"
    echo "  -t, --template <path>    Specify template path for nuclei"
    exit 0 
}

home_dir=$(eval echo ~$USER)

# Check if ParamSpider is already cloned and installed 
if ! command -v paramspider &> /dev/null; then 
    echo "Installing ParamSpider..." 
    git clone https://github.com/devanshbatham/paramspider.git "$home_dir/paramspider" 
    cd "$home_dir/paramspider" || exit 
    pip install . 
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

# Timestamp Variable
timestamp=$(date +"%Y%m%d_%H%M%S")

# Step 1: Parse command line arguments 
domain=""
domain_file=""
template_path="$home_dir/fuzzing-templates"

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
        -l|--list)
            domain_file="$2"
            shift
            shift
            ;;
        -t|--template)
            template_path="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Step 2: If single domain is provided, use it. If not, check the domain file.
if [ -n "$domain" ]; then
    domains=("$domain")
elif [ -n "$domain_file" ] && [ -f "$domain_file" ]; then
    mapfile -t domains < "$domain_file"
else
    echo "Please provide a valid domain or domain list file using -d, --domain or -l, --list options"
    exit 1 
fi

# Step 3: Run ParamSpider on all domains first
for domain in "${domains[@]}"; do 
    echo "Running ParamSpider on $domain" 
    paramspider -d "$domain"

    # Check if results directory does not exist, create it
    if [ ! -d "results/$timestamp" ]; then
        mkdir -p "results/$timestamp"
    fi

    # Check if results/paramspider directory does not exist, create it
    if [ ! -d "results/$timestamp/paramspider" ]; then
        mkdir -p "results/$timestamp/paramspider"
    fi

    # Move the output into the paramspider directory 
    if [ -f "results/$domain.txt" ]; then
        mv "results/$domain.txt" "results/$timestamp/paramspider/$domain.txt"
    fi

    # Delete the output file if it's empty
    if [ ! -s "results/$timestamp/paramspider/$domain.txt" ]; then
        rm "results/$timestamp/paramspider/$domain.txt"
    fi
done

# Creating Nuclei directory
mkdir -p "results/$timestamp/nuclei"

# Step 4: Now run Nuclei on each domain's results 
for domain in "${domains[@]}"; do
    if [ ! -s "results/$timestamp/paramspider/$domain.txt" ]; then
        echo "No URLs Found for $domain. Skipping..." 
        continue 
    fi 

    output_file="results/$timestamp/nuclei/nuclei_output_$domain.txt"
    echo "Running Nuclei on $domain.txt using templates from $template_path" 
    nuclei -l "results/$timestamp/paramspider/$domain.txt" -t "$template_path" -rl 05 -o "$output_file"

    # Delete the output file if it's empty
    if [ ! -s "$output_file" ]; then
        rm "$output_file"
    fi
done

# Step 5: End with a general message as the scan is completed  
echo "Scan is completed - Happy Fuzzing"
