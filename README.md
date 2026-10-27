# BSPWM-machineslego

**English** | [Русский](./README.ru.md)

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![PipeWire](https://img.shields.io/badge/PipeWire-Audio-blue?logo=pipewire&logoColor=white)
![BSPWM](https://img.shields.io/badge/WM-BSPWM-black)
![License](https://img.shields.io/badge/License-MIT-green)

A strict, flat desktop environment based on BSPWM for Debian 13 Trixie, styled in the Tokyo Night palette.

![Desktop](screenshots/desktop.png)

<details>
<summary><b>Show more screenshots</b></summary>
<br>

![Workspace & Notifications](screenshots/workspace+notify.png)
![Rofi](screenshots/rofi-showcase.png)
![Wi-Fi Manager](screenshots/wifi-manager.png)

</details>

## ✨ Features

- **Native Modules First:** Polybar uses stock `internal/battery`, `internal/backlight`, `internal/network`, and `internal/pulseaudio`. Zero background bash loops.
- **On-Demand Scripts:** Custom logic (Wi-Fi manager, Rofi menus, screenshots) runs only when triggered by a hotkey and exits immediately.
- **Smooth & Flat:** Hyprland-style window animations via Picom, no blur, strict Tokyo Night colors.
- **Smart Volume OSD:** Volume notifications dynamically change color based on level.
- **Workflow:** Clipboard history (CopyQ), Notification history (Rofi), quick screenshots to clipboard, and a comprehensive cheatsheet.
- **Stability:** Autostart processes (`picom`, `dunst`, `lxpolkit`, etc.) are protected against duplication via `pgrep` and `pkill`.

## 📦 Structure

```text
BSPWM-machineslego/
├── config/                 # Symlinks to ~/.config/*
│   ├── bspwm, dunst, picom, rofi, alacritty...
│   ├── polybar/
│   │   ├── config.ini      # Stock modules + native battery/backlight
│   │   └── scripts/
│   │       └── power-profile.sh    # PPD profile reader
│   └── sxhkd/
│       ├── sxhkdrc         # Keybindings
│       └── scripts/        # battery (Rofi details), wifi, powermenu, etc.
├── home/                   # Symlinks to ~/*
├── system/                 # Copied to /etc
├── scripts/                # install.sh, link.sh, unlink.sh
├── TODO.md                 # Planned features
└── wallpapers/
```

## 📋 Requirements

- **OS:** Debian 13 Trixie.
- **Utilities:** `git`, `sudo`, internet access.
- **Audio:** Optimized for **PipeWire**.
- **Sudo:** Required for installing packages and copying configs to `/etc`.

## 🛠 Installation

```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```
- **No `/etc` changes:** `./scripts/link.sh`
- **Rollback:** `./scripts/unlink.sh`
- **Launch:** `startx` (or via LightDM).

### ⚙️ Post-Install Customization

**Wi-Fi Manager:**
The `wifi.sh` script is pre-configured for my devices. Open `~/.config/sxhkd/scripts/wifi.sh` and add your interface name (e.g., `wlan0`, `wlp3s0`) to the `if/elif` block. Change `HOTSPOT_SSID` and `HOTSPOT_PASSWORD` at the top of the script.

**Laptop Lid Behavior:**
By default, closing the lid suspends the system. To change it to **lock without suspend**:
```bash
sudo rm /etc/systemd/logind.conf.d/10-lid-suspend.conf
sudo tee /etc/systemd/logind.conf.d/10-lid-lock.conf > /dev/null <<'EOF'
[Login]
HandleLidSwitch=lock
HandleLidSwitchExternalPower=lock
EOF
sudo systemctl kill -s HUP systemd-logind
```

## ⌨️ Keybindings

**Full cheatsheet:** `Super + /` (Rofi).

| Keybinding | Action |
|---|---|
| `Super + Return` | Terminal (Alacritty) |
| `Super + D` | Launcher (Rofi) |
| `Super + /` | Cheatsheet |
| `Super + Alt + N` | Wi-Fi Manager |
| `Super + Shift + Q` | Power Menu (Rofi) |
| `Super + Alt + B` | Battery Details (Rofi) |
| `Super + Alt + H` | Notification History |
| `Super + Ctrl + V` | Clipboard History (CopyQ) |
| `Super + F1/F2/F3` | Screenshots (Full/Window/Delay) |
| `Super + Shift + S` | Screenshot (Area) |
| `Super + H/J/K/L` | Move floating window (Vim-style) |
| `Super + 1…0` | Switch workspaces |
| `Super + Shift + 1…0` | Move window to workspace |
| `Super + Alt + Shift + R` | Reload Entire System |

## 🐛 Known Issues (Picom & UI)

- **Dunst Stack Animation:** Only the first notification animates. Second and subsequent notifications in the stack appear instantly due to a known **Picom 12.5** conflict with Dunst's positioning.
- **Context Menu Shadows:** Telegram (Flatpak) and Firefox context menus have poorly rendered shadows. This is why they are explicitly excluded in `picom.conf` (`shadow = false`).
- **AMD Sleep:** On Ryzen 7000-series, suspend may fail. Add `mem_sleep_default=s2idle` to GRUB if the laptop shuts down instead of sleeping.

## 📄 License

MIT