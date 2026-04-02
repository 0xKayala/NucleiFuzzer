#!/bin/bash

run_ai_analysis() {
    echo "[*] Running AI Analysis..."

    AI_FILE="$OUTPUT_FOLDER/ai_analysis.txt"

    SUMMARY=$(jq -r '.info.name' "$JSON_FILE" | sort | uniq)

    echo "========== AI Security Insights ==========" > "$AI_FILE"

    echo "[+] Detected Vulnerabilities:" >> "$AI_FILE"
    echo "$SUMMARY" >> "$AI_FILE"
    echo "" >> "$AI_FILE"

    # Smart heuristics (AI-like logic)

    if echo "$SUMMARY" | grep -qi "idor"; then
        echo "[!] Possible IDOR detected → Test /api/user?id=" >> "$AI_FILE"
    fi

    if echo "$SUMMARY" | grep -qi "xss"; then
        echo "[!] XSS found → Check for cookie theft & CSP bypass" >> "$AI_FILE"
    fi

    if echo "$SUMMARY" | grep -qi "sql"; then
        echo "[!] SQL Injection → Try UNION / Blind techniques" >> "$AI_FILE"
    fi

    if echo "$SUMMARY" | grep -qi "auth"; then
        echo "[!] Authentication issue → Test JWT / session handling" >> "$AI_FILE"
    fi

    if echo "$SUMMARY" | grep -qi "ssrf"; then
        echo "[!] SSRF → Test internal endpoints (169.254.169.254)" >> "$AI_FILE"
    fi

    echo "" >> "$AI_FILE"
    echo "[+] AI Analysis Completed." >> "$AI_FILE"
}
