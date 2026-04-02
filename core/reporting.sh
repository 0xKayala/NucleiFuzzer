#!/bin/bash

group_by_severity() {
    local file="$1"

    echo "[*] Grouping by severity..."

    jq -r '.info.severity' "$file" | sort | uniq -c
}

generate_html_report() {
    local json="$1"
    local html="$2"

    echo "[*] Generating HTML report..."

    cat <<EOF > "$html"
<html>
<body>
<h1>NucleiFuzzer Report</h1>
<pre>
EOF

    cat "$json" >> "$html"

    cat <<EOF >> "$html"
</pre>
</body>
</html>
EOF
}
