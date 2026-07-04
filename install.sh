#!/data/data/com.termux/files/usr/bin/bash
#
# Installer buat SSH Manager (Termux)
# Pemakaian:
#   curl -fsSL https://raw.githubusercontent.com/fidzzcodex-me/ssh-termux/main/install.sh | bash
#
set -e

REPO="fidzzcodex-me/ssh-termux"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/ssh"

BIN_NAME="sshm"   # command default, aman & tidak menimpa ssh bawaan
INSTALL_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"

info()  { printf '\033[1;36m%s\033[0m\n' "$1"; }
ok()    { printf '\033[1;32m%s\033[0m\n' "$1"; }
warn()  { printf '\033[1;33m%s\033[0m\n' "$1"; }
err()   { printf '\033[1;31m%s\033[0m\n' "$1" >&2; }

info "== Installing SSH Manager =="

# 1. Pastikan di Termux (cek keberadaan $PREFIX khas Termux)
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    warn "Peringatan: sepertinya kamu tidak menjalankan ini di Termux."
    warn "Script tetap lanjut, tapi beberapa fitur mungkin tidak berfungsi optimal."
fi

# 2. Install dependency
if command -v pkg >/dev/null 2>&1; then
    info "Memasang dependency (openssl-tool, sshpass, openssh)..."
    pkg install -y openssl-tool sshpass openssh >/dev/null 2>&1 || {
        warn "Gagal auto-install dependency. Install manual jika perlu:"
        warn "  pkg install openssl-tool sshpass openssh"
    }
fi

# 3. Download script utama
mkdir -p "$INSTALL_DIR"
TMP_FILE="$(mktemp)"

info "Mengunduh dari $RAW_URL ..."
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_URL" -o "$TMP_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$RAW_URL" -O "$TMP_FILE"
else
    err "curl atau wget tidak ditemukan. Install salah satu dulu: pkg install curl"
    exit 1
fi

# 4. Validasi hasil download (bukan file kosong / halaman 404)
if [ ! -s "$TMP_FILE" ] || grep -qi "404: Not Found" "$TMP_FILE"; then
    err "Gagal mengunduh script. Cek apakah repo/branch/path sudah benar:"
    err "  $RAW_URL"
    rm -f "$TMP_FILE"
    exit 1
fi

# 5. Pasang
mv "$TMP_FILE" "$INSTALL_DIR/$BIN_NAME"
chmod +x "$INSTALL_DIR/$BIN_NAME"
hash -r 2>/dev/null || true

ok "✓ Terinstall sebagai command: $BIN_NAME"
echo ""
echo "Kenapa '$BIN_NAME' bukan 'ssh'? Supaya command ssh bawaan tidak ketiban/rusak."
echo "Kalau kamu YAKIN mau override command 'ssh' sepenuhnya, jalankan:"
echo "  cp \$PREFIX/bin/$BIN_NAME \$PREFIX/bin/ssh && chmod +x \$PREFIX/bin/ssh"
echo ""
info "Contoh pemakaian:"
echo "  $BIN_NAME create myvps"
echo "  $BIN_NAME connect myvps"
echo "  $BIN_NAME list"
echo "  $BIN_NAME remove myvps"
