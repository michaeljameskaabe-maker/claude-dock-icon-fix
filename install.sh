#!/usr/bin/env bash
# Install the Claude dock icon fix for the current user (no root needed).
set -euo pipefail
SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user"
install -m 755 "$SRC/fix-claude-dock-icon" "$HOME/.local/bin/"
install -m 644 "$SRC/systemd/claude-dock-icon.path" "$SRC/systemd/claude-dock-icon.service" \
  "$HOME/.config/systemd/user/"
"$HOME/.local/bin/fix-claude-dock-icon" || true
if systemctl --user daemon-reload 2>/dev/null; then
  systemctl --user enable --now claude-dock-icon.path
  systemctl --user restart claude-dock-icon.path
  echo "Watcher active: $(systemctl --user is-active claude-dock-icon.path)"
else
  echo "No systemd user session; the icon was fixed once. Re-run ~/.local/bin/fix-claude-dock-icon after browser updates." >&2
fi
python3 -c 'import PIL' 2>/dev/null || echo "Tip: install python3-pil for rounded icon corners (square icon used meanwhile)."
