# Niri Desktop on Arch (archinstall profile)
A reproducible setup of the Arch “Niri desktop” profile with my tweaks for portals, autostarted services, theming, and dotfiles.

<img width="3825" height="2158" alt="image" src="https://github.com/user-attachments/assets/df9f5918-d076-4e8f-8c60-33df48ac756c" />

---
## System

* Distro: Arch Linux (rolling)
* Kernel: 6.17.6-arch1-1
* Session: Wayland (Niri 25.08-2)

```bash
cat /etc/os-release
uname -r
niri --version || pacman -Qi niri | grep Version
```

## Base profile (from archinstall: “Niri desktop”)

Installed by the profile:

* `alacritty` · `fuzzel` · `mako` · `niri` · `swaybg` · `swayidle` · `swaylock` · `waybar` · `xorg-wayland`
* Portal initially pulled in: `xdg-desktop-portal-gnome`

## What I changed (high level)

* Replaced the GNOME portal with `xdg-desktop-portal-wlr` (+ `xdg-desktop-portal-gtk`) to fix Flatpak app integration on pure Wayland/Niri.
* Added a set of user services (waybar, mako, swaybg, swayidle) to start with Niri.
* Managed configs with GNU Stow from this repo (`niri`, `waybar`, `systemd`, `mimeapps`, etc.).
* Installed AUR helper (`paru`), editors, terminals, and utilities.
* Optional theming (Colloid GTK + icons) and `nwg-look`.

## Reproduce the setup

### 1) Update and basics

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel git
```

### 2) AUR helper (paru)

```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
```

### 3) Core apps I added

Pacman:

```bash
sudo pacman -S firefox flatpak imv pavucontrol man-db man-pages xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
```

AUR (via paru):

```bash
paru -S stow vscodium-bin glow nwg-look
```

Nice-to-haves:

```bash
sudo pacman -S btop htop tree wget fastfetch foot kitty neovim
```

Fonts (optional, many Nerd fonts installed):

```bash
sudo pacman -S otf-geist-mono-nerd ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono # add more as desired
```

### 4) Portals (Wayland/Niri fix)

Remove the GNOME/KDE portals and install wlr/gtk:

```bash
sudo pacman -Rns xdg-desktop-portal-gnome xdg-desktop-portal-kde || true
sudo pacman -S xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
systemctl --user daemon-reload
systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-wlr.service
systemctl --user status  xdg-desktop-portal.service xdg-desktop-portal-wlr.service
```

Optional sanity check:

```bash
gdbus introspect --session --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop --only-properties | head -n 20
```

### 5) User services that start with Niri

Create and/or enable autostart:

```bash
# Ensure systemd user dir exists
mkdir -p ~/.config/systemd/user

# Add wants so they start with Niri
systemctl --user add-wants niri.service mako.service
systemctl --user add-wants niri.service waybar.service
systemctl --user add-wants niri.service swaybg.service
systemctl --user add-wants niri.service swayidle.service

# Start immediately (optional)
systemctl --user start waybar mako swaybg swayidle
```

Example: `swaybg.service` and `swayidle.service` unit files live under this repo (see `systemd/.config/systemd/user/`) and get deployed via Stow (below).

### 6) Config management with Stow

This repo is laid out for Stow. From the repo root:

```bash
stow niri/ waybar/ systemd/ mimeapps/ fuzzel/ foot/ mako/
```

This will populate:

* `~/.config/niri/`
* `~/.config/waybar/`
* `~/.config/systemd/user/`
* `~/.config/mimeapps.list`
* `~/.config/fuzzel/fuzzel.ini`
* `~/.config/foot/foot.ini`
* `~/.config/mako/config`

### 7) Theming (optional)

```bash
paru -S gnome-themes-extra gtk-engines sassc nwg-look
git clone https://github.com/vinceliuice/Colloid-gtk-theme.git
git clone https://github.com/vinceliuice/Colloid-icon-theme.git
(cd Colloid-gtk-theme && ./install.sh --tweaks all)
(cd Colloid-icon-theme && ./install.sh -s all)

# Pick themes in nwg-look (applies GTK theme on Wayland)
nwg-look
```

### 8) Flatpak apps

```bash
flatpak install -y flathub md.obsidian.Obsidian dev.vencord.Vesktop org.signal.Signal com.google.Chrome org.wezfurlong.wezterm
flatpak update -y
```

Wayland/Electron hints (example for Obsidian):

```bash
flatpak override --user md.obsidian.Obsidian \
  --socket=wayland --nosocket=x11 --socket=system-bus \
  --env=ELECTRON_OZONE_PLATFORM_HINT=wayland --env=OZONE_PLATFORM=wayland
```

### 9) Niri config/dev loop

Validate and reload without logging out:

```bash
niri validate
niri msg action load-config-file   # reload config.kdl
# or to exit:
niri msg action quit
```

## What’s in this repo

* `niri/.config/niri/config.kdl` — my Niri config (based on `/usr/share/doc/niri/default-config.kdl`).
* `waybar/.config/waybar/{config.jsonc,style.css,scripts/}` — status bar + a small power menu script.
* `systemd/.config/systemd/user/*.service` — user services for `swaybg`, `swayidle`, etc., wired into `niri.service.wants/`.
* `mimeapps/.config/mimeapps.list` — default handlers.
* Optional: `fuzzel`, `foot`, `mako` configs.

## Package inventory (snapshot)

Explicitly installed packages (excerpt):

```text
pacman -Qent
base, bluez-utils, btop, fastfetch, firefox, flatpak, foot, glow, gnome-themes-extra,
htop, imv, intel-ucode, kitty, man-pages, neovim, network-manager-applet, niri,
nwg-look, pavucontrol, sassc, smartmontools, stow, sublime-text, swayidle, tree,
wget, wireless_tools, xorg-xinit, xorg-xwayland, yazi, zram-generator
# Fonts: multiple Nerd Fonts installed (see pacman -Qent output in repo/issues if needed)
```

AUR:

```text
paru, paru-debug, vscodium-bin
```

Flatpaks:

```text
md.obsidian.Obsidian, dev.vencord.Vesktop, org.signal.Signal, com.google.Chrome, org.wezfurlong.wezterm
```

## Troubleshooting notes

* If Flatpak apps don’t show native file pickers/portals:

  * Ensure `xdg-desktop-portal-wlr` (and optionally `xdg-desktop-portal-gtk`) are installed.
  * Restart user services:

    ```bash
    systemctl --user daemon-reload
    systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-wlr.service
    ```
* Waybar not starting on login:

  * Check `~/.config/systemd/user/niri.service.wants/waybar.service` exists.
  * Try:

    ```bash
    systemctl --user restart waybar.service
    journalctl --user -u waybar -b
    ```
* Validate Niri changes before reload:

  ```bash
  niri validate
  ```

## Credits / References

* Arch Niri package installs docs and default config:

  * `/usr/share/doc/niri/README.md`
  * `/usr/share/doc/niri/default-config.kdl`

---

