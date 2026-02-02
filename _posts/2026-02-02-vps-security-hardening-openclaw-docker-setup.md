---
title: "From Zero to Secure VPS: Docker, OpenClaw, and HellCoin in One Night"
date: 2026-02-02 21:00:00 +0000
categories: [Infrastructure, Security]
tags: [vps, hostinger, docker, openclaw, security, ufw, ssh, hardening, solana, hellcoin, forgiveme-life, tor, cryptocurrency, devops, linux, ubuntu, tutorial]
pin: false
math: false
mermaid: false
---

## Overview

Tonight I went from a bare Hostinger KVM VPS to a fully secured server running OpenClaw in Docker -- accessible only through an SSH tunnel on a custom port. Along the way, I learned about Docker port mapping security, discovered a port-parsing bug in OpenClaw's CLI, and saved myself EUR30 per month by killing my AWS instance.

This post covers the full journey: VPS hardening, Docker installation, OpenClaw deployment, the mistakes I made, and the security decisions behind every choice.

---

## Who Am I?

My name is David Keane. I am a 51-year-old student pursuing my Masters in Cybersecurity at the University of Galway (via NCI Dublin). I am dyslexic, ADHD, and autistic -- diagnosed at 39 -- and I have spent 14 years turning those diagnoses into superpowers.

I am building [ForgivMe.life](https://forgiveme.life/) -- an anonymous confession website where visitors can "pay for their burdens" with HellCoin (H3LL), a Solana token I created. Tonight's VPS setup is part of a bigger infrastructure plan for my college AI class demo.

---

## The Problem

I had too many things running on expensive, insecure, or unreliable platforms:

- **AWS Free Tier** was charging me EUR30/month for a simple relay server
- **Tor hidden service** was running on my Mac (dies when I close the lid)
- **No server** for future bots, APIs, or always-on services
- **OpenClaw** (AI agent platform) needed a secure home for Moltbook registration

I needed a single VPS that could handle everything, secured properly from day one.

---

## The Solution: Hostinger KVM 2 VPS

I purchased a Hostinger KVM 2 VPS for about EUR200 for 2 years. That works out to roughly EUR8.33 per month -- compared to the EUR30 per month AWS was bleeding from me.

**Specs:**
- Ubuntu 24.04.3 LTS (Noble Numbat)
- Kernel 6.8.0-90
- Full root access
- Docker capable

I also grabbed two free domains: **confesstoai.org** and **h3llcoin.cloud**.

---

## Step 1: Security Hardening (The Right Way)

### Change the Default Password

Hostinger gives you a random root password. First thing -- change it through hPanel. Never keep default credentials.

### Create a Non-Root User

```bash
adduser --disabled-password --gecos "Ranger" ranger
usermod -aG sudo ranger
echo "ranger ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ranger
chmod 440 /etc/sudoers.d/ranger
```

### Set Up SSH Key Authentication

From your local machine, copy your public key:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo 'ssh-rsa YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Copy the same key to your non-root user's home directory.

### Lock Down SSH

Edit `/etc/ssh/sshd_config`:

```
PermitRootLogin no
PasswordAuthentication no
```

Then restart SSH: `systemctl restart ssh`

**What I should have done:** Test the non-root user login BEFORE disabling root. If you lock yourself out, you need hPanel console access to fix it.

### Configure UFW Firewall

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable
```

Only three ports open. Everything else is blocked.

---

## Step 2: Install Docker and Node.js

Docker from the official repository (not the Ubuntu snap):

```bash
# Add Docker GPG key and repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Gotcha:** Hostinger had a pre-existing Docker GPG key at a different path. I got a "Conflicting values for Signed-By" error. Fix: remove the old key file and let your fresh install take over.

Node.js 22 LTS via NodeSource:

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install nodejs
```

Result: Docker 29.2.1, Node.js 22.22.0, npm 10.9.4.

---

## Step 3: OpenClaw on a Custom Port (The Security Deep Dive)

This is where it gets interesting. OpenClaw is an AI agent platform that listens on port **18789** by default. The problem? Shodan bots actively scan for this port. If you expose it, you are found within hours.

### The Three-Layer Security Approach

**Layer 1: Custom Port Mapping**

OpenClaw is hardcoded to listen on 18789 inside its container. You cannot change that. But Docker can remap it:

```bash
docker run -p 127.0.0.1:2404:18789 openclaw
```

This maps the internal 18789 to external 2404. I chose 2404 -- my birth month and year. Easy to remember, impossible to guess.

**Layer 2: Loopback Binding**

The `127.0.0.1` prefix is critical. Without it, Docker defaults to `0.0.0.0` -- meaning the port is exposed to the entire internet. With it, only processes on the VPS itself can connect.

**Layer 3: SSH Tunnel**

To access OpenClaw from my Mac:

```bash
ssh -4 -i ~/.ssh/mac_to_mac_rsa -L 2404:127.0.0.1:2404 ranger@76.13.37.73
```

Then open `http://127.0.0.1:2404` in a browser. The traffic is encrypted through SSH. No port needs to be opened in the firewall.

### The Docker Bind Bug I Discovered

OpenClaw's `--bind` flag accepts keywords like `loopback`, `lan`, `auto` -- NOT IP addresses. I initially set `--bind 127.0.0.1` and got:

```
Invalid --bind (use "loopback", "lan", "tailnet", "auto", or "custom")
```

But here is the real trap: setting `--bind loopback` makes OpenClaw listen on `127.0.0.1` **inside the Docker container**. Docker's port forwarding connects to the container via its virtual network interface, NOT its loopback. So the traffic never arrives.

**Fix:** Use `--bind lan` inside the container (binds to `0.0.0.0` internally), and let Docker handle the security externally with `127.0.0.1:2404:18789`.

### The Port Parsing Bug

OpenClaw's CLI uses the `OPENCLAW_GATEWAY_PORT` environment variable. Docker Compose needs this set to `127.0.0.1:2404` for the port mapping. But OpenClaw's code does:

```javascript
const parsed = Number.parseInt(envRaw, 10);
```

`parseInt("127.0.0.1:2404")` returns `127`. So the CLI tries to connect to `ws://127.0.0.1:127` and fails silently.

**Fix:** When running CLI commands via `docker compose exec`, override the env var:

```bash
docker compose exec -e OPENCLAW_GATEWAY_PORT=18789 openclaw-gateway node dist/index.js devices list
```

### The Device Pairing Requirement

Even after connecting with the gateway token, OpenClaw requires device pairing. The browser sends a pairing request that must be approved from the CLI:

```bash
docker compose exec -e OPENCLAW_GATEWAY_PORT=18789 openclaw-gateway node dist/index.js devices list
# Shows pending request with UUID
docker compose exec -e OPENCLAW_GATEWAY_PORT=18789 openclaw-gateway node dist/index.js devices approve <UUID>
```

After approval, refresh the browser and you are in.

---

## Step 4: The Bigger Picture

This VPS is one piece of a larger infrastructure:

| Service | Platform | Status |
|---------|----------|--------|
| ForgivMe.life (website) | InMotion Hosting | Live |
| HellCoin tip widget | wallet.js + Solana | Working |
| Phantom + Solflare wallets | Browser extensions | Integrated |
| OpenClaw AI agent | Hostinger VPS (Docker) | Running |
| Tor hidden service | Currently on Mac | Moving to VPS |
| RangerChat relay | AWS (stopped) | Migrating to VPS |
| confesstoai.org | Hostinger | Pending |
| H3LL auto-delivery bot | VPS | Pending |

The goal: demonstrate the entire ecosystem for my college AI class.

---

## Mistakes I Made

1. **Tried to SSH with special characters in the password non-interactively.** The Hostinger default password had `;` and `?` which break shell escaping. Should have used hPanel or SSH keys from the start.

2. **Set `--bind loopback` for Docker container.** Docker networking means the container's loopback is not reachable from the host's port mapping. Use `--bind lan` inside, `127.0.0.1` outside.

3. **Used `config.json` instead of `openclaw.json`.** OpenClaw reads its config from `~/.openclaw/openclaw.json`. I created `config.json` and wondered why nothing changed.

4. **Passed `127.0.0.1:2404` as `OPENCLAW_GATEWAY_PORT`.** JavaScript's `parseInt` happily parses `"127.0.0.1:2404"` as `127`. No error, just silent failure.

5. **Almost bought a second VPS for EUR200.** Hostinger offered a pre-installed OpenClaw VPS. My AI assistant talked me out of it -- Docker install takes 10 minutes and one VPS handles everything.

---

## What I Learned

- **Docker port mapping is your firewall.** The `127.0.0.1:` prefix is more important than any application-level bind setting.
- **SSH tunnels replace VPNs for single-service access.** No additional software, no port exposure, encrypted by default.
- **Always test your non-root user BEFORE disabling root login.** Otherwise you are locked out.
- **`parseInt` in JavaScript is dangerous.** It silently parses partial strings. `parseInt("127.0.0.1:2404")` is `127`, not an error.
- **Default ports are a security liability.** Shodan indexes them. Change them. Even on loopback, the habit matters.
- **One VPS can replace multiple cloud services.** I was paying EUR30/month for AWS when EUR8/month covers everything.

---

## The Money Saved

| Before | After |
|--------|-------|
| AWS: EUR30/month | Stopped (EUR0) |
| No VPS | Hostinger: EUR8.33/month (2yr) |
| No domains | confesstoai.org + h3llcoin.cloud (free yr1) |
| **Total: EUR360/year** | **Total: EUR100/year** |

That is EUR260 saved per year, with more capability.

---

## What is Next

- Move the Tor hidden service from my Mac to the VPS (always-on)
- Migrate the RangerChat relay from AWS
- Deploy ForgivMe.life v2 with the HellCoin tip widget
- Register ForgiveMeBot on Moltbook (the AI social network)
- Add Metaplex metadata to H3LL so it stops showing as "Unknown Token"
- Build the H3LL auto-delivery bot
- Demo everything for college

One foot in front of the other.

---

## Resources

- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw Docker Docs](https://docs.openclaw.ai/install/docker)
- [Docker Port Binding Docs](https://docs.docker.com/engine/network/#published-ports)
- [UFW Essentials](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)
- [SSH Tunneling Explained](https://www.ssh.com/academy/ssh/tunneling)

---

*Written by David Keane -- Masters student, HellCoin creator, and someone who learned the hard way that `parseInt("127.0.0.1")` equals `127`.*
