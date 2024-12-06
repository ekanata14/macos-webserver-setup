# Welcome to macos webserver setup
I just share my experience when setting up webserver for macos
It's kinda fun, but also struggling, lmao jk.

## Install homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew --version

## Install Nginx (Use NGINX Instead lol)
brew install nginx

sudo nginx

### Check NGINX
http://localhost

### Stop NGINX
sudo nginx -s stop

### NGINX Configuration file
cd /opt/homebrew/etc/nginx/nginx.conf

nano nginx.conf

### Test Configuration
nginx -t

### Reload NGINX
sudo nginx -s reload

## Install PHP
brew install php

### Start PHP
brew services start php

### Verify PHP-FPM running on port 9000
lsof -P -n -i :9000

## Install Composer
curl -sS https://getcomposer.org/installer | php

### Move Composer
sudo mv composer.phar /usr/local/bin/composer

### Check Composer Version
composer --version


## Install NVM
brew install nvm

### Create directory for nvm
mkdir ~/.nvm


### Load ZSH and bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm


### Reload Terminal
source ~/.zshrc

### Check NVM Version
nvm --version

### Install latest or w version
nvm install (Choose One)
nvm install 22 (Choose One)

## Install MYSQL
brew install mysql

### Start MySQL Service
brew services start mysql

## Install PostgreSQL
brew install postgresql

### Start PostgreSQL
brew services start postgresql

## Install phpMyAdmin
brew install phpmyadmin

### Setup phpMyAdmin
Follow the instructions below

### Config phpMyAdmin
nano /opt/homebrew/etc/nginx/nginx.conf

### Add this config
server {
    listen 8000;
    server_name localhost;

    root /opt/homebrew/share/phpmyadmin;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}




