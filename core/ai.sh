#!/bin/bash

# ==========================================
# 🧠 AI ANALYSIS MODULE (PRO+ INTELLIGENCE)
# ==========================================

run_ai_analysis() {
    local json="$1"
    local output="$2"

    if [ ! -f "$json" ] || [ ! -s "$json" ]; then
        echo "[WARN] No data for AI analysis"
        return
    fi

    echo -e "${BLUE}[*] Running AI Analysis...${RESET}"

    # --------------------------------------
    # 📊 BASIC COUNTS
    # --------------------------------------

    CRITICAL=$(grep -c '"severity":"critical"' "$json")
    HIGH=$(grep -c '"severity":"high"' "$json")
    MEDIUM=$(grep -c '"severity":"medium"' "$json")

    # --------------------------------------
    # 🧠 DETECTION FLAGS
    # --------------------------------------

    HAS_IDOR=$(grep -qi "idor" "$json" && echo "true" || echo "false")
    HAS_XSS=$(grep -qi "xss" "$json" && echo "true" || echo "false")
    HAS_SSRF=$(grep -qi "ssrf" "$json" && echo "true" || echo "false")
    HAS_SQLI=$(grep -qi "sql" "$json" && echo "true" || echo "false")
    HAS_RCE=$(grep -qi "rce" "$json" && echo "true" || echo "false")

    # --------------------------------------
    # 📄 AI OUTPUT
    # --------------------------------------

    {
        echo "======================================"
        echo "🧠 AI SECURITY INSIGHTS"
        echo "======================================"
        echo ""
        echo "📊 Severity Overview:"
        echo "Critical : $CRITICAL"
        echo "High     : $HIGH"
        echo "Medium   : $MEDIUM"
        echo ""

        # ----------------------------------
        # 🚨 PRIORITY DECISION
        # ----------------------------------

        if [ "$CRITICAL" -gt 0 ]; then
            echo "🚨 PRIORITY: IMMEDIATE ACTION REQUIRED"
        elif [ "$HIGH" -gt 0 ]; then
            echo "⚠️ PRIORITY: HIGH RISK - Fix soon"
        else
            echo "✅ PRIORITY: Moderate risk"
        fi

        echo ""

        # ----------------------------------
        # 🧠 VULNERABILITY INSIGHTS
        # ----------------------------------

        echo "🔍 Key Findings:"

        if [ "$HAS_IDOR" = "true" ]; then
            echo "- IDOR detected"
            echo "  → Test horizontal/vertical privilege escalation"
            echo "  → Try changing user IDs"
        fi

        if [ "$HAS_XSS" = "true" ]; then
            echo "- XSS detected"
            echo "  → Test payloads:"
            echo "     <script>alert(1)</script>"
            echo "     \"><svg/onload=alert(1)>"
        fi

        if [ "$HAS_SSRF" = "true" ]; then
            echo "- SSRF risk"
            echo "  → Test internal endpoints:"
            echo "     http://127.0.0.1"
            echo "     http://169.254.169.254"
        fi

        if [ "$HAS_SQLI" = "true" ]; then
            echo "- SQL Injection indicators"
            echo "  → Try:"
            echo "     ' OR 1=1--"
            echo "     sleep(5)"
        fi

        if [ "$HAS_RCE" = "true" ]; then
            echo "- RCE indicators"
            echo "  → Test command injection:"
            echo "     ;id"
            echo "     && whoami"
        fi

        echo ""

        # ----------------------------------
        # 💡 SMART RECOMMENDATIONS
        # ----------------------------------

        echo "💡 Suggested Next Steps:"

        if [ "$CRITICAL" -gt 0 ]; then
            echo "- Focus on critical endpoints first"
        fi

        if [ "$HAS_IDOR" = "true" ]; then
            echo "- Perform authenticated testing"
        fi

        if [ "$HAS_XSS" = "true" ]; then
            echo "- Test stored vs reflected XSS"
        fi

        echo "- Run deeper scan (--deep)"
        echo "- Perform manual validation (reduce false positives)"

        echo ""
        echo "======================================"

    } > "$output"

    echo "[OK] AI analysis saved → $output"
}
