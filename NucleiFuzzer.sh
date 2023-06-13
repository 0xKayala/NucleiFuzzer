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
    echo -e "NucleiFuzzer is a powerful automation tool for detecting xss,sqli,ssrf,open-redirect..etc vulnerabilities in web applications\n\n"
    echo -e "Usage: $0 [options]\n\n"
    echo "Options:"
    echo "  -h, --help              Display help information"
    echo "  -d, --domain <domain>   Domain to scan for xss,sqli,ssrf,open-redirect..etc vulnerabilities"
    exit 0
}

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
    echo "Enter the domain name: "
    read domain
fi

# Step 3: Get the vulnerable parameters of the given domain name using ParamSpider tool and save the output into a text file
echo "Running ParamSpider on $domain"
python3 /home/kali/ParamSpider/paramspider.py -d "$domain" --exclude png,jpg,gif,jpeg,swf,woff,gif,svg --quiet -o /home/kali/paramspider_output.txt

# Check if ParamSpider found any unique URLs
unique_urls=$(grep -oP '(?<=\=)[^&]+' /home/kali/paramspider_output.txt | sort -u | wc -l)
if [ $unique_urls -eq 0 ]; then
    echo "No URLs Found"
    exit 1
fi

# Step 4: Run the nuclei fuzzer tool on the above text file
echo "Running nuclei fuzzer on paramspider_output.txt"
nuclei -l /home/kali/paramspider_output.txt -t fuzzing-templates -rl 05

# Step 5: End with general message as the scan is completed
echo "Scan is completed."
