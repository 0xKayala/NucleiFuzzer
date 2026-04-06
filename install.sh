#!/bin/bash

# ==========================================
# 📦 NUCLEIFUZZER INSTALLER (PRO VERSION)
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
# 🔗 CREATE GLOBAL COMMAND
# ------------------------------------------
echo "[*] Creating command: nf"

sudo ln -sf "$INSTALL_DIR/nucleifuzzer.sh" /usr/bin/nf

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
echo "✅ Installed Successfully"
echo "📁 Location: $INSTALL_DIR"
echo "⚡ Run: nf -h"
echo "======================================"
