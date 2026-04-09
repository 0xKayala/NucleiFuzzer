#!/bin/bash

# ==========================================
# 🧠 AI ANALYSIS MODULE (v3.3 ELITE ENGINE)
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

    TOTAL=$((CRITICAL + HIGH + MEDIUM))

    # --------------------------------------
    # 🧠 DETECTION FLAGS
    # --------------------------------------

    HAS_IDOR=$(grep -qi "idor" "$json" && echo "true" || echo "false")
    HAS_XSS=$(grep -qi "xss" "$json" && echo "true" || echo "false")
    HAS_SSRF=$(grep -qi "ssrf" "$json" && echo "true" || echo "false")
    HAS_SQLI=$(grep -qi "sql" "$json" && echo "true" || echo "false")
    HAS_RCE=$(grep -qi "rce" "$json" && echo "true" || echo "false")

    # --------------------------------------
    # 🧠 RISK SCORING ENGINE (NEW)
    # --------------------------------------

    SCORE=0

    ((SCORE += CRITICAL * 5))
    ((SCORE += HIGH * 3))
    ((SCORE += MEDIUM * 1))

    if [ "$HAS_RCE" = "true" ]; then ((SCORE += 10)); fi
    if [ "$HAS_SSRF" = "true" ]; then ((SCORE += 8)); fi
    if [ "$HAS_SQLI" = "true" ]; then ((SCORE += 7)); fi
    if [ "$HAS_IDOR" = "true" ]; then ((SCORE += 6)); fi
    if [ "$HAS_XSS" = "true" ]; then ((SCORE += 4)); fi

    # --------------------------------------
    # 🧠 AI PROVIDER DETECTION (NEW)
    # --------------------------------------

    AI_PROVIDER="none"

    if command -v gemini &>/dev/null && [ -n "$GEMINI_API_KEY" ]; then
        AI_PROVIDER="gemini"
    elif [ -n "$OPENAI_API_KEY" ]; then
        AI_PROVIDER="openai"
    elif [ -n "$CLAUDE_API_KEY" ]; then
        AI_PROVIDER="claude"
    fi

    # --------------------------------------
    # 📄 BASE OUTPUT
    # --------------------------------------

    {
        echo "======================================"
        echo "🧠 AI SECURITY INSIGHTS"
        echo "======================================"
        echo ""

        echo "📊 Overview:"
        echo "Total Findings : $TOTAL"
        echo "Critical       : $CRITICAL"
        echo "High           : $HIGH"
        echo "Medium         : $MEDIUM"
        echo ""

        echo "🧠 Risk Score: $SCORE"
        echo ""

        # ----------------------------------
        # 🚨 PRIORITY
        # ----------------------------------

        if [ "$SCORE" -gt 20 ]; then
            echo "🚨 PRIORITY: CRITICAL RISK"
        elif [ "$SCORE" -gt 10 ]; then
            echo "⚠️ PRIORITY: HIGH RISK"
        else
            echo "✅ PRIORITY: MODERATE RISK"
        fi

        echo ""

        # ----------------------------------
        # 🔍 VULNERABILITY INSIGHTS
        # ----------------------------------

        echo "🔍 Key Findings:"

        [ "$HAS_RCE" = "true" ] && echo "- RCE detected → Critical exploitation possible"
        [ "$HAS_SQLI" = "true" ] && echo "- SQL Injection → Database compromise risk"
        [ "$HAS_SSRF" = "true" ] && echo "- SSRF → Internal service access risk"
        [ "$HAS_IDOR" = "true" ] && echo "- IDOR → Broken access control"
        [ "$HAS_XSS" = "true" ] && echo "- XSS → Client-side exploitation"

        echo ""

        # ----------------------------------
        # 💡 ACTIONABLE STEPS
        # ----------------------------------

        echo "💡 Recommended Actions:"
        echo "- Validate findings manually"
        echo "- Focus on high-impact endpoints first"
        echo "- Attempt chaining vulnerabilities"
        echo "- Run deeper scan (--deep)"

        echo ""

        # ----------------------------------
        # 🤖 EXTERNAL AI (OPTIONAL)
        # ----------------------------------

        if [ "$AI_PROVIDER" = "gemini" ]; then
            echo "🤖 Gemini AI Insights:"
            gemini "Analyze this vulnerability report and suggest exploitation paths:" \
                < "$json" 2>/dev/null | head -n 15
            echo ""
        fi

        echo "======================================"

    } > "$output"

    echo "[OK] AI analysis saved → $output"
}
