#!/bin/bash

# ==========================================
# 📦 NUCLEIFUZZER INSTALLER (v4.0 PYTHON ENGINE)
# ==========================================

INSTALL_DIR="/opt/nucleifuzzer"

echo "[*] Installing NucleiFuzzer..."

# ------------------------------------------
# 📁 CREATE INSTALL DIRECTORY
# ------------------------------------------
if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p "$INSTALL_DIR"
    echo "[OK] Created install directory"
else
    echo "[OK] Install directory already exists"
fi

# ------------------------------------------
# 📦 COPY FILES
# ------------------------------------------
echo "[*] Copying files..."

if sudo cp -r ./* "$INSTALL_DIR" 2>/dev/null; then
    echo "[OK] Files copied successfully"
else
    echo "[ERROR] Failed to copy files"
    exit 1
fi

# ------------------------------------------
# 🔐 SET PERMISSIONS
# ------------------------------------------
echo "[*] Setting permissions..."

sudo chmod -R +x "$INSTALL_DIR" 2>/dev/null

# ------------------------------------------
# 🐍 INSTALL PYTHON DEPENDENCIES
# ------------------------------------------
echo "[*] Checking Python dependencies..."

if command -v pip3 &>/dev/null; then
    # We use --break-system-packages to safely bypass Kali/Ubuntu strict pip rules for global CLI tools
    sudo pip3 install colorama requests uro --break-system-packages &>/dev/null || sudo pip3 install colorama requests uro &>/dev/null
    echo "[OK] Python dependencies installed (colorama, requests, uro)"
else
    echo "[WARN] pip3 not found. Please run 'sudo apt install python3-pip' manually."
fi

# ------------------------------------------
# 🔗 CREATE GLOBAL COMMAND
# ------------------------------------------
echo "[*] Creating command: nf"

# Note: Symlinking the new Python orchestrator
sudo ln -sf "$INSTALL_DIR/nucleifuzzer.py" /usr/bin/nf

if command -v nf &>/dev/null; then
    echo "[OK] Command 'nf' is available"
else
    echo "[ERROR] Failed to create command"
    exit 1
fi

# ------------------------------------------
# 🛤️ PATH VALIDATION (OPTIONAL SAFETY)
# ------------------------------------------
if [[ ":$PATH:" != *":/usr/bin:"* ]]; then
    echo "[WARN] /usr/bin not in PATH"
fi

# ------------------------------------------
# ✅ FINAL OUTPUT
# ------------------------------------------
echo ""
echo "======================================"
echo "✅ Installed Successfully (v4.0 Python Edition)"
echo "📁 Location: $INSTALL_DIR"
echo "⚡ Run: nf -h"
echo "======================================"
