#!/data/data/com.termux/files/usr/bin/bash
#
# SSH Manager — Installer for Termux
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fidzzcodex-me/ssh-termux/main/install.sh | bash
#
set -e

REPO="fidzzcodex-me/ssh-termux"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/ssh"

BIN_NAME="sshm"
INSTALL_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"

# ─── Colors ───────────────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m'
C='\033[1;36m' W='\033[1;37m' DIM='\033[2m' RESET='\033[0m'

info() { printf "${C}  ➜ %s${RESET}\n" "$1"; }
ok()   { printf "${G}  ✔ %s${RESET}\n" "$1"; }
warn() { printf "${Y}  ⚠ %s${RESET}\n" "$1"; }
err()  { printf "${R}  ✗ %s${RESET}\n" "$1" >&2; }

# ─── Banner ───────────────────────────────────────────────────────────────────
w=46
line=$(printf '─%.0s' $(seq 1 $w))
printf "\n${C}┌${line}┐${RESET}\n"
printf "${C}│${W}  %-${w}s${C}│${RESET}\n" "SSH Manager — Installer"
printf "${C}└${line}┘${RESET}\n\n"

# ─── 1. Termux check ──────────────────────────────────────────────────────────
if [ ! -d "/data/data/com.termux/files/usr" ]; then
  warn "Not running inside Termux — some features may not work correctly."
fi

# ─── 2. Install dependencies ──────────────────────────────────────────────────
if command -v pkg >/dev/null 2>&1; then
  info "Installing dependencies (openssl-tool, sshpass, openssh)..."
  pkg install -y openssl-tool sshpass openssh >/dev/null 2>&1 || {
    warn "Auto-install failed. Install manually if needed:"
    warn "  pkg install openssl-tool sshpass openssh"
  }
fi

# ─── 3. Download ──────────────────────────────────────────────────────────────
mkdir -p "$INSTALL_DIR"
TMP_FILE="$(mktemp)"

info "Downloading from GitHub..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$RAW_URL" -o "$TMP_FILE"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$RAW_URL" -O "$TMP_FILE"
else
  err "curl or wget not found. Install one first: pkg install curl"
  exit 1
fi

# ─── 4. Validate download ─────────────────────────────────────────────────────
if [ ! -s "$TMP_FILE" ] || grep -qi "404: Not Found" "$TMP_FILE"; then
  err "Download failed. Check repo/branch/path:"
  err "  $RAW_URL"
  rm -f "$TMP_FILE"
  exit 1
fi

# ─── 5. Install ───────────────────────────────────────────────────────────────
mv "$TMP_FILE" "$INSTALL_DIR/$BIN_NAME"
chmod +x "$INSTALL_DIR/$BIN_NAME"
hash -r 2>/dev/null || true

# ─── 5b. Optional: install as 'ssh' too (with mandatory backup) ──────────────
echo ""
read -rp "  Also override the 'ssh' command directly? [y/N] " override
case "$override" in
  y|Y)
    if [ -e "$INSTALL_DIR/ssh" ] && [ ! -e "$INSTALL_DIR/ssh.real" ]; then
      info "Backing up original ssh binary to 'ssh.real'..."
      cp "$INSTALL_DIR/ssh" "$INSTALL_DIR/ssh.real"
    fi
    cp "$INSTALL_DIR/$BIN_NAME" "$INSTALL_DIR/ssh"
    chmod +x "$INSTALL_DIR/ssh"
    hash -r 2>/dev/null || true
    ok "'ssh' now runs the wrapper. Original backed up as 'ssh.real'."
    ;;
  *)
    echo "  Skipped. Use '$BIN_NAME' as the command name."
    ;;
esac

# ─── 6. Summary ───────────────────────────────────────────────────────────────
printf "\n${C}┌${line}┐${RESET}\n"
printf "${C}│${W}  %-${w}s${C}│${RESET}\n" "Installation Complete!"
printf "${C}├${line}┤${RESET}\n"
printf "${C}│${RESET}  ${DIM}%-${w}s${C}│${RESET}\n" "Command installed as: sshm"
printf "${C}│${RESET}  %-${w}s${C}│${RESET}\n" ""
printf "${C}│${RESET}  ${G}sshm create myvps   ${DIM}%-$((w-20))s${C}│${RESET}\n" "Save a connection"
printf "${C}│${RESET}  ${G}sshm connect myvps  ${DIM}%-$((w-20))s${C}│${RESET}\n" "Connect"
printf "${C}│${RESET}  ${G}sshm list           ${DIM}%-$((w-20))s${C}│${RESET}\n" "List connections"
printf "${C}│${RESET}  %-${w}s${C}│${RESET}\n" ""
printf "${C}│${DIM}  To use as 'ssh' instead of 'sshm':%-$((w-36))s${C}│${RESET}\n" ""
printf "${C}│${RESET}  ${Y}cp \$PREFIX/bin/sshm \$PREFIX/bin/ssh${RESET}%-$((w-36))s${C}│${RESET}\n" ""
printf "${C}│${RESET}  %-${w}s${C}│${RESET}\n" ""
printf "${C}└${line}┘${RESET}\n\n"
