#!/bin/bash

# ==========================================
# 📊 REPORTING MODULE (FINAL STABLE)
# ==========================================

group_by_severity() {
    local file="$1"

    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        echo "[WARN] No results found"
        return
    fi

    if ! jq empty "$file" 2>/dev/null; then
        echo "[WARN] Invalid JSON → skipping grouping"
        return
    fi

    echo -e "${BLUE}[*] Grouping by severity...${RESET}"

    jq -r '.info.severity' "$file" | sort | uniq -c | sort -nr
}

generate_html_report() {
    local json="$1"
    local html="$2"

    if [ ! -f "$json" ] || [ ! -s "$json" ]; then
        echo "[WARN] No JSON data"
        return
    fi

    if ! jq empty "$json" 2>/dev/null; then
        echo "[WARN] Invalid JSON → skipping report"
        return
    fi

    echo -e "${BLUE}[*] Generating HTML report...${RESET}"

    CRIT=$(grep -c '"severity":"critical"' "$json")
    HIGH=$(grep -c '"severity":"high"' "$json")
    MED=$(grep -c '"severity":"medium"' "$json")

    cat <<EOF > "$html"
<html>
<head>
<title>NucleiFuzzer Report</title>
<style>
body { font-family: Arial; background:#111; color:#eee; }
h1 { color:#00ffcc; }
table { width:100%; border-collapse: collapse; }
th, td { padding:10px; border:1px solid #333; }
th { background:#222; }
.critical { color:red; }
.high { color:orange; }
.medium { color:yellow; }
</style>
</head>
<body>

<h1>NucleiFuzzer Report</h1>
<p>Critical: $CRIT | High: $HIGH | Medium: $MED</p>

<table>
<tr><th>Severity</th><th>Name</th><th>URL</th></tr>
EOF

    jq -r '[.info.severity,.info.name,.host]|@tsv' "$json" \
    | while IFS=$'\t' read -r s n u; do
        echo "<tr><td class=\"$s\">$s</td><td>$n</td><td>$u</td></tr>" >> "$html"
    done

    echo "</table></body></html>" >> "$html"

    echo "[OK] HTML report generated"
}
