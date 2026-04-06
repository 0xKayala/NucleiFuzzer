#!/bin/bash

# ==========================================
# 📊 REPORTING MODULE (CLEAN + PROFESSIONAL)
# ==========================================

group_by_severity() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "[ERROR] No results found"
        return
    fi

    echo -e "${BLUE}[*] Grouping by severity...${RESET}"

    jq -r '.info.severity' "$file" | sort | uniq -c
}

generate_html_report() {
    local json="$1"
    local html="$2"

    if [ ! -f "$json" ]; then
        echo "[ERROR] JSON not found"
        return
    fi

    echo -e "${BLUE}[*] Generating HTML report...${RESET}"

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
<table>
<tr>
<th>Severity</th>
<th>Name</th>
<th>URL</th>
</tr>
EOF

    jq -r '
    [.info.severity, .info.name, .host] | @tsv
    ' "$json" | while IFS=$'\t' read -r sev name url; do
        echo "<tr><td class=\"$sev\">$sev</td><td>$name</td><td>$url</td></tr>" >> "$html"
    done

    cat "$json" >> "$html"

    cat <<EOF >> "$html"
</table>
</body>
</html>
EOF
}
