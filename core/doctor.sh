#!/bin/bash

# ==========================================
# 🩺 NUCLEIFUZZER DOCTOR MODE (v3.3 PRO+)
# ==========================================

# ==========================================
# 🌐 SMART INTERNET CHECK
# ==========================================

check_internet() {

    if command -v curl &>/dev/null; then
        curl -Is https://google.com --max-time 5 &>/dev/null && return 0
    fi

    if command -v wget &>/dev/null; then
        wget -q --spider https://google.com && return 0
    fi

    getent hosts google.com &>/dev/null && return 0

    return 1
}

# ==========================================
# 🔍 TOOL CHECK
# ==========================================

check_tool() {
    local tool="$1"

    if command -v "$tool" &>/dev/null; then
        echo "[OK] $tool is installed"
    else
        echo "[FAIL] $tool is missing"
        ((ISSUES++))
    fi
}

# ==========================================
# 🛤️ PATH CHECK
# ==========================================

check_path() {

    echo "[*] Checking PATH..."

    [[ ":$PATH:" == *":$HOME/go/bin:"* ]] \
        && echo "[OK] Go bin in PATH" \
        || { echo "[FAIL] Go bin missing"; ((ISSUES++)); }

    [[ ":$PATH:" == *":$HOME/.local/bin:"* ]] \
        && echo "[OK] Local bin in PATH" \
        || { echo "[FAIL] ~/.local/bin missing"; ((ISSUES++)); }
}

# ==========================================
# 🌐 NETWORK CHECK
# ==========================================

check_network() {

    echo "[*] Checking internet connectivity..."

    if check_internet; then
        echo "[OK] Internet connection working"
    else
        echo "[WARN] No internet connection"
        ((ISSUES++))
    fi
}

# ==========================================
# 📁 OUTPUT DIRECTORY CHECK
# ==========================================

check_output_dir() {

    OUTPUT_DIR="${OUTPUT_DIR:-./output}"

    if [ ! -d "$OUTPUT_DIR" ]; then
        echo "[WARN] Output directory missing → creating..."
        mkdir -p "$OUTPUT_DIR" 2>/dev/null
    fi

    [ -w "$OUTPUT_DIR" ] \
        && echo "[OK] Output directory writable" \
        || { echo "[FAIL] Output not writable"; ((ISSUES++)); }
}

# ==========================================
# 📦 TEMPLATE CHECK
# ==========================================

check_templates() {

    echo "[*] Checking nuclei templates..."

    TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/nuclei-templates}"

    if [ -d "$TEMPLATE_DIR" ] && [ "$(ls -A "$TEMPLATE_DIR" 2>/dev/null)" ]; then
        echo "[OK] Templates available"
    else
        echo "[FAIL] Templates missing or empty"
        echo "[FIX] Run: nf --update"
        ((ISSUES++))
    fi
}

# ==========================================
# 🔌 PLUGIN SYSTEM CHECK (NEW)
# ==========================================

check_plugins() {

    echo "[*] Checking plugin system..."

    PLUGIN_DIR="./plugins"

    if [ -d "$PLUGIN_DIR" ]; then
        COUNT=$(ls "$PLUGIN_DIR"/*.sh 2>/dev/null | wc -l)

        if [ "$COUNT" -gt 0 ]; then
            echo "[OK] Plugins loaded ($COUNT found)"
        else
            echo "[WARN] Plugin directory empty"
        fi
    else
        echo "[INFO] No plugins directory (optional)"
    fi
}

# ==========================================
# 🤖 AI PROVIDER CHECK (NEW)
# ==========================================

check_ai() {

    echo "[*] Checking AI integration..."

    if command -v gemini &>/dev/null && [ -n "$GEMINI_API_KEY" ]; then
        echo "[OK] Gemini AI ready"
    elif [ -n "$OPENAI_API_KEY" ]; then
        echo "[OK] OpenAI API configured"
    elif [ -n "$CLAUDE_API_KEY" ]; then
        echo "[OK] Claude API configured"
    else
        echo "[INFO] No AI provider configured (optional)"
    fi
}

# ==========================================
# 🌐 SUBPIPE CHECK (NEW)
# ==========================================

check_subpipe() {

    echo "[*] Checking SubPipe integration..."

    if command -v subpipe &>/dev/null; then
        if [ -n "$SUBPIPE_API_KEY" ]; then
            echo "[OK] SubPipe ready"
        else
            echo "[WARN] SubPipe installed but API key missing"
        fi
    else
        echo "[INFO] SubPipe not installed (optional)"
    fi
}

# ==========================================
# ⚡ PERFORMANCE CHECK (NEW)
# ==========================================

check_performance() {

    echo "[*] Checking performance settings..."

    RATE="${RATE_LIMIT:-50}"

    if [ "$RATE" -lt 30 ]; then
        echo "[WARN] Low rate limit → scans may be slow"
    elif [ "$RATE" -gt 200 ]; then
        echo "[WARN] High rate limit → risk of blocking"
    else
        echo "[OK] Rate limit balanced ($RATE)"
    fi
}

# ==========================================
# 🚀 MAIN DOCTOR FUNCTION
# ==========================================

run_doctor() {

    echo "======================================"
    echo "🩺 NucleiFuzzer Doctor Mode v3.3"
    echo "======================================"

    ISSUES=0

    echo ""
    echo "[*] Checking core tools..."

    check_tool "nuclei"
    check_tool "httpx"
    check_tool "katana"
    check_tool "waybackurls"
    check_tool "gauplus"
    check_tool "hakrawler"
    check_tool "uro"
    check_tool "jq"
    check_tool "python3"
    check_tool "pip3"

    echo ""
    check_path

    echo ""
    check_network

    echo ""
    check_output_dir

    echo ""
    check_templates

    echo ""
    check_plugins

    echo ""
    check_ai

    echo ""
    check_subpipe

    echo ""
    check_performance

    # --------------------------------------
    # 🚀 FINAL STATUS
    # --------------------------------------

    echo ""
    echo "======================================"

    if [ "$ISSUES" -eq 0 ]; then
        echo "✅ System Healthy - Ready to Scan 🚀"
    else
        echo "⚠️ Found $ISSUES issue(s)"
        echo "👉 Run: nf --update"
    fi

    echo "======================================"
}
