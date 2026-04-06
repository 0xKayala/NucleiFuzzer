#!/bin/bash

# ==========================================
# 🔧 NUCLEIFUZZER DEPENDENCY ENGINE (v3.0)
# ==========================================

# ==========================================
# 🌐 NETWORK FIX (WSL + GO SAFE)
# ==========================================

fix_network() {

    echo "[*] Fixing network issues..."

    # Disable IPv6 (fix Go issues in WSL)
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 &>/dev/null

    # Fix DNS (WSL issue)
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null

    # Force Go DNS resolver
    export GODEBUG=netdns=go

    echo "[OK] Network configured (IPv4 forced)"
}

# ==========================================
# 🌐 SMART INTERNET CHECK (WSL SAFE)
# ==========================================

check_internet() {

    echo "[*] Checking internet connectivity..."

    # Method 1: curl
    if command -v curl &>/dev/null; then
        curl -Is https://google.com --max-time 5 &>/dev/null && {
            echo "[OK] Internet working (curl)"
            return 0
        }
    fi

    # Method 2: wget
    if command -v wget &>/dev/null; then
        wget -q --spider https://google.com && {
            echo "[OK] Internet working (wget)"
            return 0
        }
    fi

    # Method 3: DNS fallback
    getent hosts google.com &>/dev/null && {
        echo "[OK] DNS working (partial connectivity)"
        return 0
    }

    echo "[WARN] No internet connection"
    return 1
}

# ==========================================
# 📦 GENERIC INSTALLER
# ==========================================

install_tool() {
    local name="$1"
    local cmd="$2"

    if ! command -v "$name" &>/dev/null; then
        echo "[*] Installing: $name"
        eval "$cmd" || {
            echo "[ERROR] Failed to install $name"
            return 1
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
# 🧠 GO INSTALL (STABLE)
# ==========================================

install_go_latest() {

    REQUIRED_VERSION="1.25.8"

    if command -v go &>/dev/null; then
        CURRENT_VERSION=$(go version | awk '{print $3}' | sed 's/go//')

        if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" == "$REQUIRED_VERSION" ]]; then
            echo "[OK] Go version OK ($CURRENT_VERSION)"
            return
        else
            echo "[!] Upgrading Go ($CURRENT_VERSION → $REQUIRED_VERSION)"
        fi
    else
        echo "[*] Installing Go..."
    fi

    sudo rm -rf /usr/local/go

    wget -q https://go.dev/dl/go1.26.1.linux-amd64.tar.gz -O /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz

    export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
    export GOTOOLCHAIN=local

    echo "[OK] Go installed: $(go version)"
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
        pipx install uro
    else
        if command -v apt &>/dev/null; then
            sudo apt install -y pipx
            pipx ensurepath
            export PATH="$HOME/.local/bin:$PATH"
            pipx install uro
        else
            pip3 install --break-system-packages uro
        fi
    fi

    export PATH="$HOME/.local/bin:$PATH"

    command -v uro &>/dev/null || {
        echo "[ERROR] uro installation failed"
        return 1
    }
}

# ==========================================
# 🚀 MAIN DEPENDENCY SETUP
# ==========================================

setup_dependencies() {

    echo "======================================"
    echo "🔧 NucleiFuzzer Dependency Engine"
    echo "======================================"

    # Fix PATH first (CRITICAL)
    export PATH="/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH"

    fix_network

    # Smart internet check
    if ! check_internet; then
        echo "[WARN] Offline mode → skipping installations"
        return
    fi

    echo "[*] Installing system dependencies..."
    sudo apt update -y &>/dev/null
    sudo apt install -y python3 python3-pip jq git curl wget &>/dev/null

    install_go_latest

    # Python modules
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

    echo "[*] Setting up external tools..."

    # ParamSpider
    if [ ! -d "$HOME/ParamSpider" ]; then
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider"
    else
        echo "[OK] ParamSpider exists"
    fi

    # Templates
    if [ ! -d "$HOME/nuclei-templates" ]; then
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates"
    else
        echo "[OK] Templates exist"
    fi

    echo "======================================"
    echo "✅ Dependencies Ready"
    echo "======================================"
}
