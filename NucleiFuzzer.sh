#!/bin/bash

# ASCII art

echo -e "\e[91m
#   _   _            _      _ ______
#  | \ | |          | |    (_)  ____| 
#  |  \| |_   _  ___| | ___ _| |__ _   _ ___________ _ __ 
#  | . ` | | | |/ __| |/ _ \ |  __| | | |_  /_  / _ \ '__|
#  | |\  | |_| | (__| |  __/ | |  | |_| |/ / / /  __/ |
#  |_| \_|\__,_|\___|_|\___|_|_|   \__,_/___/___\___|_|
                               Made by Satya Prakash (0xKayala)
\e[0m"

# Help menu
display_help() {
    echo -e "NucleiFuzzer is a powerful automation tool for detecting OpenRedirect vulnerabilities in web applications\n\n"
    echo -e "Usage: $0 [options]\n\n"
    echo "Options:"
    echo "  -h, --help              Display help information"
    echo "  -d, --domain <domain>   Domain to scan for open redirects"
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
python3 /home/kali/ParamSpider/paramspider.py -d "$domain" -o /home/kali/OpenRedirector/paramspider_output.txt

# Check if ParamSpider found any unique URLs
unique_urls=$(grep -oP '(?<=\=)[^&]+' /home/kali/Desktop/Bugs/OpenRedirect/paramspider_output.txt | sort -u | wc -l)
if [ $unique_urls -eq 0 ]; then
    echo "No URLs Found"
    exit 1
fi

# Step 4: Run the nuclei fuzzer tool on the above text file
echo "Running nuclei fuzzer on paramspider_output.txt"
nuclei -l paramspider_output.txt -t fuzzing-templates

# Step 5: End with general message as the scan is completed
echo "Scan is completed."
