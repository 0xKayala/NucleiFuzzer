#!/bin/bash

INSTALL_DIR="/opt/nucleifuzzer"

echo "[*] Installing NucleiFuzzer..."

# Copy entire project
sudo mkdir -p $INSTALL_DIR
sudo cp -r * $INSTALL_DIR

# Create symlink
sudo ln -sf $INSTALL_DIR/nucleifuzzer.sh /usr/bin/nf

# Make executable
sudo chmod +x $INSTALL_DIR/nucleifuzzer.sh

echo "✅ NucleiFuzzer has been installed successfully!"
echo "Now Enter the command 'nf -h' to run the tool."
