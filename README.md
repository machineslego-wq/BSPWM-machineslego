# BSPWM-machineslego

**English** | [Русский](./README.ru.md)

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![PipeWire](https://img.shields.io/badge/PipeWire-Audio-blue?logo=pipewire&logoColor=white)
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

- **Native Modules First:** Stock Polybar modules for network and audio. Battery uses a custom script (see Custom Battery Widget below).
- **Smooth & Flat:** No distracting blur, strict Tokyo Night colors, and subtle Hyprland-style window animations (Picom).
- **Unified Power Menu:** Clicking the power button or using a hotkey opens a clean Rofi menu for power actions (immediate execution, no confirmation dialogs).
- **Smart Volume OSD:** The volume notification dynamically changes its frame and progress bar color based on the level (Blue < 50%, Yellow > 50%, Red > 80%, Bright Red > 100%).
- **Custom Wi-Fi Manager:** A lightweight `wifi.sh` script (using Rofi and `nmcli`) to connect to networks, toggle the adapter, launch a hotspot, and connect to **hidden networks** (prompts for SSID, uses `hidden yes`). **Requires manual interface configuration.**
- **Ergonomic Keybindings:** Quick app launching (`Super+B` for Firefox, `Super+V` for VS Code, `Super+Alt+T` for Telegram), Rofi window switcher (`Alt+Tab`), and laptop-friendly screenshots (`Super+F1`/`F2`/`F3`).
- **Vim-keys for Floating Windows:** `Super+H/J/K/L` moves floating windows (H=left, J=down, K=up, L=right). With `xset r rate 250 30` they move smoothly when held — the same technique works for volume and brightness keys.
- **Animated Notifications (Dunst):** Notifications slide in from above with fade and slide back up on close. Notification stack shifts smoothly as new ones arrive. **Known limitation:** second and subsequent notifications in the stack appear without animation due to a Picom 12.5 conflict with Dunst's own stack positioning.
- **One-Key Reload:** `Super+Alt+Shift+R` instantly restarts SXHKD, BSPWM, Polybar, Dunst, and Picom.
- **Clipboard History (CopyQ):** Press `Super+Ctrl+V` to open a popup menu with your clipboard history. CopyQ auto-starts in `bspwmrc`.
- **Auto-Lock (xss-lock):** The screen locks automatically after 10 minutes of inactivity and before sleep, using the same `i3lock-fancy -p` as the manual `Super+Alt+L`. **No second lockscreen.**
- **Lid Suspend:** Closing the laptop lid suspends the system (kernel powers off the panel), and `xss-lock --transfer-sleep-lock` locks the screen before sleep — no second lockscreen after wake.
- **Polkit Agent (lxpolkit):** GUI password prompts for `gparted`, `synaptic`, and system updates — no terminal needed.
- **Unified Power Management (PPD):** power-profiles-daemon is the only provider, on laptops and desktops alike. TLP is removed automatically by `install.sh` to avoid conflicts.
- **Advanced Multi-monitor Support:** Customizable `bspwmrc` block for dual-monitor PCs with 144Hz support, offset alignment, portrait rotation, and dual wallpapers.
- **Notification History (Rofi):** Press `Super+Alt+H` to open a Rofi menu with the last 20 notifications from `dunstctl history`. Selecting a notification copies its body to the clipboard.
- **Custom Battery Widget:** A `battery.sh` script replaces the stock `internal/battery` module. Click the battery icon to open a Rofi menu with capacity, status, power draw, time remaining, and battery health. Warns once at 60% (recommended to finish work or plug in) and 30% (critical — please connect the charger). Supports two icon styles via `ICON_STYLE`: **horizontal** (Font Awesome, 5 levels) and **vertical** (Material Design, 10 levels). Auto-detects `BAT0`/`BAT1`/`BAT*` on any laptop and hides on desktop PCs via `exec-if`. Stock module is kept commented out in `config.ini` — pick whichever you prefer.

## 📦 Structure

```text
BSPWM-machineslego/
├── config/                 # Symlinks to ~/.config/*
│   ├── alacritty, bspwm, dunst, fastfetch, picom, rofi
│   ├── gtk-3.0, gtk-4.0    # GTK theme settings
│   ├── polybar/
│   │   ├── config.ini      # Stock modules + custom brightness
│   │   └── scripts/
│   │       ├── battery.sh          # Battery widget (custom script, Rofi details)
│   │       ├── brightness.sh       # Brightness script
│   │       └── power-profile.sh    # Power profile via PPD
│   └── sxhkd/
│       ├── sxhkdrc         # Keybindings
│       └── scripts/        # cheatsheet, notify-history, powermenu, volume, wifi
├── home/                   # Symlinks to ~/*
├── system/                 # Copied to /etc
├── scripts/                # install.sh, link.sh, unlink.sh
├── TODO.md                 # Planned features (themes, transparency)
├── screenshots/
└── wallpapers/
```

> Note: `copyq`, `xss-lock`, and `lxpolkit` are installed as Debian packages and configured via `bspwmrc` — they are not part of the repository.

## 📋 Requirements

- **OS:** Debian 13 Trixie (or a compatible distribution).
- **Basic utilities:** `git`, `sudo`, internet access.
- **Nerd Font** (installed automatically).
- **Sudo privileges** for installing packages and copying files to `/etc`.
- **Audio Backend:** This configuration is optimized for **PipeWire**. The `volume.sh` script uses `wpctl` and will only work with PipeWire. If you are using pure PulseAudio, the script will silently fail. The installer automatically adds `pipewire-pulse` for compatibility with Polybar's internal PulseAudio module.

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

**Auto-Lock Timeout (xss-lock)**
In `~/.config/bspwm/bspwmrc`, find the `--- АВТОБЛОКИРОВКА (xss-lock) ---` block. The default is 10 minutes:
```bash
xset s 600 600                    # 600 sec = 10 min
xset +dpms dpms 600 600 600       # monitor off at the same time
```
To change the timeout, edit all `600` values (e.g., `300 300` for 5 minutes).

**Lid Behavior (Laptop)**
By default, closing the lid **suspends** the system. `install.sh` creates `/etc/systemd/logind.conf.d/10-lid-suspend.conf`:
```bash
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
```
To change it to **lock without suspend**:
```bash
sudo rm /etc/systemd/logind.conf.d/10-lid-suspend.conf
sudo tee /etc/systemd/logind.conf.d/10-lid-lock.conf > /dev/null <<'EOF'
[Login]
HandleLidSwitch=lock
HandleLidSwitchExternalPower=lock
EOF
sudo systemctl kill -s HUP systemd-logind
```
> ⚠️ On some AMD laptops, "lock" does not power off the panel — the screen stays lit behind `i3lock-fancy`. That's why "suspend" is the default.

**Battery Widget (Custom Script)**
The stock `internal/battery` module is replaced by `battery.sh`. It auto-detects the battery (`BAT0`/`BAT1`/`BAT*`) on any laptop and is hidden on desktop PCs via `exec-if` in `~/.config/polybar/config.ini`.

**Icon style** — edit `ICON_STYLE` at the top of `battery.sh`:
- `"horizontal"` — Font Awesome (`    `), 5 levels (20% step)
- `"vertical"` — Material Design (`󰂂 󰂁 󰂀 󰁿 󰁾 󰁽 󰁼 󰁻 󰁺 󰂃`), 10 levels (10% step)

**Switch back to stock module:**
1. Open `~/.config/polybar/config.ini`
2. Find `[module/battery]` — the stock version is **commented out right above** the custom block
3. Comment out the custom block, uncomment the stock block
4. Restart Polybar: `pkill -x polybar && ~/.config/polybar/launch.sh &`

**Change warning thresholds** — edit the `-le 30` and `-le 60` checks in `battery.sh` (the `notify-send` lines).

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
| `Super + Ctrl + V` | Clipboard History (CopyQ) |
| `Super + /` | Cheatsheet (Rofi) |
| `Super + D` | Launcher (Rofi drun) |
| `Super + B` | Browser (Firefox) |
| `Super + V` | Editor (VS Code) |
| `Super + E` | File Manager (Thunar) |
| `Super + Alt + T` | Telegram + Proxy |
| `Super + Alt + H` | Notification History (Rofi) |
| `Super + Alt + B` | Battery Details (Rofi) |
| `Alt + Tab` | Window Switcher (Rofi) |
| `Super + W` | Close window |
| `Super + 1…0` | Switch workspaces |
| `Super + Shift + 1…0` | Move window to workspace |
| `Super + Shift + Q` | Power Menu (Rofi) |
| `Super + Alt + L` | Lock screen (i3lock-fancy) |
| `Super + F1` | Screenshot (full screen) |
| `Super + F2` | Screenshot (active window) |
| `Super + Shift + S` | Screenshot (area) |
| `Super + F3` | Screenshot (3s delay) |
| `Super + Alt + N` | Wi-Fi Manager |
| `Super + Alt + P` | Power Profile Menu |
| `Super + Alt + Shift + R` | Reload Entire System |
| `Super + Arrow keys` | Focus window |
| `Super + Shift + Arrow keys` | Swap tiled windows |
| `Super + H/J/K/L` | Move floating window (Vim-style) |
| `Super + Alt + Arrow keys` | Resize (grow) |
| `Super + Alt + Shift + Arrow keys` | Resize (shrink) |

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
- **Screen doesn't lock after inactivity** → Check `pgrep -a xss-lock`. If empty, restart BSPWM (`Super+Alt+Shift+R`). Verify timers with `xset q | grep -A 2 "Screen Saver"`.
- **Lid close locks instead of suspending** → Remove `/etc/systemd/logind.conf.d/10-lid-lock.conf` if it exists, then `sudo systemctl kill -s HUP systemd-logind`.
- **Lid close doesn't sleep (or shuts down instead)** → On AMD Ryzen 7000-series the kernel may fall back to `s2idle` or behave erratically with S3. Force `s2idle` by adding `mem_sleep_default=s2idle` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, then `sudo update-grub` and reboot. Check current mode: `cat /sys/power/mem_sleep`.
- **`Super+Ctrl+V` doesn't open CopyQ** → Make sure CopyQ is running: `pgrep -a copyq`. If not, launch it: `copyq --start-server &`. Check autostart in `bspwmrc`.
- **Polkit password dialog doesn't appear** → Check `pgrep -a lxpolkit`. Restart BSPWM if needed.
- **`Super+L` moves window instead of locking** → This is intentional. Lock moved to `Super+Alt+L` in v1.3.0; `Super+L` is now vim-right for floating windows.
- **TLP was removed after update** → Intentional. PPD is now the only power provider. If you need TLP back, install manually; but conflicts with PPD will return.
- **Battery module doesn't appear on a desktop PC** → Intentional. `exec-if` hides it because there's no battery. If you want to see a "PC" placeholder, remove `exec-if` from `[module/battery]` in `config.ini`.

## 📄 License

- Configurations and scripts — **MIT**.
- Fonts (JetBrains Mono Nerd Font) — **SIL Open Font License 1.1**.