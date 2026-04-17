# macOS PHP Version Management Guide

This document outlines how to safely switch between multiple PHP versions on a macOS environment using Homebrew and Nginx. This guide assumes you have installed PHP via the `shivammathur/php` tap and are using `php-fpm` on port `9000`.

## 📌 Method 1: The Quick Switch (Recommended)

If you ran the automated installation script, a custom global command was added to your terminal profile (`~/.zshrc`). This command handles the safe shutdown, unlinking, linking, and restart of all necessary background services.

### Usage
Open your terminal and type `switch_php` followed by the version number you want to activate.

```bash
# Example: Switch to PHP 8.2
switch_php 8.2

# Example: Switch back to PHP 8.4
switch_php 8.4
```

### What this command does automatically:
1. Detects your currently running PHP version.
2. Stops the background service for the current version to free up port 9000.
3. Unlinks the old PHP binary from your system path.
4. Force-links the requested new PHP binary to your system path.
5. Starts the new PHP background service.
6. Restarts Nginx to ensure it routes traffic to the newly activated PHP daemon.

---

## 🛠 Method 2: The Manual Switch (Under the Hood)

If you need to switch versions manually (or if the automated script fails), you must perform these exact steps in order. 

*In this example, we are switching from **PHP 8.4** to **PHP 8.3**.*

### Step 1: Stop the current PHP service
You must stop the currently active version so it releases port `9000`. If you skip this, the new PHP version will fail to start.
```bash
brew services stop php@8.4
```

### Step 2: Unlink the old binaries
Remove the old PHP version from your system's `PATH`.
```bash
brew unlink php@8.4
```

### Step 3: Link the new binaries
Force Homebrew to symlink the new PHP version's commands (like `php`, `phpize`, `php-config`) into your system's `PATH`.
```bash
brew link --overwrite --force php@8.3
```

### Step 4: Start the new PHP service
Boot up the new PHP daemon so Nginx can communicate with it.
```bash
brew services start php@8.3
```

### Step 5: Restart Nginx
Flush Nginx's active connection pool so it recognizes the newly spun-up PHP service.
```bash
brew services restart nginx
```

---

## ✅ Verifying the Change

Because PHP runs in two different contexts (Command Line and Web Server), it is good practice to verify both.

### 1. Check the Command Line Interface (CLI)
Run the following command in your terminal. It should immediately reflect the new version:
```bash
php -v
```
*(Note: If the CLI shows the old version, run `hash -r` or open a new terminal tab to clear your shell's command cache).*

### 2. Check the Web Server (Nginx/FPM)
Ensure Nginx is processing the correct version by accessing your `info.php` file in the browser:
1. Open your browser and navigate to: `http://localhost:8080/info.php`
2. The massive header at the top of the page should display your newly selected PHP version.

---

## ⚠️ Troubleshooting

**Error: `bind() to 127.0.0.1:9000 failed (Address already in use)`**
* **Cause:** You tried to start a new PHP version before completely stopping the old one. Two PHP versions cannot listen on port 9000 simultaneously.
* **Fix:** Stop all PHP services, then start only the one you want.
  ```bash
  brew services stop --all
  brew services start php@8.3
  ```

**Error: Nginx shows a `502 Bad Gateway`**
* **Cause:** Nginx is running, but no PHP service is actively listening on port 9000.
* **Fix:** Ensure your target PHP version is actually started and running without errors.
  ```bash
  brew services restart php@8.3
  ```
