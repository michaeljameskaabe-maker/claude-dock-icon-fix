# Claude Dock Icon Fix

Keeps the **Claude web app's dock icon** from turning into a blank box on Linux after Chromium updates. A tiny systemd *user* watcher puts the icon back automatically, with no root and no polling.

## The problem

If you install claude.ai as an app from Chromium (*Install app* / *Open in app*), Chromium writes a launcher like:

```
~/.local/share/applications/chrome-<app-id>-Default.desktop
```

With the **Chromium snap**, its `Icon=` line points inside a version-numbered folder:

```
Icon=/home/you/snap/chromium/3549/.local/share/icons/hicolor/256x256/apps/chrome-<app-id>-Default.png
```

The next snap update deletes that folder (`3549`), so GNOME draws a blank dock icon. Chromium rewrites the launcher again on later updates, so fixing it once doesn't last.

## The fix

- `fix-claude-dock-icon` finds every launcher named **Claude** created by Chromium, Chrome, Edge or Brave.
- It makes a rounded copy of the app's own icon (taken from the browser's local web-app data) at `~/.local/share/icons/claude-app-<app-id>.png`.
- It points the launcher's `Icon=` at that copy.
- A systemd path unit watches `~/.local/share/applications` and re-runs the script whenever a launcher is written. That covers browser rewrites, and also reinstalls that change the app ID.
- The script only edits a launcher whose `Icon=` line is wrong. Its own edit triggers one extra no-op run, so it never loops.

No logo file is shipped in this repo. The icon is built on your machine from the copy your browser already downloaded with the app.

## Install

```bash
git clone https://github.com/michaeljameskaabe-maker/claude-dock-icon-fix.git
cd claude-dock-icon-fix
./install.sh
```

This installs `~/.local/bin/fix-claude-dock-icon` and `~/.config/systemd/user/claude-dock-icon.{path,service}`, fixes the icon once, and enables the watcher.

Requirements:
- Linux with systemd user sessions. Tested on Ubuntu with GNOME and the Chromium snap.
- `python3`. With `python3-pil` the icon gets rounded corners; without it, a square icon is used.

## Uninstall

```bash
./uninstall.sh                 # stop the watcher, remove the script and units
./uninstall.sh --remove-icons  # also delete the generated icons
```

Without `--remove-icons`, launchers keep pointing at the generated icon, which keeps working.

## Commands

| What | Command |
|---|---|
| Is the watcher running? | `systemctl --user status claude-dock-icon.path` |
| Fix the icon now by hand | `~/.local/bin/fix-claude-dock-icon` |
| Turn the watcher off / on | `systemctl --user disable --now claude-dock-icon.path` / `enable --now` |
| Show the current icon line | `grep ^Icon= ~/.local/share/applications/chrome-*.desktop` |
| Use for a different web app | `CLAUDE_APP_NAME="Other App" ~/.local/bin/fix-claude-dock-icon` (one-off run; the watcher still uses the default name) |

## Troubleshooting

- **Still blank.**
  - Run `~/.local/bin/fix-claude-dock-icon` and read its output.
  - "no icon found" means the browser's web-app icon folder wasn't found. Supported locations are the snap Chromium, Chromium, Chrome, Edge and Brave profiles under `~/snap/chromium/common/chromium` or `~/.config/...`.
- **Changed the icon image but the dock shows the old one.** GNOME Shell caches icons by file path. Delete `~/.local/share/icons/claude-app-*.png` and run the script; a fresh file is generated. If the old image persists, log out and back in.
- **Why not `Icon=<theme name>`?** GNOME Shell only notices new theme icons after its icon cache refreshes, often not until you log in again. An absolute path shows up immediately.

## License

MIT for the scripts in this repo. "Claude" and the Claude logo are trademarks of Anthropic. This project is not affiliated with Anthropic, and it does not distribute the logo.
