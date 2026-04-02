#!/bin/bash

INSTALL_DIR="/opt/nucleifuzzer"

echo "[*] Installing NucleiFuzzer..."

sudo mkdir -p $INSTALL_DIR

sudo cp -r core config $INSTALL_DIR
sudo cp nucleifuzzer.sh $INSTALL_DIR

sudo ln -sf $INSTALL_DIR/nucleifuzzer.sh /usr/bin/nf
sudo chmod +x /usr/bin/nf

echo "======================================"
echo "✅ Installed Successfully"
echo "📁 Location: $INSTALL_DIR"
echo "⚡ Run: nf -d example.com --ai"
echo "======================================"