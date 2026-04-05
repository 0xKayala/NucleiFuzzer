#!/bin/bash

run_doctor() {

    echo "======================================"
    echo "🩺 NucleiFuzzer Doctor Mode"
    echo "======================================"

    ISSUES=0

    check_tool() {
        local tool="$1"

        if command -v "$tool" &>/dev/null; then
            echo "[OK] $tool is installed"
        else
            echo "[FAIL] $tool is missing"
            ((ISSUES++))
        fi
    }

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
    echo "[*] Checking PATH..."

    if [[ ":$PATH:" == *"$HOME/go/bin"* ]]; then
        echo "[OK] Go bin in PATH"
    else
        echo "[FAIL] Go bin missing from PATH"
        ((ISSUES++))
    fi

    if [[ ":$PATH:" == *"$HOME/.local/bin"* ]]; then
        echo "[OK] Local bin in PATH"
    else
        echo "[FAIL] ~/.local/bin missing from PATH"
        ((ISSUES++))
    fi

    echo ""
    echo "[*] Checking internet connectivity..."

    if ping -c 1 google.com &>/dev/null; then
        echo "[OK] Internet connection working"
    else
        echo "[FAIL] No internet connection"
        ((ISSUES++))
    fi

    echo ""
    echo "[*] Checking permissions..."

    if [ -w "$OUTPUT_DIR" ]; then
        echo "[OK] Output directory writable"
    else
        echo "[FAIL] Output directory not writable"
        ((ISSUES++))
    fi

    echo ""
    echo "======================================"

    if [ "$ISSUES" -eq 0 ]; then
        echo "✅ System Healthy - Ready to Scan 🚀"
    else
        echo "⚠️ Found $ISSUES issue(s). Run nf again to auto-fix."
    fi

    echo "======================================"
}
