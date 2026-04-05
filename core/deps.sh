#!/bin/bash

# ==========================================
# 🔧 DEPENDENCY INSTALLER (FINAL VERSION)
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
    fi
}

install_python_module() {
    local module="$1"

    python3 -c "import $module" &>/dev/null || {
        echo "[*] Installing Python module: $module"
        pip3 install --break-system-packages "$module"
    }
}

install_go() {
    if ! command -v go &>/dev/null; then
        echo "[*] Installing Go..."
        sudo apt install -y golang
    fi
}

# ==========================================
# 🧠 SMART URO INSTALLER
# ==========================================

install_uro() {

    if command -v uro &>/dev/null; then
        return
    fi

    echo "[*] Installing uro..."

    if command -v pipx &>/dev/null; then
        echo "[+] Using pipx"
        pipx install uro
    else
        echo "[!] pipx not found → installing..."
        sudo apt install -y pipx
        pipx ensurepath
        export PATH="$HOME/.local/bin:$PATH"
        pipx install uro
    fi

    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v uro &>/dev/null; then
        echo "[ERROR] uro installation failed"
        exit 1
    fi
}

# ==========================================
# 🚀 MAIN DEP SETUP
# ==========================================

setup_dependencies() {

    echo "[*] Checking dependencies..."

    install_tool "python3" "sudo apt install -y python3"
    install_tool "pip3" "sudo apt install -y python3-pip"
    install_tool "jq" "sudo apt install -y jq"
    install_tool "git" "sudo apt install -y git"

    install_go

    # PATH FIX (VERY IMPORTANT)
    export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"

    install_tool "nuclei" "go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    install_tool "httpx" "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
    install_tool "katana" "go install github.com/projectdiscovery/katana/cmd/katana@latest"
    install_tool "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
    install_tool "gauplus" "go install github.com/bp0lr/gauplus@latest"
    install_tool "hakrawler" "go install github.com/hakluke/hakrawler@latest"

    install_uro

    # ParamSpider
    if [ ! -d "$HOME/ParamSpider" ]; then
        echo "[*] Cloning ParamSpider..."
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider"
    fi

    # Templates
    if [ ! -d "$HOME/nuclei-templates" ]; then
        echo "[*] Cloning nuclei templates..."
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates"
    fi

    echo "[*] Dependencies ready ✅"
}
