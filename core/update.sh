#!/bin/bash

# ==========================================
# ⬆️ NUCLEIFUZZER UPDATE ENGINE
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
# 🔄 SMART GO TOOL UPDATE
# ==========================================

update_go_tool() {
    local tool_name="$1"
    local install_cmd="$2"

    if command -v "$tool_name" &>/dev/null; then

        echo "[*] Checking $tool_name..."

        CURRENT_VERSION=$(get_version "$tool_name")
        echo "[INFO] Current: $CURRENT_VERSION"

        # Attempt update silently
        eval "$install_cmd" &>/dev/null

        NEW_VERSION=$(get_version "$tool_name")

        if [ "$CURRENT_VERSION" == "$NEW_VERSION" ]; then
            echo "[OK] $tool_name is already up-to-date"
        else
            echo "[UPDATED] $tool_name → $NEW_VERSION"
        fi

    else
        echo "[WARN] $tool_name not found → installing..."
        eval "$install_cmd"
        echo "[OK] $tool_name installed"
    fi
}

# ==========================================
# 📦 UPDATE GO-BASED TOOLS
# ==========================================

update_go_tools() {

    echo "[*] Updating Go-based tools..."

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

    echo "[*] Updating external resources..."

    # Nuclei Templates
    if [ -d "$HOME/nuclei-templates/.git" ]; then
        echo "[*] Updating nuclei templates..."
        cd "$HOME/nuclei-templates" && git pull --quiet && cd - &>/dev/null
        echo "[OK] Templates updated"
    else
        echo "[*] Cloning nuclei templates..."
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates"
    fi

    # ParamSpider
    if [ -d "$HOME/ParamSpider/.git" ]; then
        echo "[*] Updating ParamSpider..."
        cd "$HOME/ParamSpider" && git pull --quiet && cd - &>/dev/null
        echo "[OK] ParamSpider updated"
    else
        echo "[*] Cloning ParamSpider..."
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider"
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

    update_go_tools

    update_resources

    cleanup_update

    echo "======================================"
    echo "✅ Update completed successfully"
    echo "======================================"

}
