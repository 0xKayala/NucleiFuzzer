#!/bin/bash

# ==========================================
# ⬆️ NUCLEIFUZZER UPDATE ENGINE (SMART + FAST)
# ==========================================

# ==========================================
# 🌐 ENVIRONMENT SETUP
# ==========================================

setup_update_env() {

    # Fix PATH (critical for WSL + Go)
    export PATH="/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"

    # Go stability fixes
    export GOPROXY=https://proxy.golang.org,direct
    export GOSUMDB=off
    export GOTOOLCHAIN=local
}

# ==========================================
# 🌐 INTERNET CHECK (NEW)
# ==========================================

check_network_update() {

    if command -v curl &>/dev/null; then
        curl -Is https://google.com --max-time 5 &>/dev/null && return 0
    fi

    return 1
}

# ==========================================
# 🔍 TOOL VERSION FETCHER
# ==========================================

get_version() {
    local tool="$1"

    case "$tool" in
        nuclei|httpx|katana)
            $tool -version 2>/dev/null | head -n1
            ;;
        waybackurls|gauplus|hakrawler)
            echo "installed"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# ==========================================
# 🔄 SMART GO TOOL UPDATE (FIXED)
# ==========================================

update_go_tool() {
    local tool_name="$1"
    local install_cmd="$2"

    # Skip if already installed (FAST MODE)
    if command -v "$tool_name" &>/dev/null; then
        echo "[OK] $tool_name already installed → skipping"
        return
    fi

    echo "[*] Installing $tool_name..."

    if eval "$install_cmd" &>/dev/null; then
        echo "[OK] $tool_name installed"
    else
        echo "[WARN] Failed to install $tool_name"
    fi
}

# ==========================================
# 📦 UPDATE GO-BASED TOOLS
# ==========================================

update_go_tools() {

    echo "[*] Checking Go-based tools..."

    update_go_tool "nuclei" "go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    update_go_tool "httpx" "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
    update_go_tool "katana" "go install github.com/projectdiscovery/katana/cmd/katana@latest"
    update_go_tool "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
    update_go_tool "gauplus" "go install github.com/bp0lr/gauplus@latest"
    update_go_tool "hakrawler" "go install github.com/hakluke/hakrawler@latest"
}

# ==========================================
# 🌐 UPDATE EXTERNAL RESOURCES
# ==========================================

update_resources() {

    echo "[*] Checking external resources..."

    # Nuclei Templates
    if [ -d "$HOME/nuclei-templates/.git" ]; then
        echo "[OK] Templates already present"
    else
        echo "[*] Cloning nuclei templates..."
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates" &>/dev/null \
            && echo "[OK] Templates installed" \
            || echo "[WARN] Failed to clone templates"
    fi

    # ParamSpider
    if [ -d "$HOME/ParamSpider/.git" ]; then
        echo "[OK] ParamSpider already present"
    else
        echo "[*] Cloning ParamSpider..."
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider" &>/dev/null \
            && echo "[OK] ParamSpider installed" \
            || echo "[WARN] Failed to clone ParamSpider"
    fi
}

# ==========================================
# 🧹 CLEANUP
# ==========================================

cleanup_update() {

    echo "[*] Cleaning Go cache..."
    go clean -modcache &>/dev/null
}

# ==========================================
# 🚀 MAIN UPDATE FUNCTION
# ==========================================

run_update() {

    echo "======================================"
    echo "⬆️ NucleiFuzzer Smart Update Engine"
    echo "======================================"

    setup_update_env

    # --------------------------------------
    # 🌐 NETWORK CHECK
    # --------------------------------------
    if ! check_network_update; then
        echo "[WARN] No internet connection → skipping updates"
        echo "======================================"
        echo "⚠️ Update skipped (offline mode)"
        echo "======================================"
        return
    fi

    # --------------------------------------
    # 📦 TOOLS
    # --------------------------------------
    update_go_tools

    # --------------------------------------
    # 📂 RESOURCES
    # --------------------------------------
    update_resources

    # --------------------------------------
    # 🧹 CLEANUP
    # --------------------------------------
    cleanup_update

    echo "======================================"
    echo "✅ Update completed successfully"
    echo "======================================"
}
