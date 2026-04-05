#!/bin/bash

# ==========================================
# 🔧 DEPENDENCY INSTALLER (SMART VERSION)
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

# ==========================================
# 🧠 SMART URO INSTALLER
# ==========================================

install_uro() {

    if command -v uro &>/dev/null; then
        return
    fi

    echo "[*] Installing uro..."

    # Step 1: Check pipx
    if command -v pipx &>/dev/null; then
        echo "[+] Using pipx to install uro"
        pipx install uro

    else
        echo "[!] pipx not found"

        # Step 2: Install pipx if possible
        if command -v apt &>/dev/null; then
            echo "[*] Installing pipx via apt..."
            sudo apt install -y pipx
            pipx ensurepath

            export PATH="$HOME/.local/bin:$PATH"

            echo "[+] Using pipx after install"
            pipx install uro

        else
            # Step 3: Fallback to pip
            echo "[!] Falling back to pip3 installation"
            pip3 install --break-system-packages uro

            # Fix PATH
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi

    # Final check
    if ! command -v uro &>/dev/null; then
        echo "[ERROR] uro installation failed. Please install manually."
        exit 1
    fi
}

# ==========================================
# 🚀 MAIN DEP SETUP
# ==========================================

setup_dependencies() {

    echo "[*] Checking dependencies..."

    # System tools
    install_tool "python3" "sudo apt install -y python3"
    install_tool "pip3" "sudo apt install -y python3-pip"
    install_tool "jq" "sudo apt install -y jq"
    install_tool "git" "sudo apt install -y git"

    # Python modules
    install_python_module "requests"
    install_python_module "urllib3"

    # Go tools
    install_tool "nuclei" "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    install_tool "httpx" "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
    install_tool "katana" "go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
    install_tool "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
    install_tool "gauplus" "go install github.com/bp0lr/gauplus@latest"
    install_tool "hakrawler" "go install github.com/hakluke/hakrawler@latest"

    # 🔥 FIXED URO INSTALL
    install_uro

    # ParamSpider
    if [ ! -d "$HOME/ParamSpider" ]; then
        echo "[*] Cloning ParamSpider..."
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider"
    fi

    # Nuclei Templates
    if [ ! -d "$HOME/nuclei-templates" ]; then
        echo "[*] Cloning nuclei templates..."
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates"
    fi

    # PATH FIX (VERY IMPORTANT FOR WSL)
    export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"

    echo "[*] Dependencies ready ✅"
}
