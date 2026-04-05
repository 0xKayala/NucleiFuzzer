#!/bin/bash

# ==========================================
# 🔧 DEPENDENCY INSTALLER (FINAL STABLE VERSION)
# ==========================================

# ==========================================
# 🌐 NETWORK FIX (WSL + GO ISSUE FIX)
# ==========================================

fix_network() {

    echo "[*] Fixing network issues..."

    # Disable IPv6 (prevents Go failures)
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 &>/dev/null

    # Fix DNS (WSL issue)
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null

    # Force Go DNS resolver
    export GODEBUG=netdns=go

    echo "[OK] Network configured (IPv4 forced)"
}

# ==========================================
# 📦 GENERIC INSTALLER
# ==========================================

install_tool() {
    local name="$1"
    local cmd="$2"

    if ! command -v "$name" &>/dev/null; then
        echo "[*] Installing missing tool: $name"
        eval "$cmd" || {
            echo "[ERROR] Failed to install $name"
            exit 1
        }
    else
        echo "[OK] $name already installed"
    fi
}

# ==========================================
# 🐍 PYTHON MODULE INSTALLER
# ==========================================

install_python_module() {
    local module="$1"

    python3 -c "import $module" &>/dev/null || {
        echo "[*] Installing Python module: $module"
        pip3 install --break-system-packages "$module"
    }
}

# ==========================================
# 🧠 GO INSTALL (STABLE VERSION)
# ==========================================

install_go_latest() {

    REQUIRED_VERSION="1.25.8"

    if command -v go &>/dev/null; then
        CURRENT_VERSION=$(go version | awk '{print $3}' | sed 's/go//')

        if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" == "$REQUIRED_VERSION" ]]; then
            echo "[OK] Go version is sufficient ($CURRENT_VERSION)"
            return
        else
            echo "[!] Go outdated ($CURRENT_VERSION) → upgrading..."
        fi
    else
        echo "[*] Go not found → installing..."
    fi

    # Remove old Go
    sudo rm -rf /usr/local/go

    # Install fresh Go
    wget -q https://go.dev/dl/go1.25.8.linux-amd64.tar.gz -O /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz

    export PATH="/usr/local/go/bin:$PATH"
    export PATH="$HOME/go/bin:$PATH"

    # 🔥 CRITICAL FIX (prevents toolchain auto-download failure)
    export GOTOOLCHAIN=local

    echo "[+] Go installed: $(go version)"
}

# ==========================================
# 🧠 SMART URO INSTALLER
# ==========================================

install_uro() {

    if command -v uro &>/dev/null; then
        echo "[OK] uro already installed"
        return
    fi

    echo "[*] Installing uro..."

    if command -v pipx &>/dev/null; then
        echo "[+] Using pipx"
        pipx install uro
    else
        echo "[!] pipx not found → installing..."

        if command -v apt &>/dev/null; then
            sudo apt install -y pipx
            pipx ensurepath
            export PATH="$HOME/.local/bin:$PATH"
            pipx install uro
        else
            echo "[!] Falling back to pip3"
            pip3 install --break-system-packages uro
        fi
    fi

    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v uro &>/dev/null; then
        echo "[ERROR] uro installation failed"
        exit 1
    fi
}

# ==========================================
# 🌐 NETWORK CHECK
# ==========================================

check_network() {
    if ! ping -c 1 google.com &>/dev/null; then
        echo "[ERROR] No internet connection"
        exit 1
    fi
}

# ==========================================
# 🚀 MAIN DEPENDENCY SETUP
# ==========================================

setup_dependencies() {

    echo "======================================"
    echo "🔧 NucleiFuzzer Dependency Engine"
    echo "======================================"

    fix_network
    check_network

    echo "[*] Installing system dependencies..."
    sudo apt update
    sudo apt install -y python3 python3-pip jq git curl wget

    install_go_latest

    # PATH FIX (VERY IMPORTANT FOR WSL)
    export PATH="/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"

    echo "[*] Installing Python modules..."
    install_python_module "requests"
    install_python_module "urllib3"

    echo "[*] Installing Go tools..."

    # 🔥 Stable Go proxy setup
    export GOPROXY=https://proxy.golang.org,direct
    export GOSUMDB=off

    go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    go install github.com/tomnomnom/waybackurls@latest
    go install github.com/bp0lr/gauplus@latest
    go install github.com/hakluke/hakrawler@latest

    install_uro

    echo "[*] Setting up external tools..."

    # ParamSpider
    if [ ! -d "$HOME/ParamSpider" ]; then
        echo "[*] Cloning ParamSpider..."
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider"
    else
        echo "[OK] ParamSpider already exists"
    fi

    # Nuclei Templates
    if [ ! -d "$HOME/nuclei-templates" ]; then
        echo "[*] Cloning nuclei templates..."
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates"
    else
        echo "[OK] Nuclei templates already exist"
    fi

    echo "======================================"
    echo "✅ Dependencies Installed Successfully"
    echo "======================================"
}
