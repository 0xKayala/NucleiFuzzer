#!/bin/bash

# ==========================================
# 🎯 ACTIVE VALIDATOR PLUGIN (v3.4)
# ==========================================
plugin_name="active_validator"
plugin_stage="post_scan"

run_plugin() {
    echo -e "${CYAN}[*] Initializing Active Validation Engine...${RESET}"
    
    # We use SCAN_RESULTS exported from scanning.sh
    if [ -z "$SCAN_RESULTS" ] || [ ! -f "$SCAN_RESULTS" ] || [ ! -s "$SCAN_RESULTS" ]; then
        echo "[INFO] No vulnerabilities found to validate."
        return
    fi

    mkdir -p "$OUTPUT_DIR/proofs"

    # 1. Validate SQL Injection using SQLMap
    if grep -qi "sqli\|sql-injection" "$SCAN_RESULTS"; then
        echo -e "${YELLOW}[!] Potential SQLi detected. Triggering SQLMap for verification...${RESET}"
        
        jq -r 'select(.info.name | test("sqli|sql injection"; "i")) | .matched-at' "$SCAN_RESULTS" | sort -u > "$OUTPUT_DIR/sqli_targets.txt"
        
        if command -v sqlmap &>/dev/null; then
            while read -r target; do
                [ -z "$target" ] && continue
                echo "[*] Attacking: $target"
                sqlmap -u "$target" --batch --level 1 --risk 1 --dbs --output-dir="$OUTPUT_DIR/proofs/sqlmap" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[+] CONFIRMED: SQLi exploit successful on $target${RESET}"
                fi
            done < "$OUTPUT_DIR/sqli_targets.txt"
        else
            echo "[WARN] SQLMap not installed. Skipping SQLi validation."
        fi
    fi

    # 2. Validate XSS using Dalfox
    if grep -qi "xss\|cross-site" "$SCAN_RESULTS"; then
        echo -e "${YELLOW}[!] Potential XSS detected. Triggering Dalfox...${RESET}"
        
        jq -r 'select(.info.name | test("xss|cross-site"; "i")) | .matched-at' "$SCAN_RESULTS" | sort -u > "$OUTPUT_DIR/xss_targets.txt"
        
        if command -v dalfox &>/dev/null; then
            dalfox file "$OUTPUT_DIR/xss_targets.txt" -o "$OUTPUT_DIR/proofs/xss_confirmed.txt" > /dev/null 2>&1
            if [ -s "$OUTPUT_DIR/proofs/xss_confirmed.txt" ]; then
                 echo -e "${GREEN}[+] CONFIRMED: XSS exploits found. Check proofs directory.${RESET}"
            fi
        else
            echo "[WARN] Dalfox not installed. Skipping XSS validation."
        fi
    fi

    echo -e "${GREEN}[✔] Active Validation Complete. Proofs saved in $OUTPUT_DIR/proofs/${RESET}"
}
