#!/bin/bash

run_update() {

    echo "======================================"
    echo "⬆️ NucleiFuzzer Update Engine"
    echo "======================================"

    echo "[*] Updating Go tools..."

    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    go install -v github.com/projectdiscovery/katana/cmd/katana@latest
    go install github.com/tomnomnom/waybackurls@latest
    go install github.com/bp0lr/gauplus@latest
    go install github.com/hakluke/hakrawler@latest

    echo "[*] Updating Nuclei templates..."

    if [ -d "$HOME/nuclei-templates" ]; then
        cd "$HOME/nuclei-templates" && git pull
    else
        git clone https://github.com/projectdiscovery/nuclei-templates "$HOME/nuclei-templates"
    fi

    echo "[*] Updating ParamSpider..."

    if [ -d "$HOME/ParamSpider" ]; then
        cd "$HOME/ParamSpider" && git pull
    else
        git clone https://github.com/0xKayala/ParamSpider "$HOME/ParamSpider"
    fi

    echo "[*] Cleaning Go cache..."
    go clean -modcache

    echo "======================================"
    echo "✅ Update completed successfully"
    echo "======================================"
}
