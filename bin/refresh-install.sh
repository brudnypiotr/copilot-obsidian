#!/usr/bin/env bash
# refresh-install.sh — uninstall and reinstall copilot-obsidian from a local path.
#
# Copilot CLI direct-installs cache a frozen tarball at
# ~/.copilot/installed-plugins/_direct/<name>/ and are NOT refreshed when the
# source repo is updated via `git pull`. This script forces a refresh.
#
# Usage:
#   bash bin/refresh-install.sh           # uses $PWD as the source
#   bash bin/refresh-install.sh /path     # uses /path as the source

set -euo pipefail

SOURCE="${1:-$PWD}"

if [ ! -f "$SOURCE/plugin.json" ]; then
  echo "error: $SOURCE/plugin.json not found — not a copilot-obsidian source dir" >&2
  exit 1
fi

echo "→ uninstalling copilot-obsidian (if installed)"
copilot plugin uninstall copilot-obsidian 2>/dev/null || true

echo "→ installing copilot-obsidian from $SOURCE"
copilot plugin install "$SOURCE"

echo "→ verifying"
copilot plugin list | grep -i copilot-obsidian || {
  echo "warning: plugin not listed after install" >&2
  exit 1
}

echo "✓ refresh complete"
