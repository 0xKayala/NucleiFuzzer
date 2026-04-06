#!/bin/bash

# ==========================================
# 🩺 NUCLEIFUZZER DOCTOR MODE (v3.1)
# ==========================================

# ==========================================
# 🌐 SMART INTERNET CHECK (WSL SAFE)
# ==========================================

check_internet() {

    # Method 1: curl
    if command -v curl &>/dev/null; then
        curl -Is https://google.com --max-time 5 &>/dev/null && return 0
    fi

    # Method 2: wget
    if command -v wget &>/dev/null; then
        wget -q --spider https://google.com && return 0
    fi

    # Method 3: DNS fallback
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

    if [[ ":$PATH:" == *":$HOME/go/bin:"* ]]; then
        echo "[OK] Go bin in PATH"
    else
        echo "[FAIL] Go bin missing from PATH"
        ((ISSUES++))
    fi

    if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
        echo "[OK] Local bin in PATH"
    else
        echo "[FAIL] ~/.local/bin missing from PATH"
        ((ISSUES++))
    fi
}

# ==========================================
# 🌐 INTERNET CHECK
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
# 📁 OUTPUT DIRECTORY CHECK (AUTO-FIX)
# ==========================================

check_output_dir() {

    OUTPUT_DIR="${OUTPUT_DIR:-./output}"

    if [ ! -d "$OUTPUT_DIR" ]; then
        echo "[WARN] Output directory missing → creating..."
        mkdir -p "$OUTPUT_DIR" 2>/dev/null
    fi

    if [ -w "$OUTPUT_DIR" ]; then
        echo "[OK] Output directory writable"
    else
        echo "[FAIL] Output directory not writable"
        ((ISSUES++))
    fi
}

# ==========================================
# 🚀 MAIN DOCTOR FUNCTION
# ==========================================

run_doctor() {

    echo "======================================"
    echo "🩺 NucleiFuzzer Doctor Mode"
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
    echo "======================================"

    if [ "$ISSUES" -eq 0 ]; then
        echo "✅ System Healthy - Ready to Scan 🚀"
    else
        echo "⚠️ Found $ISSUES issue(s). Run nf again to auto-fix."
    fi

    echo "======================================"
}
