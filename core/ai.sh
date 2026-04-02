run_ai_analysis() {
    echo "[*] Running AI Analysis..."

    SUMMARY=$(jq -r '.info.name' "$JSON_FILE" | sort | uniq)

    echo "AI Insights:" > "$OUTPUT_FOLDER/ai_analysis.txt"

    echo "Detected vulnerabilities:" >> "$OUTPUT_FOLDER/ai_analysis.txt"
    echo "$SUMMARY" >> "$OUTPUT_FOLDER/ai_analysis.txt"

    # Example logic (can connect to LLM later)
    if echo "$SUMMARY" | grep -qi "idor"; then
        echo "[!] Possible IDOR → Test /api/user?id= parameter" >> "$OUTPUT_FOLDER/ai_analysis.txt"
    fi

    if echo "$SUMMARY" | grep -qi "auth"; then
        echo "[!] Check authentication bypass / JWT issues" >> "$OUTPUT_FOLDER/ai_analysis.txt"
    fi
}
