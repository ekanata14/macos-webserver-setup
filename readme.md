Berikut adalah ringkasan lengkap (Cheatsheet) untuk setup environment Web Development Native di macOS (PHP, Node, MySQL) menggantikan Docker.

Anda bisa menyalin ini ke dalam file `SETUP.md` atau Notion Anda untuk referensi di masa depan.

---

# macOS Web Development Environment Setup (Native)

Panduan ini menghapus Docker dan menggantinya dengan instalasi native menggunakan Homebrew, NVM, dan Shivam Mathur PHP Tap (Support PHP 8.1 - 8.5).

### 1. Uninstall Docker (Deep Clean)

Jalankan di Terminal untuk menghapus aplikasi dan semua data container/image.

```bash
# 1. Hapus App & Binary
rm -rf /Applications/Docker.app
rm -f /usr/local/bin/docker /usr/local/bin/docker-compose
rm -f /usr/local/bin/docker-machine /usr/local/bin/docker-credential-desktop
rm -f /usr/local/bin/docker-credential-ecr-login /usr/local/bin/docker-credential-osxkeychain
rm -f /usr/local/bin/hub-tool /usr/local/bin/hyperkit /usr/local/bin/kubectl.docker /usr/local/bin/vpnkit

# 2. Hapus Data & Library (Penting untuk free space)
rm -rf ~/Library/Group\ Containers/group.com.docker
rm -rf ~/Library/Containers/com.docker.docker
rm -rf ~/.docker

```

### 2. Install Package Manager & Frontend Stack

Menggunakan **NVM** untuk Node.js agar tidak ada masalah permission (hindari `brew install node`).

```bash
# Install Homebrew (jika belum ada)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Restart Terminal, lalu install Node LTS
nvm install --lts
nvm use --lts

```

### 3. PHP Ultimate Setup (8.1 - 8.5 + Extensions)

Script ini akan menginstall semua versi PHP yang diminta beserta extension penting (Redis & Imagick). Extension standar (BCMath, GD, Intl) sudah termasuk bawaan.

**Copy-paste script ini ke Terminal:**

```bash
# Add Repositories
brew tap shivammathur/php
brew tap shivammathur/extensions

# Install PHP 8.1 s/d 8.5 dan Extensions
VERSIONS=("8.1" "8.2" "8.3" "8.4" "8.5")
for val in ${VERSIONS[@]}; do
    echo "Installing PHP $val..."
    brew install shivammathur/php/php@$val
    brew install shivammathur/extensions/redis@$val
    brew install shivammathur/extensions/imagick@$val
done

# Install Composer
brew install composer

# Link PHP 8.5 sebagai default
brew unlink php 2>/dev/null
brew link --overwrite --force shivammathur/php/php@8.5

```

### 4. Setup Database (MySQL & Redis)

Install database secara native service.

```bash
# Install Services
brew install mysql redis

# Jalankan Service (Auto-start saat login)
brew services start mysql
brew services start redis

# Secure Installation (Optional untuk local dev)
mysql_secure_installation

```

#### Buat User Database Baru

Masuk ke MySQL (`mysql -u root -p`) dan jalankan query ini:

```sql
-- Ganti 'app_user' dan 'password' sesuai keinginan
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;

```

### 5. Utilities: PHP Switcher

Agar mudah berpindah versi PHP, tambahkan fungsi ini ke file config shell Anda (`~/.zshrc` atau `~/.bashrc`).

**Buka config:** `nano ~/.zshrc`
**Paste di paling bawah:**

```bash
# PHP Switcher function
# Usage: phpv 8.1
phpv() {
    brew unlink php
    brew link --overwrite --force "shivammathur/php/php@$1"
    php -v
    composer dump-autoload
}

```

**Simpan & Reload:** `source ~/.zshrc`

### 6. Serving Sites (Laravel Valet)

Opsional, tapi sangat direkomendasikan untuk pengguna Laravel.

```bash
composer global require laravel/valet
valet install

# Setup folder project
mkdir ~/Sites
cd ~/Sites
valet park

```

*Sekarang semua folder di dalam `~/Sites` bisa diakses via browser di `http://nama-folder.test*`

---

### Cek Final

Pastikan semua berjalan dengan menjalankan perintah ini:

* **PHP:** `php -v`
* **Node:** `node -v`
* **Composer:** `composer -V`
* **MySQL:** `mysqladmin -u app_user -p status`
* **Redis:** `redis-cli ping` (Harus membalas "PONG")
