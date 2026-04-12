#!/bin/bash

# ==========================================
# 🔧 NUCLEIFUZZER DEPENDENCY ENGINE (v3.3 PRO)
# ==========================================

# ------------------------------------------
# ⚡ FAST CHECK MODE (NEW)
# ------------------------------------------

FAST_CHECK="${FAST_CHECK:-true}"

# ------------------------------------------
# 🌐 NETWORK FIX (SAFE + OPTIONAL)
# ------------------------------------------

fix_network() {

    if [ "$FAST_CHECK" = true ]; then
        return
    fi

    echo "[*] Fixing network issues..."

    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 &>/dev/null

    export GODEBUG=netdns=go

    echo "[OK] Network configured (IPv4 forced)"
}

# ------------------------------------------
# 🌐 INTERNET CHECK
# ------------------------------------------

check_internet() {

    if curl -Is https://google.com --max-time 5 &>/dev/null; then
        return 0
    fi

    if wget -q --spider https://google.com; then
        return 0
    fi

    return 1
}

# ------------------------------------------
# 📦 SMART INSTALLER
# ------------------------------------------

install_tool() {
    local name="$1"
    local cmd="$2"

    if command -v "$name" &>/dev/null; then
        echo "[OK] $name already installed"
        return
    fi

    echo "[*] Installing: $name"
    eval "$cmd" &>/dev/null || {
        echo "[ERROR] Failed to install $name"
    }
}

# ------------------------------------------
# 🐍 PYTHON INSTALLER
# ------------------------------------------

install_python_module() {
    local module="$1"

    python3 -c "import $module" &>/dev/null && return

    echo "[*] Installing Python module: $module"
    pip3 install --break-system-packages "$module" &>/dev/null
}

# ------------------------------------------
# 🧠 GO INSTALL (SMART)
# ------------------------------------------

install_go() {

    if command -v go &>/dev/null; then
        echo "[OK] Go already installed ($(go version | awk '{print $3}'))"
        return
    fi

    echo "[*] Installing Go..."

    wget -q https://go.dev/dl/go1.26.1.linux-amd64.tar.gz -O /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz

    export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"

    echo "[OK] Go installed"
}

# ------------------------------------------
# 🧠 URO INSTALL
# ------------------------------------------

install_uro() {

    if command -v uro &>/dev/null; then
        echo "[OK] uro already installed"
        return
    fi

    echo "[*] Installing uro..."

    if command -v pipx &>/dev/null; then
        pipx install uro &>/dev/null
    else
        pip3 install --break-system-packages uro &>/dev/null
    fi
}

# ------------------------------------------
# 🔌 PLUGIN DEPENDENCIES (NEW)
# ------------------------------------------

install_plugins_deps() {

    echo "[*] Checking plugin dependencies..."

    # SubPipe
    if [[ "$ENABLED_PLUGINS" == *"subpipe"* ]]; then
        install_tool "subpipe" "go install github.com/subpipe/subpipe@latest"
    fi

    # Gemini CLI
    if [[ "$ENABLED_PLUGINS" == *"ai_filter"* ]]; then
        if ! command -v gemini &>/dev/null; then
            echo "[*] Installing Gemini CLI..."
            npm install -g @google/gemini-cli &>/dev/null
        else
            echo "[OK] gemini already installed"
        fi
    fi
}

# ------------------------------------------
# 🌐 EXTERNAL RESOURCES
# ------------------------------------------

setup_resources() {

    echo "[*] Setting up external tools..."

    # ParamSpider
    if [ ! -d "$HOME/ParamSpider" ]; then
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider" &>/dev/null
    else
        echo "[OK] ParamSpider exists"
    fi

    # Nuclei Templates
    if [ ! -d "$TEMPLATE_DIR" ]; then
        git clone https://github.com/projectdiscovery/nuclei-templates "$TEMPLATE_DIR" &>/dev/null
    else
        echo "[OK] Templates exist"
    fi
}

# ------------------------------------------
# 🚀 MAIN ENGINE
# ------------------------------------------

setup_dependencies() {

    echo "======================================"
    echo "🔧 NucleiFuzzer Dependency Engine (v3.3)"
    echo "======================================"

    export PATH="/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"

    fix_network

    if ! check_internet; then
        echo "[WARN] Offline mode → skipping installations"
        return
    fi

    echo "[*] Installing system dependencies..."

    sudo apt update -y &>/dev/null
    sudo apt install -y python3 python3-pip jq git curl wget npm &>/dev/null

    install_go

    # Python
    install_python_module "requests"
    install_python_module "urllib3"

    echo "[*] Installing Go tools..."

    export GOPROXY=https://proxy.golang.org,direct
    export GOSUMDB=off

    install_tool "nuclei" "go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    install_tool "httpx" "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
    install_tool "katana" "go install github.com/projectdiscovery/katana/cmd/katana@latest"
    install_tool "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
    install_tool "gauplus" "go install github.com/bp0lr/gauplus@latest"
    install_tool "hakrawler" "go install github.com/hakluke/hakrawler@latest"

    install_uro

    # 🔌 Plugin tools
    install_plugins_deps

    # 🌐 External resources
    setup_resources

    echo "======================================"
    echo "✅ Dependencies Ready"
    echo "======================================"
}
