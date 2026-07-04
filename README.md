# ssh-termux

SSH connection manager buat Termux. Simpan koneksi SSH (password / key / connection string seperti tmate) dan konek pakai nama alias — gak perlu ketik IP & user berulang-ulang.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/fidzzcodex-me/ssh-termux/main/install.sh | bash
```

Ter-install sebagai command **`sshm`** (supaya `ssh` bawaan Termux gak ketiban).

Kalau mau pakai command `ssh` langsung (override total):
```bash
cp $PREFIX/bin/sshm $PREFIX/bin/ssh
chmod +x $PREFIX/bin/ssh
```

## Pemakaian

```bash
sshm create myvps       # bikin koneksi baru (interaktif)
sshm connect myvps      # konek ke koneksi tersimpan
sshm list                # lihat semua koneksi tersimpan
sshm remove myvps        # hapus koneksi
sshm dc                  # info soal disconnect
sshm user@host           # tetap bisa dipakai kayak ssh biasa
```

### Metode koneksi saat `create`

1. **Host + User + Password** — password disimpan terenkripsi (AES-256, via `openssl`) menggunakan master password yang kamu tentukan sendiri.
2. **Host + User + SSH key** — pakai private key file yang sudah ada.
3. **Connection string langsung** — buat kasus seperti tmate (`token@host`), tanpa host/user/password terpisah.

## Requirement

- Termux
- `openssl-tool`, `sshpass`, `openssh` (auto ke-install lewat installer)

## Catatan keamanan

- Password disimpan dalam bentuk terenkripsi, bukan plain text.
- Master password **tidak disimpan di mana pun** — kalau lupa, koneksi dengan auth password harus dihapus & dibuat ulang.
- File konfigurasi koneksi disimpan di `~/.ssh-manager/connections/` dengan permission `600`.

## Lisensi

Bebas dipakai & dimodifikasi.
