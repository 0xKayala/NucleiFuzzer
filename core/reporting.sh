#!/bin/bash

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
pre { background:#222; padding:10px; }
</style>
</head>
<body>
<h1>NucleiFuzzer Scan Results</h1>
<pre>
EOF

    cat "$json" >> "$html"

    cat <<EOF >> "$html"
</pre>
</body>
</html>
EOF
}