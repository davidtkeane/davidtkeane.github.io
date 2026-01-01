---
title: "Setting Up a Tor Relay on macOS: Complete Guide with IP Rotation"
date: 2025-12-31 15:00:00 +0000
categories: [Privacy, Networking]
tags: [tor, macos, relay, privacy, nyx, networking, vodafone, port-forwarding]
pin: false
math: false
mermaid: false
---

## Overview

This guide documents setting up a Tor relay on macOS (M4 Max MacBook Pro), including troubleshooting issues, port forwarding on a Vodafone Gigabox router, monitoring with nyx, and creating an IP rotation script. If you've seen tools like `tornet` on YouTube but can't run them on macOS, this guide is for you!

## Why Run a Tor Relay?

By running a Tor relay, you help others stay anonymous online. Your relay becomes part of the Tor network, routing encrypted traffic for journalists, activists, researchers, and privacy-conscious users worldwide.

**Types of Tor Relays:**

| Type | What It Sees | Risk Level |
|------|--------------|------------|
| Guard (Entry) | User's real IP | Low |
| Middle | Neither user nor destination | Lowest |
| Exit | Destination websites | Highest |
| Bridge | Unlisted entry for censored users | Low |

This guide sets up a **Middle Relay** - the safest option that still helps the network.

---

## Prerequisites

- macOS (tested on M4 Max, works on M1/M2/M3/Intel)
- Homebrew installed
- Router access for port forwarding
- Terminal familiarity

---

## Step 1: Install Tor

```bash
brew install tor
```

Verify installation:
```bash
tor --version
```

---

## Step 2: Configure Tor as a Relay

Edit the Tor configuration file:
```bash
nano /opt/homebrew/etc/tor/torrc
```

Add or modify these lines:
```bash
# Basic relay configuration
Nickname YourRelayName
ORPort 9001
SocksPort 9050
ControlPort 9051

# Your public IP (find with: curl ifconfig.me)
Address YOUR_PUBLIC_IP

# Contact info (optional but recommended)
ContactInfo your@email.com

# Bandwidth limits (adjust to your connection)
RelayBandwidthRate 1 MB
RelayBandwidthBurst 2 MB
AccountingMax 40 GB
AccountingStart month 3 15:00

# IMPORTANT: This makes you a Middle relay (NOT an exit)
ExitPolicy reject *:*
```

Save with `Ctrl+O`, `Enter`, `Ctrl+X`.

---

## Step 3: Start Tor

```bash
brew services start tor
```

Check status:
```bash
brew services list | grep tor
```

View logs:
```bash
tail -f /opt/homebrew/var/log/tor.log
```

---

## Mistake #1: Trying to Use systemctl on macOS

**What I tried:**
```bash
sudo systemctl start tor
```

**Error:**
```
System has not been booted with systemd as init system (PID 1). Can't operate.
```

**Why it failed:** macOS doesn't use systemd - that's a Linux thing!

**The fix:** Use Homebrew services:
```bash
brew services start tor    # Start
brew services stop tor     # Stop
brew services restart tor  # Restart
brew services list         # Check status
```

---

## Mistake #2: tornet Doesn't Work on macOS

**What I tried:**
```bash
tornet --interval 2 --count 0
```

**Error:**
```
[!] No supported service manager found (systemctl or service)
```

**Why:** tornet expects Linux service managers.

**The fix:** Use `nyx` instead (official Tor monitor) or create your own IP rotation script (shown below).

---

## Step 4: Port Forwarding (Vodafone Gigabox)

Your relay needs port 9001 open to the internet.

### Find Your Local IP
```bash
ipconfig getifaddr en0
# Example: 192.168.1.38
```

### Access Your Router
1. Open browser: `http://192.168.1.1`
2. Login (check sticker on router for credentials)

### Add Port Forward Rule

Navigate to: **Internet** → **Port Forwarding** (or **Advanced** → **NAT**)

| Field | Value |
|-------|-------|
| Name | Tor Relay |
| Protocol | TCP |
| External Port | 9001 |
| Internal IP | 192.168.1.38 (your Mac's IP) |
| Internal Port | 9001 |
| Enable | Yes |

Save and apply.

### Verify Port is Open

Use these online tools:
- [https://canyouseeme.org/](https://canyouseeme.org/) - Enter port 9001
- [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/)

**Expected result:** Port 9001 is OPEN

---

## Mistake #3: Wrong IP in Tor Config

**What happened:**
```
[WARN] Your server has not managed to confirm reachability for its ORPort(s) at 109.77.12.130:9001
```

But my current IP was different!

**Why:** My public IP had changed (dynamic IP from ISP).

**The fix:**
```bash
# Get current public IP
curl ifconfig.me

# Update torrc
nano /opt/homebrew/etc/tor/torrc
# Change: Address YOUR_CURRENT_IP

# Restart Tor
brew services restart tor
```

**Tip:** If you have a dynamic IP, consider removing the `Address` line and letting Tor auto-detect, or set up Dynamic DNS.

---

## Mistake #4: macOS Firewall Blocking Tor

**Symptoms:** Port shows closed even with router forwarding.

**Check firewall status:**
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

**Add Tor exception:**
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/tor
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/tor
```

---

## Success: Relay is Live!

After fixing the IP and port forwarding:
```
[NOTICE] Self-testing indicates your ORPort 109.78.86.31:9001 is reachable from the outside. Excellent.
[NOTICE] Publishing server descriptor.
```

Check your relay online (after 1-3 hours):
- [https://metrics.torproject.org/rs.html](https://metrics.torproject.org/rs.html) - Search your relay name

---

## Step 5: Install nyx (Tor Monitor)

nyx is the official Tor relay monitor - like `tornet` but works on macOS!

```bash
brew install nyx
```

Run it:
```bash
nyx
```

### nyx Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `←` `→` | Switch pages |
| `g` | Bandwidth graph |
| `c` | Connections |
| `l` | Logs |
| `n` | New Identity (rotate IP) |
| `q` | Quit |

---

## Step 6: IP Rotation Script (tornet Alternative)

Since tornet doesn't work on macOS, here's a custom script that does the same thing!

### Create the Script

Save as `~/scripts/tor-rotate.sh`:

```bash
#!/bin/bash
#
# Tor IP Rotation Script
# Rotates Tor exit IP every N seconds
#

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default interval (seconds)
INTERVAL=${1:-10}

echo -e "${CYAN}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║       TOR IP ROTATOR - CipherStream   ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Rotating IP every ${INTERVAL} seconds${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Counter
count=0

while true; do
    count=$((count + 1))

    # Request new circuit
    echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\nQUIT' | nc 127.0.0.1 9051 > /dev/null 2>&1

    # Wait for circuit to establish
    sleep 2

    # Get new IP
    NEW_IP=$(curl -s --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip 2>/dev/null | grep -o '"IP":"[^"]*"' | cut -d'"' -f4)

    # Get timestamp
    TIMESTAMP=$(date '+%H:%M:%S')

    # Display
    echo -e "${GREEN}[${count}]${NC} ${TIMESTAMP} - New IP: ${CYAN}${NEW_IP}${NC}"

    # Wait for next rotation (minus the 2 seconds we already waited)
    sleep $((INTERVAL - 2))
done
```

### Make Executable

```bash
chmod +x ~/scripts/tor-rotate.sh
```

### Usage

```bash
# Default: Rotate every 10 seconds
~/scripts/tor-rotate.sh

# Custom: Rotate every 30 seconds
~/scripts/tor-rotate.sh 30
```

### Sample Output

```
  ╔═══════════════════════════════════════╗
  ║       TOR IP ROTATOR - CipherStream   ║
  ╚═══════════════════════════════════════╝

Rotating IP every 10 seconds
Press Ctrl+C to stop

[1] 14:35:10 - New IP: 185.220.101.45
[2] 14:35:20 - New IP: 23.129.64.142
[3] 14:35:30 - New IP: 51.15.43.205
[4] 14:35:40 - New IP: 109.70.100.31
```

### Add Alias

```bash
echo 'alias tor-rotate="~/scripts/tor-rotate.sh"' >> ~/.zshrc
source ~/.zshrc
```

Now just run:
```bash
tor-rotate
tor-rotate 20  # Custom interval
```

---

## Important: Relay vs Client

**Your relay and browsing are separate:**

| Component | Port | Purpose |
|-----------|------|---------|
| Relay (ORPort) | 9001 | Helps others - PUBLIC |
| Client (SOCKS) | 9050 | Your browsing - ANONYMOUS |

- IP rotation only affects YOUR browsing (port 9050)
- Your relay uptime and stats are NOT affected
- You can browse anonymously while helping the network!

---

## Useful Commands Cheatsheet

```bash
# Tor Service
brew services start tor
brew services stop tor
brew services restart tor
brew services list | grep tor

# Check Tor is running
ps aux | grep -w tor

# View logs
tail -f /opt/homebrew/var/log/tor.log

# Test your anonymity
curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip

# Get your public IP
curl ifconfig.me

# Monitor with nyx
nyx

# Rotate IP manually
echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\nQUIT' | nc 127.0.0.1 9051

# Check port is listening
lsof -i :9001
lsof -i :9050
```

---

## Helpful Aliases

Add to `~/.zshrc`:

```bash
# Tor aliases
alias tor-start='brew services start tor'
alias tor-stop='brew services stop tor'
alias tor-restart='brew services restart tor'
alias tor-status='brew services list | grep tor'
alias tor-logs='tail -f /opt/homebrew/var/log/tor.log'
alias tor-ip='curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip'
alias tor-rotate='~/scripts/tor-rotate.sh'
alias torcurl='curl --socks5 127.0.0.1:9050'
```

---

## Configure Firefox for Tor

1. Open Firefox → Settings → Network Settings
2. Select "Manual proxy configuration"
3. SOCKS Host: `127.0.0.1`
4. Port: `9050`
5. Select "SOCKS v5"
6. Check "Proxy DNS when using SOCKS v5"
7. Click OK

Verify at: [https://check.torproject.org/](https://check.torproject.org/)

---

## Port Check URLs

- [https://canyouseeme.org/](https://canyouseeme.org/)
- [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/)
- [https://portchecker.co/](https://portchecker.co/)

---

## Check Your Relay Status

After a few hours online:
- [https://metrics.torproject.org/rs.html](https://metrics.torproject.org/rs.html) - Search your nickname or fingerprint

Your relay info will show:
- Uptime
- Bandwidth
- Country
- Flags earned (Stable, Fast, Valid, etc.)

---

## Summary

| Problem | Solution |
|---------|----------|
| systemctl not found | Use `brew services` |
| tornet not working | Use `nyx` or `tor-rotate.sh` |
| Port closed | Forward port 9001 on router |
| Wrong IP in config | Update `Address` in torrc |
| Firewall blocking | Add Tor exception |

---

## Key Takeaways

1. **Homebrew manages Tor on macOS** - not systemctl
2. **tornet is Linux-only** - use nyx + custom scripts on Mac
3. **Port 9001 must be forwarded** - check with online tools
4. **Middle relays are safest** - use `ExitPolicy reject *:*`
5. **Relay and client are separate** - IP rotation doesn't affect relay uptime
6. **nyx is your friend** - official Tor monitor that works on macOS

---

## Resources

- [Tor Project](https://www.torproject.org/)
- [Tor Relay Guide](https://community.torproject.org/relay/)
- [nyx Documentation](https://nyx.torproject.org/)
- [Tor Metrics - Relay Search](https://metrics.torproject.org/rs.html)
- [Homebrew](https://brew.sh/)

---

*Running a Tor relay is a small contribution that makes a big difference. You're helping journalists, activists, and privacy-conscious users worldwide stay safe online.*

**Welcome to the Tor network!** 🧅

