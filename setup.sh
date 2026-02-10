cat << 'EOF' > install_mac_stack.sh
#!/bin/bash
set -e

# Warna untuk output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Memulai Setup macOS PHP Development Stack ===${NC}"

# 1. Cek & Install Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${BLUE}[1/9] Menginstal Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Setup Path untuk Apple Silicon jika perlu
    if [[ $(uname -m) == 'arm64' ]]; then
        (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$USER/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}[1/9] Homebrew sudah terinstall.${NC}"
fi

echo -e "${BLUE}[2/9] Update Homebrew...${NC}"
brew update

# 2. Install PHP 8.4 (Menggunakan Tap Shivammathur agar versi spesifik)
echo -e "${BLUE}[3/9] Menginstal PHP 8.4...${NC}"
brew tap shivammathur/php
brew install shivammathur/php/php@8.4
brew link --overwrite --force php@8.4

# Start PHP Service
brew services stop php@8.4 2>/dev/null || true
brew services start php@8.4

# 3. Install Nginx
echo -e "${BLUE}[4/9] Menginstal Nginx...${NC}"
brew install nginx
brew services stop nginx 2>/dev/null || true

# Tentukan Path Homebrew (Intel vs Apple Silicon)
BREW_PREFIX=$(brew --prefix)
WEB_ROOT="$BREW_PREFIX/var/www"

# Konfigurasi Otomatis Nginx agar support PHP (PENTING DI MAC)
# Default Nginx mac tidak support PHP out-of-the-box. Kita buat config baru.
echo -e "${BLUE}[INFO] Membuat konfigurasi Nginx PHP di $BREW_PREFIX/etc/nginx/servers/laravel-stack.conf...${NC}"
mkdir -p "$BREW_PREFIX/etc/nginx/servers"

cat <<NGINX_CONF > "$BREW_PREFIX/etc/nginx/servers/laravel-stack.conf"
server {
    listen 8080;
    server_name localhost;
    root $WEB_ROOT;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
NGINX_CONF

brew services start nginx

# 4. Install MySQL
echo -e "${BLUE}[5/9] Menginstal MySQL...${NC}"
brew install mysql
brew services start mysql

# 5. Install NVM
echo -e "${BLUE}[6/9] Menginstal NVM...${NC}"
brew install nvm
mkdir -p ~/.nvm

# Tambahkan ke zshrc jika belum ada
if ! grep -q "nvm.sh" ~/.zshrc; then
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
  echo "[ -s \"$BREW_PREFIX/opt/nvm/nvm.sh\" ] && \. \"$BREW_PREFIX/opt/nvm/nvm.sh\"" >> ~/.zshrc
  echo "[ -s \"$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm\" ] && \. \"$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm\"" >> ~/.zshrc
fi

# Load NVM sementara untuk sesi ini
export NVM_DIR="$HOME/.nvm"
[ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$BREW_PREFIX/opt/nvm/nvm.sh"
nvm install node # Install latest node

# 6. Install Composer
echo -e "${BLUE}[7/9] Menginstal Composer...${NC}"
brew install composer

# 7. Install phpMyAdmin
echo -e "${BLUE}[8/9] Menginstal phpMyAdmin...${NC}"
PMA_VER="5.2.1"
cd /tmp
curl -O -L https://files.phpmyadmin.net/phpMyAdmin/${PMA_VER}/phpMyAdmin-${PMA_VER}-all-languages.zip
unzip -q phpMyAdmin-${PMA_VER}-all-languages.zip
rm -rf "$WEB_ROOT/phpmyadmin"
mv phpMyAdmin-${PMA_VER}-all-languages "$WEB_ROOT/phpmyadmin"
rm phpMyAdmin-${PMA_VER}-all-languages.zip

# Buat config file sederhana untuk PMA
cp "$WEB_ROOT/phpmyadmin/config.sample.inc.php" "$WEB_ROOT/phpmyadmin/config.inc.php"
# Generate random secret
RANDOM_SECRET=$(openssl rand -base64 32)
sed -i '' "s/\['blowfish_secret'\] = '';/\['blowfish_secret'\] = '$RANDOM_SECRET';/" "$WEB_ROOT/phpmyadmin/config.inc.php"
# Izinkan login tanpa password (default brew mysql root user tidak ada password)
sed -i '' "s/\['AllowNoPassword'\] = false;/\['AllowNoPassword'\] = true;/" "$WEB_ROOT/phpmyadmin/config.inc.php"

# 8. Set Permissions (Di Mac, user adalah owner, tidak perlu www-data)
echo -e "${BLUE}[9/9] Mengatur Permission...${NC}"
chmod -R 755 "$WEB_ROOT"

# Buat info.php untuk tes
echo "<?php phpinfo(); ?>" > "$WEB_ROOT/info.php"

echo "------------------------------------------------"
echo -e "${GREEN}Installation Complete!${NC}"
echo "------------------------------------------------"
echo "PHP Version      : $(php -v | head -n 1)"
echo "Nginx            : Running on port 8080"
echo "MySQL            : Running (User: root, Pass: [kosong])"
echo "Composer         : $(composer --version | head -n 1)"
echo "Web Root         : $WEB_ROOT"
echo "------------------------------------------------"
echo -e "${GREEN}Akses Dashboard:${NC}"
echo "1. Cek PHP       : http://localhost:8080/info.php"
echo "2. phpMyAdmin    : http://localhost:8080/phpmyadmin"
echo "------------------------------------------------"
echo "Catatan: Jalankan 'source ~/.zshrc' untuk menggunakan perintah 'nvm'"
EOF
chmod +x install_mac_stack.sh && ./install_mac_stack.sh
