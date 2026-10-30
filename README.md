# BSPWM-machineslego

**English** | [Русский](./README.ru.md)

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![PipeWire](https://img.shields.io/badge/PipeWire-Audio-blue?logo=pipewire&logoColor=white)
![BSPWM](https://img.shields.io/badge/WM-BSPWM-black)
![Fish](https://img.shields.io/badge/Shell-Fish-green)
![License](https://img.shields.io/badge/License-MIT-green)

A strict, flat desktop environment based on BSPWM for Debian 13 Trixie, styled in the Tokyo Night palette.

---

## 🧭 Rule of the repository

> **If a stock module solves it, don't write a script.**
> **If a script is needed, run it on-demand and exit immediately.**
> **No background loops. No dead code.**

Every line of code and every running process must justify its existence. This rule is the reason why some features are intentionally **not** implemented — and why others were removed after being tried (see [TODO.md](./TODO.md) for the list of rejected ideas).

---

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
- **Wallpapers — `feh` only:** No picker script, no state file, no ImageMagick previews. Two static `feh` calls in `bspwmrc` — landscape on the main monitor, portrait on the rotated one. To change a wallpaper, edit one line. This is intentional.
- **Modern Shell:** Powered by **Fish** and **Tide** prompt. Fast, feature-rich autosuggestions, syntax highlighting, and Git status integration without background daemons.
- **Smooth & Flat:** Hyprland-style window animations via Picom, no blur, strict Tokyo Night colors.
- **Smart Volume OSD:** Volume notifications dynamically change color based on level.
- **Workflow:** Clipboard history (CopyQ), Notification history (Rofi), quick screenshots to clipboard, and a comprehensive cheatsheet.
- **Stability:** Autostart processes (`picom`, `dunst`, `lxpolkit`, etc.) are protected against duplication via `pgrep` and `pkill`.

## 📦 Structure

```text
BSPWM-machineslego/
├── config/                 # Symlinks to ~/.config/*
│   ├── bspwm, dunst, picom, rofi, alacritty...
│   ├── fish/               # Fish shell config
│   │   ├── config.fish     # Aliases and base settings
│   │   └── fish_plugins    # Tide prompt tracking (used by Fisher)
│   ├── polybar/
│   │   ├── config.ini      # Stock modules + native battery/backlight
│   │   └── scripts/
│   │       └── power-profile.sh    # PPD profile reader
│   └── sxhkd/
│       ├── sxhkdrc         # Keybindings
│       └── scripts/        # battery (Rofi details), wifi, powermenu, etc.
├── home/                   # Symlinks to ~/*
├── system/                 # Copied to /etc
├── scripts/                # install.sh, link.sh, unlink.sh, software.sh
├── TODO.md                 # Planned features (and rejected ones)
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

**Fish & Tide Prompt:**
`install.sh` automatically installs Fisher and the Tide prompt. After installation, open a terminal and run:
```bash
tide configure
```
This interactive wizard will help you set up the prompt's style, colors, and icons to match your preferences.

**Wi-Fi Manager:**
The `wifi.sh` script is pre-configured for my devices. Open `~/.config/sxhkd/scripts/wifi.sh` and add your interface name (e.g., `wlan0`, `wlp3s0`) to the `if/elif` block. Change `HOTSPOT_SSID` and `HOTSPOT_PASSWORD` at the top of the script.

**Wallpapers:**
There is no picker. Edit the two `feh` lines in `~/.config/bspwm/bspwmrc` — one for `DisplayPort-1`, one for `HDMI-A-3` (or the single `feh` line for laptops). Files live in `~/BSPWM-machineslego/wallpapers/`.

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
| `Super + F4` | Active Monitor Screenshot |
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