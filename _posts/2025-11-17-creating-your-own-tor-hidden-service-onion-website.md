---
title: "Creating Your Own Tor Hidden Service (.onion Website)"
date: 2025-11-17 01:00:00 +0000
categories: [Security, Guides]
tags: [tor, onion, hidden-service, privacy, darknet, kali, linux, nginx]
pin: false
math: false
mermaid: false
---

## Overview

Want to host your own .onion website on the Tor network? This comprehensive guide walks you through creating a Tor hidden service from scratch on Kali Linux (ARM64/x86-64). You'll learn how to set up a web server, configure Tor, generate your .onion address, and implement security best practices.

**What you'll accomplish:**
- Install and configure Tor as a service (not just the browser)
- Set up a web server (nginx)
- Create and configure your hidden service
- Get your unique .onion address
- Test and secure your service

**Time required:** 30-45 minutes

---

## What is a Tor Hidden Service?

A **Tor hidden service** (also called an **onion service**) is a website that:
- Is only accessible through the Tor network
- Has a `.onion` address (e.g., `abc123xyz456.onion`)
- Provides **bidirectional anonymity** (both host and visitor are anonymous)
- Cannot be taken down by traditional means (no server IP to target)
- Resists censorship

### Legitimate Uses

- **Privacy-focused services:** Whistleblower platforms, secure communication
- **Censorship resistance:** Publishing content in restrictive countries
- **Security research:** Testing and learning about Tor technology
- **Personal projects:** Private blogs, file sharing, development testing
- **Journalistic sources:** SecureDrop and similar platforms

---

## Prerequisites

### System Requirements

- **OS:** Kali Linux, Ubuntu, Debian, or any Linux distribution
- **Architecture:** ARM64 or x86-64 (both work)
- **RAM:** Minimum 1GB (2GB+ recommended)
- **Disk Space:** At least 500MB free
- **Network:** Internet connection (no special configuration needed)

### Knowledge Requirements

- Basic Linux command line skills
- Understanding of web servers (helpful but not required)
- Familiarity with text editors (nano, vim, or GUI editors)

---

## Understanding the Architecture (Important!)

**Before we start, let's clarify a common point of confusion:** You'll work with TWO different directories, but they serve completely different purposes.

### The Two Directories Explained

```
┌─────────────────────────────────────────────────────────────────┐
│                          YOUR SERVER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  /var/lib/tor/my-onion-site/          /var/www/onion-site/     │
│  ┌──────────────────────────┐         ┌──────────────────────┐ │
│  │  TOR'S CRYPTO FILES      │         │   YOUR WEBSITE       │ │
│  │  (Don't touch!)          │         │   (Edit this!)       │ │
│  │                          │         │                      │ │
│  │  • hostname              │         │  • index.html        │ │
│  │  • hs_ed25519_secret_key │         │  • style.css         │ │
│  │  • hs_ed25519_public_key │         │  • images/           │ │
│  │  • authorized_clients/   │         │  • scripts/          │ │
│  └──────────────────────────┘         └──────────────────────┘ │
│           ↓                                     ↑               │
│      Tor Daemon                            Nginx Server         │
│    (Port 9050)                          (Port 8080)             │
│           ↓                                     ↑               │
│           └─────────────────┬───────────────────┘               │
│                             ↓                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────────┐
                    │    Tor Network      │
                    │   (Your .onion)     │
                    └─────────────────────┘
                              ↑
                    ┌─────────────────────┐
                    │   Visitor using     │
                    │    Tor Browser      │
                    └─────────────────────┘
```

### Directory Breakdown

| Directory | Purpose | You Edit? | Contains |
|-----------|---------|-----------|----------|
| **`/var/lib/tor/my-onion-site/`** | Tor's cryptographic keys and routing data | ❌ **NO** (Tor manages automatically) | • Private/public keys<br>• Your .onion hostname<br>• Client authorization (optional) |
| **`/var/www/onion-site/`** | Your actual website files | ✅ **YES** (This is your content!) | • HTML files<br>• CSS, JavaScript<br>• Images, media<br>• Any web content |

### How the Data Flows

Here's what happens when someone visits your .onion site:

```
1. Visitor enters your .onion address in Tor Browser
                    ↓
2. Request travels through Tor network (encrypted)
                    ↓
3. Arrives at Tor daemon on your server (port 9050)
                    ↓
4. Tor daemon checks /var/lib/tor/my-onion-site/ for crypto keys
                    ↓
5. Tor forwards request to 127.0.0.1:8080 (nginx)
                    ↓
6. Nginx reads files from /var/www/onion-site/
                    ↓
7. Nginx sends HTML/CSS/JS back to Tor daemon
                    ↓
8. Tor encrypts and sends response back through network
                    ↓
9. Visitor sees your website in Tor Browser
```

### Common Misconception ⚠️

**WRONG:** "I need to put my website files in `/var/lib/tor/my-onion-site/`"

**RIGHT:** "My website files go in `/var/www/onion-site/`. The `/var/lib/tor/` directory is ONLY for Tor's cryptographic data."

**Think of it like this:**
- `/var/lib/tor/my-onion-site/` = Your house's **security system and locks** (Tor manages this)
- `/var/www/onion-site/` = Your house's **furniture and decorations** (You manage this)

You don't manually adjust your security system's cryptography, but you do arrange your furniture!

### What's in Each Directory?

**`/var/lib/tor/my-onion-site/` (Tor's directory):**
```
/var/lib/tor/my-onion-site/
├── hostname                    # Your .onion address (READ ONLY)
├── hs_ed25519_public_key       # Public key (Tor manages)
├── hs_ed25519_secret_key       # Private key (NEVER SHARE!)
└── authorized_clients/         # Optional client auth keys
```

**`/var/www/onion-site/` (Your website directory):**
```
/var/www/onion-site/
├── index.html                  # Your homepage
├── about.html                  # Other pages
├── css/
│   └── style.css              # Stylesheets
├── js/
│   └── script.js              # JavaScript
├── images/
│   ├── logo.png               # Images
│   └── banner.jpg
└── files/
    └── document.pdf           # Downloads
```

### Key Points to Remember

1. **Only Tor touches** `/var/lib/tor/my-onion-site/` - it's automatically managed
2. **Only you touch** `/var/www/onion-site/` - this is where you build your site
3. **Nginx reads from** `/var/www/onion-site/` and serves files to visitors
4. **Tor handles** encryption, routing, and .onion address generation
5. **You never manually edit** the cryptographic keys in `/var/lib/tor/`

Now that you understand the architecture, let's build your hidden service!

---

## Step 1: Install Required Packages

First, install Tor (the service, not the browser) and nginx web server.

### Update Package Lists

```bash
sudo apt update
```

### Install Tor and Nginx

```bash
# Install Tor daemon and nginx web server
sudo apt install tor nginx -y
```

**Verify installation:**

```bash
# Check Tor version
tor --version
# Output: Tor version 0.4.x.x

# Check nginx version
nginx -v
# Output: nginx version: nginx/1.x.x
```

### Start Services

```bash
# Start and enable Tor
sudo systemctl start tor
sudo systemctl enable tor

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

**Check status:**

```bash
sudo systemctl status tor
sudo systemctl status nginx
```

Both should show **active (running)** in green.

---

## Step 2: Create Your Website Content

Create a simple website to host on your hidden service.

### Create Website Directory

```bash
# Create directory for your onion site
sudo mkdir -p /var/www/onion-site

# Set permissions
sudo chown -R $USER:$USER /var/www/onion-site
sudo chmod -R 755 /var/www/onion-site
```

### Create HTML Content

```bash
# Create a simple homepage
nano /var/www/onion-site/index.html
```

**Add this content:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Hidden Service</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #1a1a1a;
            color: #00ff00;
        }
        h1 {
            color: #00ff00;
            border-bottom: 2px solid #00ff00;
            padding-bottom: 10px;
        }
        .info {
            background-color: #2a2a2a;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        a {
            color: #00aaff;
        }
    </style>
</head>
<body>
    <h1>Welcome to My Tor Hidden Service</h1>

    <div class="info">
        <p><strong>Status:</strong> Online and operational</p>
        <p><strong>Purpose:</strong> Privacy-focused demonstration</p>
        <p><strong>Access:</strong> Tor network only</p>
    </div>

    <h2>About This Service</h2>
    <p>This is a demonstration of a Tor hidden service (.onion website) running on a secure, anonymous server.</p>

    <h2>Features</h2>
    <ul>
        <li>Accessible only through Tor Browser</li>
        <li>Bidirectional anonymity</li>
        <li>Censorship resistant</li>
        <li>End-to-end encrypted</li>
    </ul>

    <h2>Contact</h2>
    <p>This is a test service. Replace this content with your own!</p>

    <hr>
    <p><small>Powered by Tor Hidden Services | Running on Kali Linux</small></p>
</body>
</html>
```

**Save and exit:** `Ctrl+O`, `Enter`, `Ctrl+X`

---

## Step 3: Configure Nginx for Hidden Service

Create an nginx configuration specifically for your onion site.

### Create Nginx Config File

```bash
sudo nano /etc/nginx/sites-available/onion-site
```

**Add this configuration:**

```nginx
server {
    listen 127.0.0.1:8080;
    server_name localhost;

    root /var/www/onion-site;
    index index.html index.htm;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Disable logging for privacy
    access_log off;
    error_log /var/log/nginx/onion-error.log;

    location / {
        try_files $uri $uri/ =404;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
```

**Save and exit:** `Ctrl+O`, `Enter`, `Ctrl+X`

### Enable the Site

```bash
# Create symbolic link to enable the site
sudo ln -s /etc/nginx/sites-available/onion-site /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t
```

**Expected output:**
```
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Reload Nginx

```bash
sudo systemctl reload nginx
```

### Test Locally

```bash
curl http://127.0.0.1:8080
```

You should see your HTML content. If you see your page, nginx is working correctly!

---

## Step 4: Configure Tor Hidden Service

Now configure Tor to create your hidden service.

### Edit Tor Configuration

```bash
sudo nano /etc/tor/torrc
```

### Add Hidden Service Configuration

Scroll to the bottom of the file and add:

```bash
############### This section is for hidden services ###############

# Directory where Tor stores hidden service data
HiddenServiceDir /var/lib/tor/my-onion-site/

# Map port 80 (what visitors use) to local port 8080 (nginx)
HiddenServicePort 80 127.0.0.1:8080

# Optional: Set version (v3 is default and recommended)
HiddenServiceVersion 3
```

**Understanding the configuration:**

- **HiddenServiceDir:** Where Tor stores your private keys and hostname
- **HiddenServicePort:** Maps external port (80) to your local service (8080)
- **HiddenServiceVersion 3:** Uses modern v3 onion addresses (56 characters)

**Save and exit:** `Ctrl+O`, `Enter`, `Ctrl+X`

### Set Permissions

```bash
# Ensure Tor can write to its directory
sudo chmod 700 /var/lib/tor/
sudo chown -R debian-tor:debian-tor /var/lib/tor/
```

### Restart Tor

```bash
sudo systemctl restart tor
```

**Check for errors:**

```bash
sudo systemctl status tor
```

Should show **active (running)**. If you see errors, check the logs:

```bash
sudo journalctl -u tor -n 50
```

---

## Step 5: Get Your .onion Address

Tor automatically generates your unique .onion address.

### Retrieve Your Hostname

```bash
sudo cat /var/lib/tor/my-onion-site/hostname
```

**Output example:**
```
abc123def456ghi789jkl012mno345pqr678stu901vwx234yz.onion
```

**This is your onion address!** Copy it somewhere safe.

### Understanding Your Address

- **Length:** 56 characters (v3 onion addresses)
- **Format:** Random alphanumeric + `.onion`
- **Permanence:** Tied to private keys in `HiddenServiceDir`
- **Security:** Cryptographically derived from your service's public key

### Backup Your Keys

**IMPORTANT:** Your private keys are in the hidden service directory.

```bash
# Create backup
sudo tar -czf ~/onion-service-backup.tar.gz /var/lib/tor/my-onion-site/

# Secure the backup
chmod 600 ~/onion-service-backup.tar.gz
```

**⚠️ WARNING:** If you lose these keys, you lose your .onion address forever!

---

## Step 6: Test Your Hidden Service

### Using Tor Browser (Recommended)

1. **Open Tor Browser** (installed in previous tutorial)
2. **Paste your .onion address** into the address bar
3. **Press Enter**

You should see your website!

### Troubleshooting Connection Issues

If your site doesn't load:

**1. Check Tor is running:**
```bash
sudo systemctl status tor
```

**2. Check nginx is running:**
```bash
sudo systemctl status nginx
```

**3. Verify the hostname file exists:**
```bash
ls -la /var/lib/tor/my-onion-site/
# Should show: hostname, private_key, hs_ed25519_public_key, hs_ed25519_secret_key
```

**4. Check Tor logs for errors:**
```bash
sudo journalctl -u tor -f
```

**5. Verify nginx is listening on port 8080:**
```bash
sudo netstat -tlnp | grep 8080
```

**6. Test local nginx:**
```bash
curl http://127.0.0.1:8080
```

---

## Step 7: Security Hardening

### Nginx Security

**Disable server tokens:**

```bash
sudo nano /etc/nginx/nginx.conf
```

Add inside `http {}` block:

```nginx
server_tokens off;
```

**Restart nginx:**
```bash
sudo systemctl reload nginx
```

### Tor Security

**Monitor Tor logs:**

```bash
# Watch logs in real-time
sudo journalctl -u tor -f
```

**Check Tor's self-test:**

```bash
# Look for "Self-testing indicates your ORPort is reachable"
sudo grep "Self-testing" /var/log/tor/log
```

### Firewall Configuration

**Block direct access to nginx (optional but recommended):**

```bash
# Install ufw if not already installed
sudo apt install ufw -y

# Allow SSH (important!)
sudo ufw allow ssh

# Enable firewall
sudo ufw enable

# Verify nginx is NOT accessible externally
# (it should only listen on 127.0.0.1:8080)
```

### File Permissions

```bash
# Restrict access to hidden service directory
sudo chmod 700 /var/lib/tor/my-onion-site/
sudo chown -R debian-tor:debian-tor /var/lib/tor/my-onion-site/

# Secure website files
sudo chmod -R 755 /var/www/onion-site/
```

---

## Advanced Configuration

### Multiple Hidden Services

You can run multiple hidden services on the same machine:

```bash
sudo nano /etc/tor/torrc
```

**Add multiple services:**

```bash
# First hidden service
HiddenServiceDir /var/lib/tor/service1/
HiddenServicePort 80 127.0.0.1:8080

# Second hidden service
HiddenServiceDir /var/lib/tor/service2/
HiddenServicePort 80 127.0.0.1:8081

# Third hidden service (different protocol)
HiddenServiceDir /var/lib/tor/service3/
HiddenServicePort 22 127.0.0.1:22  # SSH over Tor
```

### Custom .onion Address (Vanity Address)

Generate a custom .onion address with a specific prefix:

```bash
# Install mkp224o (vanity address generator)
sudo apt install gcc libsodium-dev make autoconf -y

cd ~/Downloads
git clone https://github.com/cathugger/mkp224o.git
cd mkp224o
./autogen.sh
./configure
make

# Generate address starting with "ranger"
./mkp224o ranger -d ~/onion-keys

# This can take hours/days depending on length!
# Longer prefixes = exponentially longer time
```

**Replace keys:**

```bash
# Stop Tor
sudo systemctl stop tor

# Backup old keys
sudo mv /var/lib/tor/my-onion-site/ /var/lib/tor/my-onion-site.backup

# Copy new keys
sudo cp -r ~/onion-keys/ranger* /var/lib/tor/my-onion-site/

# Fix permissions
sudo chown -R debian-tor:debian-tor /var/lib/tor/my-onion-site/
sudo chmod 700 /var/lib/tor/my-onion-site/

# Restart Tor
sudo systemctl start tor
```

### Authentication (Client Authorization)

Require clients to have authorization keys to access your service:

**Generate client key:**

```bash
# Create key directory
mkdir -p /var/lib/tor/my-onion-site/authorized_clients/

# Generate client key
tor --keygen --newkey > /tmp/client.auth

# Move to authorized clients
sudo mv /tmp/client.auth /var/lib/tor/my-onion-site/authorized_clients/client1.auth

# Fix permissions
sudo chown -R debian-tor:debian-tor /var/lib/tor/my-onion-site/
sudo chmod 600 /var/lib/tor/my-onion-site/authorized_clients/*

# Restart Tor
sudo systemctl restart tor
```

Clients need the private key to access your service.

---

## Monitoring and Maintenance

### Check Service Status

```bash
# Create monitoring script
nano ~/check-onion.sh
```

**Add this content:**

```bash
#!/bin/bash

echo "=== Tor Hidden Service Status ==="
echo ""

# Check Tor status
echo "1. Tor Service:"
sudo systemctl is-active tor
echo ""

# Check nginx status
echo "2. Nginx Service:"
sudo systemctl is-active nginx
echo ""

# Check onion address
echo "3. Your .onion Address:"
sudo cat /var/lib/tor/my-onion-site/hostname
echo ""

# Check local nginx
echo "4. Local Nginx Test:"
curl -s http://127.0.0.1:8080 | head -n 5
echo "..."
echo ""

# Check Tor circuits
echo "5. Recent Tor Activity:"
sudo journalctl -u tor --since "5 minutes ago" | tail -n 10
```

**Make executable:**

```bash
chmod +x ~/check-onion.sh
```

**Run it:**

```bash
./check-onion.sh
```

### Automatic Service Recovery

Create a systemd service to auto-restart if it fails:

```bash
sudo nano /etc/systemd/system/tor-watchdog.service
```

**Add:**

```ini
[Unit]
Description=Tor Hidden Service Watchdog
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart tor
ExecStart=/usr/bin/systemctl restart nginx

[Install]
WantedBy=multi-user.target
```

**Enable:**

```bash
sudo systemctl enable tor-watchdog.service
```

### Log Rotation

Prevent logs from filling disk:

```bash
sudo nano /etc/logrotate.d/onion-service
```

**Add:**

```
/var/log/nginx/onion-error.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
}
```

---

## Performance Optimization

### Tor Configuration Tweaks

```bash
sudo nano /etc/tor/torrc
```

**Add performance options:**

```bash
# Increase circuit build timeout
CircuitBuildTimeout 60

# Number of intro points (balance between performance and anonymity)
HiddenServiceNumIntroductionPoints 5

# Enable caching
HiddenServiceMaxStreamsCloseCircuit 1
```

### Nginx Optimization

```bash
sudo nano /etc/nginx/sites-available/onion-site
```

**Add inside server block:**

```nginx
# Enable gzip compression
gzip on;
gzip_vary on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

# Enable caching
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## Troubleshooting

### Site Not Loading in Tor Browser

**Symptom:** Connection times out or "Unable to connect"

**Solutions:**

1. **Wait 5-10 minutes** after starting Tor (it takes time to establish circuits)

2. **Check Tor logs for errors:**
   ```bash
   sudo journalctl -u tor -n 100
   ```

3. **Verify hostname file exists:**
   ```bash
   sudo cat /var/lib/tor/my-onion-site/hostname
   ```

4. **Restart both services:**
   ```bash
   sudo systemctl restart tor nginx
   ```

### "403 Forbidden" Error

**Cause:** Permission issues

**Solution:**

```bash
# Fix permissions
sudo chown -R www-data:www-data /var/www/onion-site/
sudo chmod -R 755 /var/www/onion-site/

# Restart nginx
sudo systemctl restart nginx
```

### "502 Bad Gateway" Error

**Cause:** Nginx can't reach backend service

**Solution:**

```bash
# Check if nginx is running
sudo systemctl status nginx

# Verify port 8080 is listening
sudo netstat -tlnp | grep 8080

# Test local connection
curl http://127.0.0.1:8080
```

### My Website Files Aren't Showing (Common Mistake!)

**Symptom:** Site loads but shows default nginx page, or changes to HTML don't appear

**Cause:** Website files are in the wrong directory

**The Confusion:**
Many beginners mistakenly put their website files in `/var/lib/tor/my-onion-site/` thinking that's where the site goes. **This is wrong!**

**Solution:**

```bash
# Check where your files actually are
ls -la /var/lib/tor/my-onion-site/
# Should ONLY show: hostname, hs_ed25519_public_key, hs_ed25519_secret_key

ls -la /var/www/onion-site/
# Should show: index.html, css/, images/, etc.

# If your files are in the wrong place, move them:
sudo mv /var/lib/tor/my-onion-site/index.html /var/www/onion-site/
sudo mv /var/lib/tor/my-onion-site/css /var/www/onion-site/
# etc.

# Verify nginx config points to correct directory
grep "root" /etc/nginx/sites-available/onion-site
# Should show: root /var/www/onion-site;

# Fix permissions
sudo chown -R www-data:www-data /var/www/onion-site/
sudo chmod -R 755 /var/www/onion-site/

# Restart nginx
sudo systemctl restart nginx
```

**Remember:**
- **`/var/lib/tor/my-onion-site/`** = Tor's crypto keys (DON'T put website here!)
- **`/var/www/onion-site/`** = Your website files (PUT website here!)

### Lost .onion Address After Reboot

**Cause:** Hidden service directory was deleted or moved

**Solution:**

```bash
# Restore from backup
sudo tar -xzf ~/onion-service-backup.tar.gz -C /

# Fix permissions
sudo chown -R debian-tor:debian-tor /var/lib/tor/my-onion-site/
sudo chmod 700 /var/lib/tor/my-onion-site/

# Restart Tor
sudo systemctl restart tor
```

### Tor Won't Start

**Symptom:** `systemctl status tor` shows failed

**Check logs:**

```bash
sudo journalctl -u tor -n 50
```

**Common issues:**

1. **Syntax error in torrc:**
   ```bash
   tor --verify-config
   ```

2. **Permission issues:**
   ```bash
   sudo chown -R debian-tor:debian-tor /var/lib/tor/
   sudo chmod 700 /var/lib/tor/
   ```

3. **Port conflict:**
   ```bash
   # Check if port 9050 is in use
   sudo netstat -tlnp | grep 9050
   ```

---

## Security Best Practices

### ✅ DO:

1. **Keep software updated:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Monitor logs regularly:**
   ```bash
   sudo journalctl -u tor -f
   ```

3. **Backup your keys weekly:**
   ```bash
   sudo tar -czf ~/onion-backup-$(date +%F).tar.gz /var/lib/tor/my-onion-site/
   ```

4. **Use HTTPS for sensitive data** (even on Tor)

5. **Disable unnecessary services:**
   ```bash
   sudo systemctl disable bluetooth cups
   ```

6. **Use strong passwords** for any authentication

7. **Regularly check for unauthorized access:**
   ```bash
   sudo last
   sudo journalctl -u ssh
   ```

### ❌ DON'T:

1. **Don't expose your real IP** by linking to external resources
2. **Don't use the same server** for clearnet and hidden services
3. **Don't log visitor information** (defeats anonymity)
4. **Don't share your private keys** (in `/var/lib/tor/`)
5. **Don't use weak or default passwords**
6. **Don't run unnecessary network services**
7. **Don't trust user input** without validation/sanitization

### Legal Considerations

- **Know your local laws** regarding Tor and hidden services
- **Don't host illegal content** (respect laws of your jurisdiction)
- **Consider liability** of content hosted on your service
- **Terms of Service:** Follow your ISP/hosting provider ToS
- **Keep records** of what you host (for legal defense if needed)

---

## Use Cases and Examples

### 1. Private Blog

Host a censorship-resistant blog:

```bash
# Install static site generator
sudo apt install hugo -y

# Create blog
hugo new site /var/www/onion-site
cd /var/www/onion-site
hugo new posts/my-first-post.md

# Build site
hugo

# Point nginx to public/ directory
sudo nano /etc/nginx/sites-available/onion-site
# Change: root /var/www/onion-site/public;
```

### 2. File Sharing

Simple file sharing service:

```bash
# Create uploads directory
mkdir -p /var/www/onion-site/files
chmod 755 /var/www/onion-site/files

# Enable directory listing in nginx
sudo nano /etc/nginx/sites-available/onion-site
```

**Add:**

```nginx
location /files/ {
    autoindex on;
    autoindex_exact_size off;
    autoindex_localtime on;
}
```

### 3. Secure Communication

Set up OnionShare-like functionality:

```bash
# Install OnionShare
sudo apt install onionshare -y

# Use OnionShare's built-in hidden service
onionshare --receive
```

### 4. Development Testing

Test web applications before public release:

```bash
# Use any web framework
# Example with Python Flask:
pip install flask

# Create app.py
cat > /var/www/onion-site/app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return '<h1>Test Application</h1>'

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
EOF

# Update nginx to proxy to Flask
# (Configure as reverse proxy)
```

---

## Upgrading and Updating

### Update Tor

```bash
# Update package lists
sudo apt update

# Upgrade Tor
sudo apt upgrade tor -y

# Restart service
sudo systemctl restart tor

# Verify version
tor --version
```

### Migrate to New Server

**On old server:**

```bash
# Backup everything
sudo tar -czf onion-complete-backup.tar.gz \
  /var/lib/tor/my-onion-site/ \
  /var/www/onion-site/ \
  /etc/nginx/sites-available/onion-site \
  /etc/tor/torrc

# Transfer to new server
scp onion-complete-backup.tar.gz user@newserver:/tmp/
```

**On new server:**

```bash
# Install packages
sudo apt install tor nginx -y

# Extract backup
sudo tar -xzf /tmp/onion-complete-backup.tar.gz -C /

# Fix permissions
sudo chown -R debian-tor:debian-tor /var/lib/tor/
sudo chown -R www-data:www-data /var/www/onion-site/

# Enable site
sudo ln -s /etc/nginx/sites-available/onion-site /etc/nginx/sites-enabled/

# Start services
sudo systemctl restart tor nginx
```

Your .onion address will remain the same!

---

## Conclusion

You now have a fully functional Tor hidden service! Your website is:

✅ **Anonymous** - Your server's IP is hidden
✅ **Encrypted** - All traffic is end-to-end encrypted
✅ **Censorship-resistant** - Can't be blocked by IP
✅ **Private** - No visitor tracking or logging
✅ **Yours** - Complete control over content and data

### Key Takeaways

1. **Hidden services provide bidirectional anonymity**
2. **Your .onion address is tied to cryptographic keys**
3. **Always backup your hidden service directory**
4. **Monitor logs for security and performance**
5. **Keep Tor and nginx updated**
6. **Follow security best practices**
7. **Respect laws and ethical considerations**

### Next Steps

- **Customize your site** with more advanced content
- **Add HTTPS** using self-signed certificates
- **Implement authentication** for private areas
- **Set up monitoring** with automated alerts
- **Create multiple services** for different purposes
- **Generate vanity addresses** for branding
- **Join the community** at Tor Project forums

---

## Quick Reference

### Directory Cheat Sheet

**Remember these two directories and their purposes:**

```
/var/lib/tor/my-onion-site/     ← Tor's cryptographic files (READ ONLY)
    ├── hostname                  Your .onion address
    ├── hs_ed25519_secret_key    Private key (NEVER SHARE!)
    └── hs_ed25519_public_key    Public key

/var/www/onion-site/            ← YOUR WEBSITE FILES (EDIT THESE!)
    ├── index.html               Your homepage
    ├── css/                     Stylesheets
    ├── images/                  Images
    └── ...                      All your web content
```

**Golden Rule:**
- **Tor touches** `/var/lib/tor/` (you backup, but don't edit)
- **You touch** `/var/www/` (you create, edit, update)

### Essential Commands

```bash
# Start services
sudo systemctl start tor nginx

# Stop services
sudo systemctl stop tor nginx

# Restart services
sudo systemctl restart tor nginx

# Check status
sudo systemctl status tor nginx

# View .onion address
sudo cat /var/lib/tor/my-onion-site/hostname

# Monitor Tor logs
sudo journalctl -u tor -f

# Test nginx locally
curl http://127.0.0.1:8080

# Backup hidden service
sudo tar -czf ~/onion-backup.tar.gz /var/lib/tor/my-onion-site/

# Check Tor config syntax
tor --verify-config

# Reload nginx config
sudo nginx -t && sudo systemctl reload nginx
```

---

## Additional Resources

- **Tor Project Documentation:** https://community.torproject.org/onion-services/
- **Tor Hidden Service Protocol:** https://gitweb.torproject.org/torspec.git/tree/rend-spec-v3.txt
- **Nginx Documentation:** https://nginx.org/en/docs/
- **OnionShare:** https://onionshare.org/
- **SecureDrop:** https://securedrop.org/
- **Tor Forum:** https://forum.torproject.org/
- **DarknetLive Guide:** https://darknetlive.com/guides/

---

## Support This Content

If this guide helped you create your own Tor hidden service, consider supporting more tutorials like this!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

Your support helps create more in-depth guides on privacy, security, and anonymity technologies!

---

**Disclaimer:** This guide is for educational purposes. Always comply with local laws and regulations. The author is not responsible for how you use this information. Tor hidden services can be used for both legitimate and illegitimate purposes—use responsibly.

**Note:** This guide was written on 2025-11-17 for Kali Linux ARM64/x86-64. Commands may vary slightly on other distributions.
