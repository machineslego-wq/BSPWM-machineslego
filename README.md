# BSPWM-machineslego

**English** | [Русский](./README.ru.md)

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![BSPWM](https://img.shields.io/badge/WM-BSPWM-black)
![License](https://img.shields.io/badge/License-MIT-green)

Configuration of a desktop environment based on BSPWM for Debian 13 Trixie, styled in the Tokyo Night color palette.

![Desktop](screenshots/desktop.png)
![Workspace & Notifications](screenshots/workspace+notify.png)

<details>
<summary><b>Show more screenshots (Rofi, Polybar, Power, Wi-Fi, Cheatsheet)</b></summary>
<br>

**Rofi**
![Rofi](screenshots/rofi-showcase.png)
![Alt+Tab Example](screenshots/alt+x-example.png)

**Polybar (Right side, all modules expanded)**
![Polybar right side expanded](screenshots/polybar-right-expanded.png)

**Power Profiles**
![Power Profiles](screenshots/power-profiles.png)

**Wi-Fi**
![Wi-Fi Manager](screenshots/wifi-manager.png)
![Wi-Fi Menu](screenshots/wifi-manager-menu.png)

**Cheatsheet**
![Cheatsheet](screenshots/cheatsheet.png)

</details>

## Features

- **Native Modules First:** Stock Polybar modules for battery, network, and audio.
- **Smooth & Flat:** No distracting blur, strict Tokyo Night colors, and subtle Hyprland-style window animations (Picom).
- **Unified Power Menu:** Clicking the power button or using a hotkey opens a clean Rofi menu for power actions (immediate execution, no confirmation dialogs).
- **Smart Volume OSD:** The volume notification dynamically changes its frame and progress bar color based on the level (Blue < 50%, Yellow > 50%, Red > 80%, Bright Red > 100%).
- **Custom Wi-Fi Manager:** A lightweight `wifi.sh` script (using Rofi and `nmcli`) to connect to networks, toggle the adapter, and launch a hotspot. **Requires manual interface configuration.**
- **Ergonomic Keybindings:** Quick app launching (`Super+B` for Firefox, `Super+V` for VS Code, `Super+Alt+T` for Telegram), Rofi window switcher (`Alt+Tab`), and laptop-friendly screenshots (`Super+F1`/`F2`/`F3`).
- **One-Key Reload:** `Super+Alt+Shift+R` instantly restarts SXHKD, BSPWM, Polybar, Dunst, and Picom.
- **Advanced Multi-monitor Support:** Customizable `bspwmrc` block for dual-monitor PCs with 144Hz support, offset alignment, portrait rotation, and dual wallpapers.

## 📦 Structure

```text
BSPWM-machineslego/
├── config/                 # Symlinks to ~/.config/*
│   ├── alacritty, bspwm, dunst, fastfetch, picom, rofi
│   ├── gtk-3.0, gtk-4.0    # GTK theme settings
│   ├── polybar/
│   │   ├── config.ini      # Stock modules + custom brightness
│   │   └── scripts/
│   │       ├── battery.sh          # Battery fallback script
│   │       ├── brightness.sh       # Brightness script
│   │       ├── power-profile-ppd.sh # Power profile for PPD
│   │       └── power-profile-tlp.sh # Power profile for TLP
│   └── sxhkd/
│       ├── sxhkdrc         # Keybindings
│       └── scripts/        # cheatsheet, powermenu, volume, wifi
├── home/                   # Symlinks to ~/*
├── system/                 # Copied to /etc
├── scripts/                # install.sh, link.sh, unlink.sh
├── screenshots/
└── wallpapers/
```

## 📋 Requirements

- **OS:** Debian 13 Trixie (or a compatible distribution).
- **Basic utilities:** `git`, `sudo`, internet access.
- **Nerd Font** (installed automatically).
- **Sudo privileges** for installing packages and copying files to `/etc`.

## 🛠 Installation

**Option 1: Via Git (Recommended)**
```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```

**Option 2: Via ZIP archive**
If you downloaded the `.zip` archive, GitHub extracts it into a folder named `BSPWM-machineslego-X.X.X`. 
⚠️ **Important:** Rename the extracted folder to exactly `BSPWM-machineslego` and place it in your home directory (`~/`).
```bash
mv ~/Downloads/BSPWM-machineslego* ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```

**If you don't want to touch `/etc`:** use `./scripts/link.sh`.
**Rollback:** `./scripts/unlink.sh`.
**Launch:** `startx` (or via LightDM).

### ⚙️ Customization

**Monitor Setup (Desktop PC)**
If you use a desktop PC with multiple monitors, customize them in `~/.config/bspwm/bspwmrc`. Find the `--- НАСТРОЙКА МОНИТОРОВ ---` block.
1. Change `"lamer-deb"` to your actual `hostname`.
2. Adjust `xrandr` outputs, refresh rate (`--rate 144.00`), rotation, and position.
3. Set different wallpapers for each monitor using `feh --output`.

**Wi-Fi & Hotspot (Manual Setup Required)**
The `wifi.sh` script is pre-configured for my devices (e.g., `wlo1`, `wlp3s0`). **You must manually add your own device's interface name** to the `if/elif` block. 
You can find your interface name by running `ip a` or `nmcli device`. On some machines, it might be `wlan0`, while on others (like a PC with a PCIe card), it could be something like `wlp7s0`.
Also, change the `HOTSPOT_SSID` and `HOTSPOT_PASSWORD` variables at the top of `~/.config/sxhkd/scripts/wifi.sh`.

## 🖼️ Wallpapers and Theme

Dimming wallpapers for the Tokyo Night palette via ImageMagick:
```bash
convert /path/to/original.jpg -fill "#1a1b26" -colorize 50% -modulate 80,80,100 /path/to/tokyo-night-wallpaper.jpg
```

## ⌨️ Keybindings

**Full cheatsheet:** `Super + /` (Rofi, search by hidden tags).

| Keybinding | Action |
|---|---|
| `Super + Return` | Terminal (Alacritty) |
| `Super + /` | Cheatsheet (Rofi) |
| `Super + D` | Launcher (Rofi drun) |
| `Super + B` | Browser (Firefox) |
| `Super + V` | Editor (VS Code) |
| `Super + E` | File Manager (Thunar) |
| `Super + Alt + T` | Telegram + Proxy |
| `Alt + Tab` | Window Switcher (Rofi) |
| `Super + W` | Close window |
| `Super + 1…0` | Switch workspaces |
| `Super + Shift + 1…0` | Move window to workspace |
| `Super + Shift + Q` | Power Menu (Rofi) |
| `Super + F1` | Screenshot (full screen) |
| `Super + F2` | Screenshot (active window) |
| `Super + Shift + S` | Screenshot (area) |
| `Super + F3` | Screenshot (3s delay) |
| `Super + Alt + N` | Wi-Fi Manager |
| `Super + Alt + P` | Power Profile Menu |
| `Super + Alt + Shift + R` | Reload Entire System |

## 🎨 Ecosystem

If you want your notes to match the strict, flat aesthetic of this desktop setup, check out the companion theme for Obsidian:

**[Tokyo Night Flat Theme for Obsidian](https://github.com/machineslego-wq/tokyo-night-by-machineslego-wq)**

## 🔧 Troubleshooting

- **Wi-Fi script doesn't work / Error in `wifi.sh`** → The script has hardcoded interface names for my devices. You must open `~/.config/sxhkd/scripts/wifi.sh` and manually add your interface name to the `if/elif` block. Run `ip a` to find it (e.g., `wlan0`, `wlo1`, `wlp7s0`).
- **No icons in Polybar/Rofi** → Nerd Font is not installed. Check: `fc-list | grep -i "nerd"`.
- **`startx` doesn't start** → Check for `exec bspwm` in `~/.xinitrc`.
- **Keybindings don't work** → Check `pgrep sxhkd`. Restart: `pkill -USR1 -x sxhkd`.
- **No brightness module on a desktop PC** → This is intentional. Use monitor buttons.
- **Polybar doesn't start** → Check the `~/.config/polybar` symlink and `launch.sh` permissions.

## 📄 License

- Configurations and scripts — **MIT**.
- Fonts (JetBrains Mono Nerd Font) — **SIL Open Font License 1.1**.