#!/usr/bin/env bash
set -e

# ============================================
# CONFIG - change these
# ============================================

DOTFILES_REPO="https://github.com/karl-sparks/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# List extra packages you want installed here
PACKAGES=(
  neovim
  helium-browser
  niri
  dms-shell-bin
  greetd-dms-greeter-git
  cachyos-gaming-meta
  lact
  lug-helper
  discord
)

# ============================================
# ABORT IF NOT FRESH INSTALL
# ============================================

if [ -d "$DOTFILES_DIR" ]; then
  echo "[ERROR] Dotfiles directory '$DOTFILES_DIR' already exists. Aborting script."
  exit 1
fi

# ============================================
# 1. Install packages
# ============================================

sudo paru -Syu --noconfirm "${PACKAGES[@]}"

# ============================================
# 2. Clone bare dotfiles repo and checkout
# ============================================

git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"

if git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout; then
  echo "Restored dotfiles successfully"
else
  echo "Removing default config files..."
  git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | xargs -I % rm "$HOME/%"
  if git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout; then
    echo "Finished restoring dotfiles"
  else
    echo "Failed to restore dotfiles"
    exit 1
  fi
fi

git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config status.showUntrackedFiles no

# ============================================
# 3. Start DMS Niri
# ============================================

systemctl --user enable dms
dms greeter enable
dms greeter sync

echo "Dotfiles restored, packages installed, and DMS Niri installed!"
