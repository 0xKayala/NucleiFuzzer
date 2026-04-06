#!/bin/bash

# ==========================================
# 📊 REPORTING MODULE (CLEAN + PROFESSIONAL)
# ==========================================

group_by_severity() {
    local file="$1"

    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        echo "[WARN] No results found"
        return
    fi

    echo -e "${BLUE}[*] Grouping by severity...${RESET}"

    jq -r '.info.severity' "$file" \
        | sort \
        | uniq -c \
        | sort -nr
}

generate_html_report() {
    local json="$1"
    local html="$2"

    if [ ! -f "$json" ] || [ ! -s "$json" ]; then
        echo "[WARN] No JSON data to generate report"
        return
    fi

    echo -e "${BLUE}[*] Generating HTML report...${RESET}"

    # --------------------------------------
    # 📊 SUMMARY COUNTS
    # --------------------------------------

    CRIT=$(grep -c '"severity":"critical"' "$json")
    HIGH=$(grep -c '"severity":"high"' "$json")
    MED=$(grep -c '"severity":"medium"' "$json")

    # --------------------------------------
    # 🌐 HTML HEADER
    # --------------------------------------

    cat <<EOF > "$html"
<html>
<head>
<title>NucleiFuzzer Report</title>
<style>
body { font-family: Arial; background:#111; color:#eee; }
h1 { color:#00ffcc; }
h2 { color:#00ffaa; }
table { width:100%; border-collapse: collapse; margin-top:20px; }
th, td { padding:10px; border:1px solid #333; text-align:left; }
th { background:#222; }
.critical { color:red; font-weight:bold; }
.high { color:orange; }
.medium { color:yellow; }
.summary { margin-top:20px; }
</style>
</head>
<body>

<h1>NucleiFuzzer Scan Report</h1>

<div class="summary">
<h2>Summary</h2>
<p>Critical: $CRIT</p>
<p>High: $HIGH</p>
<p>Medium: $MED</p>
</div>

<table>
<tr>
<th>Severity</th>
<th>Name</th>
<th>URL</th>
</tr>
EOF

    # --------------------------------------
    # 📊 SORTED OUTPUT (CRITICAL → MEDIUM)
    # --------------------------------------

    jq -r '
    [.info.severity, .info.name, .host] | @tsv
    ' "$json" \
    | sort -t$'\t' -k1,1r \
    | while IFS=$'\t' read -r sev name url; do

        # Basic HTML escaping
        name=$(echo "$name" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
        url=$(echo "$url" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

        echo "<tr>
<td class=\"$sev\">$sev</td>
<td>$name</td>
<td><a href=\"$url\" target=\"_blank\">$url</a></td>
</tr>" >> "$html"

    done

    # --------------------------------------
    # 🌐 HTML FOOTER
    # --------------------------------------

    cat <<EOF >> "$html"
</table>

</body>
</html>
EOF

    echo "[OK] HTML report generated: $html"
}
