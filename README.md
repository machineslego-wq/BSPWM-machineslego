# BSPWM-machineslego

**English** | [Русский](./README.ru.md)

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![BSPWM](https://img.shields.io/badge/WM-BSPWM-black)
![License](https://img.shields.io/badge/License-MIT-green)

Configuration of a desktop environment based on BSPWM for Debian 13 Trixie, styled in the Tokyo Night color palette.

![Desktop](screenshots/desktop-actual.png)
![Workspace](screenshots/workspace-example-actual.png)
![Rofi](screenshots/rofi-actual.png)

<details>
<summary><b>Show more screenshots (Unfolded Polybar)</b></summary>
<br>

![Unfolded-right-modules](screenshots/unfolded-polybar-actual.png)

</details>

## Features

- **Native Modules First:** Stock Polybar modules for battery, network, and audio.
- **No transparency or blur:** Disabled in Alacritty, Polybar, and Picom. Only strict Tokyo Night colors.
- **Static cheatsheet:** `Super + /` menu with icons and hidden tags for Rofi search. *(Note: Since the cheatsheet is a static script, its content inside `autocheatsheet.sh` is currently in Russian and requires manual translation for English users).*
- **Universal hardware:** Auto-detection of batteries (`BAT0`/`BAT1`) and power adapters. Brightness control is available out-of-the-box for laptops (via `brightnessctl`).
- **Management without unnecessary applets:** Wi-Fi via `nmtui`, audio via `pavucontrol`. Exception: `blueman` for Bluetooth (in the system tray).
- **Network fix:** The installer copies a fixed `/etc/network/interfaces` and NetworkManager settings, solving Wi-Fi issues on a clean install.
- **Multi-monitor Support:** Smart fallback for laptops and a customizable block in `bspwmrc` for custom dual-monitor PC setups (rotation, specific workspace distribution).

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
│   │       ├── brightness.sh       # Brightness script (with dot indicator)
│   │       ├── power-profile-ppd.sh # Power profile for PPD
│   │       └── power-profile-tlp.sh # Power profile for TLP
│   └── sxhkd/
│       ├── sxhkdrc         # Keybindings
│       └── scripts/        # autocheatsheet, powermenu, sensors, volume
├── home/                   # Symlinks to ~/*
├── system/                 # Copied to /etc (touchpad, NetworkManager, network fix)
├── scripts/                # install.sh, link.sh, unlink.sh
├── screenshots/
└── wallpapers/
```

## 📋 Requirements

- **OS:** Debian 13 Trixie (or a compatible distribution).
- **Basic utilities:** `git`, `sudo`, internet access for downloading packages.
- **Nerd Font** (installed automatically by the installer).
- **Sudo privileges** for installing `apt` packages and copying files to `/etc`.

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
⚠️ **Important:** You must rename the extracted folder to exactly `BSPWM-machineslego` and place it in your home directory (`~/`). Otherwise, wallpapers and hardcoded paths will break.
```bash
# Example after extracting the ZIP:
mv ~/Downloads/BSPWM-machineslego* ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```

**What `install.sh` does:**
- Installs packages via `apt`.
- Downloads Nerd Font from the official release and places it in `~/.local/share/fonts`.
- Configures `sudoers` for power profile management.
- Copies touchpad configs, NetworkManager, and the `/etc/network/interfaces` fix to `/etc`.
- Creates symlinks in `~/.config/*` and `~/*`.

**If you don't want to touch `/etc`:** use `./scripts/link.sh`.
**Rollback:** `./scripts/unlink.sh` (removes only symlinks; packages and files in `/etc` remain).
**Launch:** `startx` (or via LightDM).

### ⚙️ Customization

**Monitor Setup (Desktop PC)**
If you use a desktop PC with multiple monitors, you can customize their layout in `~/.config/bspwm/bspwmrc`. Find the `--- НАСТРОЙКА МОНИТОРОВ ---` block.
1. Change `"lamer-deb"` to your actual `hostname`.
2. Adjust `xrandr` outputs (`DisplayPort-1`, `HDMI-A-3`) and rotation (`--rotate right`).
3. Distribute workspaces as you prefer (e.g., `I..IX` on primary, `X` on secondary).
*If the hostname doesn't match, the script falls back to the default single-monitor layout.*

## 🖼️ Wallpapers and Theme

Dimming wallpapers for the Tokyo Night palette via ImageMagick:
```bash
convert /path/to/original.jpg -fill "#1a1b26" -colorize 50% -modulate 80,80,100 /path/to/tokyo-night-wallpaper.jpg
```

## ⌨️ Keybindings

**Full cheatsheet:** `Super + /` (Rofi, search by hidden tags).

| Keybinding | Action |
|---|---|
| `Super + Enter` | Terminal (Alacritty) |
| `Super + /` | Cheatsheet (Rofi) |
| `Super + W` | Close window |
| `Super + 1…9` | Switch workspaces |
| `Super + Shift + 1…9` | Move window to workspace |
| `Super + D` | Launcher (Rofi drun) |
| `Print` | Screenshot full screen |
| `Shift + Print` | Screenshot window |
| `Super + Shift + S` | Screenshot area |

> Exact list is in `config/sxhkd/sxhkdrc`.

## 🔧 Troubleshooting

- **No icons in Polybar/Rofi** → Nerd Font is not installed. Check: `fc-list | grep -i "nerd"`. Reinstall: `./scripts/install.sh`.
- **`startx` doesn't start** → Check for `exec bspwm` in `~/.xinitrc` and the `xorg` package.
- **Keybindings don't work** → Check `pgrep sxhkd`. Restart: `pkill -USR1 -x sxhkd`.
- **No brightness module on a desktop PC** → This is intentional. The brightness module uses `brightnessctl`, which only works with built-in laptop panels. On desktop PCs, use your monitor's physical buttons.
- **Polybar doesn't start** → Check the `~/.config/polybar` symlink and `launch.sh` permissions (`chmod +x`).
- **TLP and PPD conflict** → Only one should be active at a time (`systemctl status tlp` / `power-profiles-daemon`).
- **Wi-Fi lost** → Restart NetworkManager: `sudo systemctl restart NetworkManager` (ensure the `/etc/network/interfaces` fix is copied).

## 📄 License

- Configurations and scripts — **MIT**.
- Fonts (JetBrains Mono Nerd Font) — **SIL Open Font License 1.1**.