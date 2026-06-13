#!/bin/bash

# --- PRE-RUN CHECKS ---
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root. Run it as a normal user with sudo privileges."
  exit 1
fi

# --- PACMAN CONFIGURATION ---
# Enable and set Parallel Downloads to 50 for faster installation
if grep -q "ParallelDownloads" /etc/pacman.conf; then
  echo "Setting Parallel Downloads to 50 in pacman.conf..."
  sudo sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 50/' /etc/pacman.conf
fi

# Enable multilib repository (required for steam and 32-bit GPU libraries)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  echo "Enabling multilib repository..."
  sudo sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/#//' /etc/pacman.conf
fi

# --- SYSTEM UPDATE ---
echo "Updating package databases..."
sudo pacman -Syyu --noconfirm

# --- PACMAN PACKAGES ---
PACMAN_PACKAGES=(
  # Base Utilities & Terminal Tools
  base base-devel bash-completion git wget which unzip unrar jq rsync ripgrep the_silver_searcher fd less
  man-db man-pages texinfo tldr python python-pip python-pipx python-gobject nodejs npm go
  tree-sitter-cli fzf lazygit diffutils difftastic gdu fastfetch btop cpio lsb-release
  pkgfile pacman-contrib

  # System, Storage & Filesystems
  grub os-prober efibootmgr mkinitcpio cryptsetup device-mapper mdadm
  btrfs-progs snapper compsize testdisk btrfs-assistant dosfstools e2fsprogs exfatprogs
  nfs-utils accountsservice xdg-user-dirs

  # CPU & GPU Drivers / Hardware Control
  amd-ucode nvidia-utils lib32-nvidia-utils opencl-nvidia lib32-opencl-nvidia libva-nvidia-driver
  egl-wayland nvidia-settings mesa-utils vulkan-icd-loader lib32-vulkan-icd-loader lact
  nvtop usbutils dmidecode

  # Desktop & Window Managers
  hyprland hyprlang hyprgraphics hyprshot hyprpaper quickshell wofi dunst
  xsettingsd cliphist wl-clipboard yazi kitty zsh plasma-desktop
  plasma-login-manager sddm bluedevil blueman kscreen powerdevil kde-gtk-config
  kdialog kinfocenter spectacle gwenview plasma-nm plasma-pa plasma-thunderbolt
  phonon-qt6-vlc plasma-browser-integration breeze-gtk kwallet-pam

  # Portals
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

  # Networking, Security & Avahi
  networkmanager network-manager-applet iwd wpa_supplicant dnsmasq bind
  nss-mdns ufw openssh modemmanager logrotate fwupd smartmontools avahi

  # Audio & GStreamer
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber pavucontrol
  sof-firmware alsa-firmware alsa-plugins alsa-utils gst-libav gst-plugin-pipewire
  gst-plugin-va gst-plugins-bad gst-plugins-ugly mpv

  # Virtualization & Emulation
  qemu-desktop libvirt virt-manager edk2-ovmf swtpm waydroid podman distrobox

  # Gaming & Performance
  steam gamescope mangohud

  # Extra
  firefox ttf-jetbrains-mono-nerd vivid python-pywal
)

echo "Installing Pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# --- AUR HELPERS & PACKAGES ---
if ! command -v yay &> /dev/null; then
  echo "Bootstrapping yay..."
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bin
fi

AUR_PACKAGES=(
  quickshell
  accounts-qml-module
  spicetify-bin
  spotify
  wl-gammarelay-rs
  hstr
  pacman-static
  bpftune-git
  antigravity-ide
  char-white
  rate-mirrors
  rebuild-detector
  downgrade
  ananicy-cpp
  gdlauncher-carbon-bin
)

echo "Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# --- RUST & CARGO TOOLS ---
if ! command -v rustup &> /dev/null; then
  echo "Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  source "$HOME/.cargo/env"
fi

echo "Setting default Rust toolchain..."
rustup default stable

CARGO_PACKAGES=(
  bat
  cargo-cache
  cargo-update
  eza
  kondo
  procs
  rm-improved
  starship
  tokei
  topgrade
  zoxide
)

echo "Installing Cargo packages..."
cargo install "${CARGO_PACKAGES[@]}"

# --- PIPX PACKAGES ---
echo "Installing Pipx applications..."
pipx install argcomplete
pipx install bpython

# --- SHELL PLUGINS ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- POST-INSTALL CLI UPDATES ---
if command -v pkgfile &> /dev/null; then
  echo "Updating pkgfile database..."
  sudo pkgfile --update
fi

# --- SERVICES CONFIGURATION ---
echo "Enabling core system services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now sddm
sudo systemctl enable --now libvirtd
sudo systemctl enable --now ufw
sudo systemctl enable --now avahi-daemon
sudo systemctl enable --now systemd-resolved
echo "Configuring systemd-resolved DNS resolver stub link..."
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl enable --now systemd-timesyncd
sudo systemctl enable --now fstrim.timer

# Enable hardware and optimization daemons if installed
for svc in lactd bpftune ananicy-cpp; do
  if systemctl list-unit-files | grep -q "^${svc}.service"; then
    echo "Enabling optimization daemon: $svc..."
    sudo systemctl enable --now "$svc"
  fi
done

# Snapper setup (Btrfs)
if command -v snapper &> /dev/null; then
  echo "Enabling Snapper automatic snapshots..."
  sudo systemctl enable --now grub-btrfs-snapper.path
  sudo systemctl enable --now snapper-cleanup.timer
fi

echo "Configuring libvirt default network..."
sudo virsh net-start default 2> /dev/null || true
sudo virsh net-autostart default 2> /dev/null || true

# --- GROUPS & SHELL ---
echo "Adding user to key groups..."
sudo usermod -aG wheel,video,input,libvirt "$USER"

if [ "$SHELL" != "/bin/zsh" ]; then
  echo "Changing default shell to zsh..."
  chsh -s /bin/zsh
fi

# --- LINK DOTFILES ---
echo "Linking configuration files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/install.sh" ]; then
  bash "$SCRIPT_DIR/install.sh"
else
  echo "Error: install.sh not found in $SCRIPT_DIR"
  exit 1
fi

echo "Re-creation complete! Please log out or reboot to apply all group and shell changes."
