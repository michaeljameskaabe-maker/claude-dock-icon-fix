#!/usr/bin/env bash
# Remove the Claude dock icon fix. Launchers keep pointing at the stable icon,
# which still works; pass --remove-icons to delete those too (the browser will
# fix the launcher the next time it rewrites it).
set -u
systemctl --user disable --now claude-dock-icon.path 2>/dev/null
rm -f "$HOME/.config/systemd/user/claude-dock-icon.path" \
      "$HOME/.config/systemd/user/claude-dock-icon.service" \
      "$HOME/.local/bin/fix-claude-dock-icon"
systemctl --user daemon-reload 2>/dev/null
if [[ ${1:-} == --remove-icons ]]; then
  rm -f "${XDG_DATA_HOME:-$HOME/.local/share}"/icons/claude-app-*.png
fi
echo "Claude dock icon fix removed."
