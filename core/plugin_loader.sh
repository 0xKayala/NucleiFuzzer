#!/bin/bash

# ==========================================
# 🔌 NUCLEIFUZZER PLUGIN LOADER (v3.3 PRO)
# ==========================================

# ------------------------------------------
# 📦 GLOBAL PLUGIN STORAGE
# ------------------------------------------

PLUGINS=()

# ------------------------------------------
# 📂 LOAD PLUGINS
# ------------------------------------------

load_plugins() {

    echo -e "${BLUE}[*] Loading plugins...${RESET}"

    if [ ! -d "$PLUGIN_DIR" ]; then
        echo "[WARN] Plugin directory not found → $PLUGIN_DIR"
        return
    fi

    for plugin in "$PLUGIN_DIR"/*.sh; do

        [ -f "$plugin" ] || continue

        # Reset variables to avoid leakage
        unset plugin_name
        unset plugin_stage

        # Source plugin safely
        source "$plugin"

        # Validate plugin
        if [ -z "$plugin_name" ] || [ -z "$plugin_stage" ]; then
            echo "[WARN] Invalid plugin skipped → $(basename "$plugin")"
            continue
        fi

        # Check if enabled
        if [[ "$ENABLED_PLUGINS" != *"$plugin_name"* ]]; then
            continue
        fi

        PLUGINS+=("$plugin")
    done

    echo "[OK] Plugins loaded: ${#PLUGINS[@]}"
}

# ------------------------------------------
# ▶️ EXECUTE PLUGINS BY STAGE
# ------------------------------------------

run_plugins() {

    local stage="$1"

    if [ ${#PLUGINS[@]} -eq 0 ]; then
        return
    fi

    echo -e "${CYAN}[*] Running plugins ($stage)...${RESET}"

    for plugin in "${PLUGINS[@]}"; do

        # Reset to avoid conflicts
        unset plugin_name
        unset plugin_stage

        source "$plugin"

        if [ "$plugin_stage" != "$stage" ]; then
            continue
        fi

        echo "[PLUGIN] → $plugin_name"

        # Safe execution
        if declare -f run_plugin >/dev/null; then
            run_plugin
        else
            echo "[WARN] $plugin_name has no run_plugin()"
        fi
    done
}

# ------------------------------------------
# 🧪 DEBUG MODE (OPTIONAL)
# ------------------------------------------

list_plugins() {

    echo "Loaded Plugins:"
    for plugin in "${PLUGINS[@]}"; do
        source "$plugin"
        echo "- $plugin_name ($plugin_stage)"
    done
}
