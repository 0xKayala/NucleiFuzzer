#!/bin/bash

group_by_severity() {
    echo "[*] Grouping by severity..."

    jq -r '.info.severity' "$JSON_FILE" | \
        sort | uniq -c > "$OUTPUT_FOLDER/severity.txt"
}

generate_html_report() {
    echo "[*] Generating HTML report..."

    HTML_FILE="$OUTPUT_FOLDER/report.html"

    cat <<EOF > "$HTML_FILE"
<html>
<head>
<title>NucleiFuzzer Report</title>
<style>
body { font-family: Arial; }
.critical { color: red; }
.high { color: orange; }
.medium { color: goldenrod; }
.low { color: green; }
</style>
</head>
<body>

<h1>NucleiFuzzer Scan Report</h1>

<h2>Severity Summary</h2>
<pre>
$(cat "$OUTPUT_FOLDER/severity.txt")
</pre>

<h2>Findings</h2>
EOF

    jq -r '
    "<div>
    <b class=\"" + .info.severity + "\">" + .info.severity + "</b><br>
    <b>" + .info.name + "</b><br>
    " + .host + "<br><br>
    </div>"
    ' "$JSON_FILE" >> "$HTML_FILE"

    echo "</body></html>" >> "$HTML_FILE"
}
