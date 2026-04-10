#!/bin/bash

# ==========================================
# ⬆️ NUCLEIFUZZER UPDATE ENGINE (v3.3 PRO)
# ==========================================

# ==========================================
# 🌐 ENVIRONMENT SETUP
# ==========================================

setup_update_env() {

    export PATH="/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"

    export GOPROXY=https://proxy.golang.org,direct
    export GOSUMDB=off
    export GOTOOLCHAIN=local
}

# ==========================================
# 🌐 INTERNET CHECK
# ==========================================

check_network_update() {

    if command -v curl &>/dev/null; then
        curl -Is https://google.com --max-time 5 &>/dev/null && return 0
    fi

    return 1
}

# ==========================================
# 🔄 SMART INSTALL / UPDATE ENGINE
# ==========================================

update_go_tool() {
    local tool_name="$1"
    local install_cmd="$2"

    echo "[*] Checking $tool_name..."

    if command -v "$tool_name" &>/dev/null; then
        echo "[INFO] Updating $tool_name..."
    else
        echo "[INFO] Installing $tool_name..."
    fi

    if eval "$install_cmd" &>/dev/null; then
        echo "[OK] $tool_name ready"
    else
        echo "[WARN] Failed → retrying..."
        sleep 2
        eval "$install_cmd" &>/dev/null \
            && echo "[OK] $tool_name installed (retry success)" \
            || echo "[FAIL] $tool_name installation failed"
    fi
}

# ==========================================
# 📦 GO TOOLS (UPDATED)
# ==========================================

update_go_tools() {

    echo "[*] Updating Go-based tools..."

    update_go_tool "nuclei" "go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    update_go_tool "httpx" "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
    update_go_tool "katana" "go install github.com/projectdiscovery/katana/cmd/katana@latest"
    update_go_tool "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
    update_go_tool "gauplus" "go install github.com/bp0lr/gauplus@latest"
    update_go_tool "hakrawler" "go install github.com/hakluke/hakrawler@latest"

    # 🔥 NEW: SubPipe
    update_go_tool "subpipe" "go install github.com/subpipe/subpipe@latest"
}

# ==========================================
# 🌐 EXTERNAL RESOURCES
# ==========================================

update_resources() {

    echo "[*] Checking external resources..."

    # Templates
    if [ -d "$HOME/nuclei-templates/.git" ]; then
        echo "[*] Updating templates..."
        cd "$HOME/nuclei-templates" && git pull --quiet && cd - &>/dev/null
        echo "[OK] Templates updated"
    else
        echo "[*] Cloning templates..."
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates" &>/dev/null \
            && echo "[OK] Templates installed"
    fi

    # ParamSpider
    if [ -d "$HOME/ParamSpider/.git" ]; then
        echo "[*] Updating ParamSpider..."
        cd "$HOME/ParamSpider" && git pull --quiet && cd - &>/dev/null
        echo "[OK] ParamSpider updated"
    else
        echo "[*] Cloning ParamSpider..."
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider" &>/dev/null \
            && echo "[OK] ParamSpider installed"
    fi
}

# ==========================================
# 🤖 AI SETUP (NEW)
# ==========================================

setup_ai_tools() {

    echo "[*] Checking AI tools..."

    if command -v npm &>/dev/null; then
        if ! command -v gemini &>/dev/null; then
            echo "[*] Installing Gemini CLI..."
            npm install -g @google/gemini-cli &>/dev/null \
                && echo "[OK] Gemini installed"
        else
            echo "[OK] Gemini already installed"
        fi
    else
        echo "[WARN] npm not found → AI features limited"
    fi
}

# ==========================================
# 🔌 PLUGIN SYSTEM (NEW)
# ==========================================

setup_plugins() {

    echo "[*] Setting up plugins..."

    PLUGIN_DIR="./plugins"

    if [ ! -d "$PLUGIN_DIR" ]; then
        mkdir -p "$PLUGIN_DIR"
        echo "[OK] Plugin directory created"
    fi

    # Example plugin
    if [ ! -f "$PLUGIN_DIR/example.sh" ]; then
        cat <<EOF > "$PLUGIN_DIR/example.sh"
#!/bin/bash
plugin_post_scan() {
    echo "[PLUGIN] Example plugin executed"
}
EOF
        chmod +x "$PLUGIN_DIR/example.sh"
        echo "[OK] Example plugin added"
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
    echo "⬆️ NucleiFuzzer Smart Update Engine v3.3"
    echo "======================================"

    setup_update_env

    if ! check_network_update; then
        echo "[WARN] Offline → skipping updates"
        return
    fi

    update_go_tools
    update_resources
    setup_ai_tools
    setup_plugins
    cleanup_update

    echo "======================================"
    echo "✅ Update completed successfully"
    echo "======================================"
}
