#!/bin/bash

INSTALL_DIR="/opt/nucleifuzzer"

echo "[*] Installing NucleiFuzzer..."

# Create install directory
sudo mkdir -p "$INSTALL_DIR"

# Copy all project files (IMPORTANT: includes core + config)
sudo cp -r ./* "$INSTALL_DIR"

# Make main script executable
sudo chmod +x "$INSTALL_DIR/nucleifuzzer.sh"

# Create symlink
sudo ln -sf "$INSTALL_DIR/nucleifuzzer.sh" /usr/bin/nf

echo ""
echo "======================================"
echo "✅ NucleiFuzzer Installed Successfully"
echo "📍 Location: $INSTALL_DIR"
echo "⚡ Run using: nf -h"
echo "======================================"
