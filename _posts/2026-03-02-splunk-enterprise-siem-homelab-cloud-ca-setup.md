---
layout: post
title: "Splunk Enterprise SIEM — Real Attack Data from a Home Lab Fleet"
date: 2026-03-02 01:00:00 +0000
categories: [Security, Cloud, SIEM]
tags: [splunk, siem, homelab, cloud, security, blue-team, aws, tailscale, ubuntu, amazon-linux, tutorial]
author: David Keane
description: "How I set up Splunk Enterprise 10.2.1 as a SIEM on an OVH VPS and shipped real logs from a Hostinger Red Team VPS and AWS EC2 — including every problem I hit and exactly how I fixed it."
---

# Splunk Enterprise SIEM — Real Attack Data from a Home Lab Fleet

This is a real-world walkthrough of setting up Splunk Enterprise as a SIEM across a multi-server home lab fleet, done as part of a Cloud Computing CA assignment. By the end I had real SSH brute force attacks and audit events flowing into a central dashboard — not simulated lab data, actual live attacks.

**What you'll have at the end:**
- ✅ Splunk Enterprise 10.2.1 running on an OVH VPS
- ✅ Universal Forwarder shipping logs from a Hostinger VPS (Ubuntu 24.04)
- ✅ Universal Forwarder shipping logs from AWS EC2 (Amazon Linux 2023)
- ✅ Real SSH brute force attacks visible in Splunk within minutes
- ✅ All traffic over Tailscale — no public ports exposed

**Time required:** ~2-3 hours
**Cost:** Free (Splunk 60-day trial → 500MB/day free tier)
**Skill level:** Intermediate

---

## Infrastructure Overview

```
Fleet Nodes (Universal Forwarder — free, lightweight)
├── Hostinger Red Team VPS  (Ubuntu 24.04)  → UF → OVH:9997
├── AWS EC2                 (Amazon Linux 2023) → UF → OVH:9997
└── [More nodes planned]
                                    ↓
                    Splunk Enterprise (OVH VPS)
                    Web UI: http://100.77.2.103:8000
                    Indexer port: 9997
                    All via Tailscale (private, encrypted)
```

All communication runs over Tailscale (WireGuard) — no public ports needed on the Splunk server.

---

## Part 1 — Install Splunk Enterprise on OVH VPS

### The VPS

| Detail | Value |
|--------|-------|
| Provider | OVH |
| Model | VPS-2 (6 vCores, 12GB RAM, 100GB SSD) |
| OS | Ubuntu 24.04 |
| Location | Gravelines, France |

### Step 1 — SSH in and check resources

```bash
ssh blueteam
uname -m        # x86_64
free -h         # confirm 12GB RAM
df -h /         # confirm 100GB disk
```

### Step 2 — Download Splunk Enterprise

Get the download link from [splunk.com/download](https://www.splunk.com/en_us/download/splunk-enterprise.html) — you need to register (free). Download the `.deb` for Ubuntu:

```bash
wget -O splunk.deb 'https://download.splunk.com/products/splunk/releases/10.2.1/linux/splunk-10.2.1-c892b66d163d-linux-amd64.deb'
```

**My download:** 1.24GB at 31MB/s — took 41 seconds.

### Step 3 — Install

```bash
sudo dpkg -i splunk.deb
```

> You'll see a harmless warning: `find: python3.7 site-packages: No such file or directory` — ignore it. Install completes successfully.

### Step 4 — Start and set admin password

```bash
sudo /opt/splunk/bin/splunk start --accept-license
# Set your admin username and password when prompted
```

### Step 5 — Enable boot-start

```bash
sudo /opt/splunk/bin/splunk enable boot-start
# Creates /etc/init.d/splunk — auto-starts on reboot
```

### Step 6 — Firewall (Tailscale-only access)

```bash
# Allow Tailscale subnet only — no public access
sudo ufw allow from 100.64.0.0/10 to any port 8000
sudo ufw allow from 100.64.0.0/10 to any port 9997
```

### Step 7 — Configure receiving port

In Splunk Web UI → Settings → Forwarding and Receiving → Configure Receiving → Add port **9997**.

### Step 8 — Access the UI

```
http://100.77.2.103:8000
```

Via Tailscale from any device on your network. No open public ports needed.

---

## Part 2 — Universal Forwarder on Hostinger Red Team (Ubuntu 24.04)

The UF is free, lightweight, and ships logs to your Splunk indexer.

### Step 1 — Download UF

```bash
ssh redteam
wget -O splunkuf.deb 'https://download.splunk.com/products/universalforwarder/releases/10.2.1/linux/splunkforwarder-10.2.1-c892b66d163d-linux-amd64.deb'
```

### Step 2 — Install

```bash
sudo dpkg -i splunkuf.deb
```

### Step 3 — Seed credentials (do this BEFORE starting)

This saves you a painful auth loop later (I learned the hard way):

```bash
sudo mkdir -p /opt/splunkforwarder/etc/system/local

sudo sh -c 'echo "[user_info]" > /opt/splunkforwarder/etc/system/local/user-seed.conf'
sudo sh -c 'echo "USERNAME = admin" >> /opt/splunkforwarder/etc/system/local/user-seed.conf'
sudo sh -c 'echo "PASSWORD = YourPassword" >> /opt/splunkforwarder/etc/system/local/user-seed.conf'

sudo sh -c 'echo "[general]" > /opt/splunkforwarder/etc/system/local/server.conf'
sudo sh -c 'echo "allowRemoteLogin = always" >> /opt/splunkforwarder/etc/system/local/server.conf'
```

### Step 4 — Start

```bash
sudo /opt/splunkforwarder/bin/splunk start --accept-license
```

### Step 5 — Point at Splunk indexer

```bash
sudo /opt/splunkforwarder/bin/splunk add forward-server 100.77.2.103:9997 -auth admin:YourPassword
```

### Step 6 — Add log monitors

```bash
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/syslog -index main -auth admin:YourPassword
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index main -auth admin:YourPassword
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/fail2ban.log -index main -auth admin:YourPassword
```

### Step 7 — Enable boot-start and restart

```bash
sudo /opt/splunkforwarder/bin/splunk enable boot-start
sudo /opt/splunkforwarder/bin/splunk restart
```

### Verify in Splunk

```
index=* host=red-team
```

Within 60 seconds you'll see live SSH brute force attempts hitting your server.

---

## Part 3 — Universal Forwarder on AWS EC2 (Amazon Linux 2023)

AWS EC2 on Amazon Linux 2023 has two differences from Ubuntu:
1. Uses `rpm` not `dpkg`
2. Log file paths are different (`/var/log/messages` → doesn't exist, use `/var/log/audit/audit.log`)

### Problem — No internet on EC2

My EC2 instance has no NAT gateway so `wget` fails. Solution: download on your local machine and SCP it over.

**On your Mac:**
```bash
wget -O splunkuf.rpm 'https://download.splunk.com/products/universalforwarder/releases/10.2.1/linux/splunkforwarder-10.2.1-c892b66d163d.x86_64.rpm'

# SCP to EC2 via Tailscale
scp -i ~/.ssh/your-key.pem splunkuf.rpm ec2-user@100.x.x.x:~/
```

> Note the `-i` flag must come BEFORE the source file — easy mistake to make.

### Step 1 — Install (RPM not dpkg!)

```bash
ssh ec2-user@your-tailscale-ip
sudo rpm -i splunkuf.rpm
```

> You'll see `Header V4 RSA/SHA256 Signature... NOKEY` — harmless, just the Splunk signing key not in your RPM keyring.

### Step 2 — Seed credentials

```bash
sudo sh -c 'echo "[user_info]" > /opt/splunkforwarder/etc/system/local/user-seed.conf'
sudo sh -c 'echo "USERNAME = admin" >> /opt/splunkforwarder/etc/system/local/user-seed.conf'
sudo sh -c 'echo "PASSWORD = YourPassword" >> /opt/splunkforwarder/etc/system/local/user-seed.conf'

sudo sh -c 'echo "[general]" > /opt/splunkforwarder/etc/system/local/server.conf'
sudo sh -c 'echo "allowRemoteLogin = always" >> /opt/splunkforwarder/etc/system/local/server.conf'
```

### Step 3 — Start and configure

```bash
sudo /opt/splunkforwarder/bin/splunk start --accept-license
sudo /opt/splunkforwarder/bin/splunk add forward-server 100.77.2.103:9997 -auth admin:YourPassword
```

### Step 4 — Add monitors (Amazon Linux paths)

```bash
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/audit/audit.log -index main -auth admin:YourPassword
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/httpd/access_log -index main -auth admin:YourPassword
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/httpd/error_log -index main -auth admin:YourPassword
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/cloud-init.log -index main -auth admin:YourPassword
```

### Step 5 — Boot-start and restart

```bash
sudo /opt/splunkforwarder/bin/splunk enable boot-start
sudo /opt/splunkforwarder/bin/splunk restart
```

### Verify in Splunk

⚠️ **Important:** The hostname in Splunk will be the EC2 **internal DNS name**, not the Tailscale name.

```
index=* host=ip-172-31-18-130.ec2.internal
```

Or search all:
```
index=* earliest=-15m
```

---

## Troubleshooting Reference

| Problem | Cause | Fix |
|---------|-------|-----|
| `Login failed` with correct password | Special character (e.g. `/`) in password breaking shell | Wrap in single quotes: `-auth 'user:pass/word'` |
| `No users exist. Please set up a user.` | Passwd file deleted, UF started without prompting | Create `user-seed.conf` before starting |
| `Remote login disabled for admin with default password` | Splunk blocks remote ops with default password | Add `allowRemoteLogin = always` to `server.conf` |
| `boot-start` warning — unit file exists | Systemd unit already created by RPM install | Safe to ignore — already configured |
| `Path must be a file or directory` | Log file doesn't exist on Amazon Linux 2023 | Use `/var/log/audit/audit.log` not `/var/log/messages` |
| `splunkuf.rpm: not an rpm package` | Corrupt/failed previous download (HTML error page) | Re-download or SCP fresh copy from Mac |
| `scp: Permission denied` | Wrong syntax — key file treated as source file | Put `-i key.pem` BEFORE source file |
| 0 events in Splunk | Searching wrong hostname | AWS host = EC2 internal DNS (`ip-172-x.ec2.internal`) |

---

## What's Flowing in Splunk

**Red Team VPS (host=red-team):**

Real SSH brute force attempts hitting the server every few minutes:

```
type=auth: Connection closed by invalid user admin 142.93.40.206
type=fail2ban: NOTICE [sshd] Unban 165.227.120.134
type=auth: Connection closed by authenticating user root 188.166.23.177
```

**AWS EC2 (host=ip-172-31-18-130.ec2.internal):**

Full audit trail of system events:

```
type=SERVICE_START: unit=refresh-policy-routes@ens5
type=USER_START: op=PAM:session_open acct=root exe=/usr/bin/sudo
type=CRED_DISP: op=PAM:setcred UID=ec2-user
```

Every sudo command you run is logged, timestamped, and in your SIEM.

---

## SPL Queries for Your CA Report

```spl
# SSH brute force attackers ranked by attempt count
index=main host=red-team sourcetype=auth "Invalid user"
| stats count by src_ip
| sort -count

# All fail2ban bans
index=main host=red-team sourcetype=fail2ban "Ban"
| table _time, src_ip

# AWS sudo activity
index=main host=ip-172-31-18-130.ec2.internal "sudo"
| table _time, type, uid

# All hosts summary
index=main
| stats count by host, sourcetype
| sort -count
```

---

## Cost

| Item | Cost |
|------|------|
| Splunk (60-day trial) | Free — unlimited indexing |
| Splunk (after 60 days) | Free — 500MB/day limit |
| AWS data transfer (~10MB/day logs) | ~€0.03/month |
| OVH VPS | Already paying |
| **Total extra cost** | **~€0.03/month** |

For a home lab SIEM setup this is essentially free.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│              Tailscale Mesh (WireGuard)              │
│                  100.64.0.0/10                       │
├──────────────────┬──────────────────────────────────┤
│                  │                                   │
│  Hostinger VPS   │    AWS EC2                        │
│  100.103.164.7   │    100.119.131.76                 │
│  [UF] auth.log   │    [UF] audit.log                 │
│       fail2ban   │         httpd logs                │
│                  │                                   │
└──────────┬───────┴───────────────────────────────────┘
           │  port 9997 (encrypted via Tailscale)
           ▼
    OVH Blue Team VPS
    100.77.2.103
    Splunk Enterprise 10.2.1
    Web UI: :8000
```

---

## Resources

- [Splunk Enterprise Download](https://www.splunk.com/en_us/download/splunk-enterprise.html)
- [Splunk Universal Forwarder](https://www.splunk.com/en_us/download/universal-forwarder.html)
- [Splunk Docs — Install on Linux](https://docs.splunk.com/Documentation/Splunk/latest/Installation/InstallonLinux)
- [Tailscale](https://tailscale.com)

---

## Support This Content

If this guide saved you time, consider buying me a coffee!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

---

*Written 2026-03-02 — based on a real Cloud CA setup session. All steps verified working with Splunk Enterprise 10.2.1 on OVH VPS-2 and Universal Forwarders on Hostinger Ubuntu 24.04 and AWS EC2 Amazon Linux 2023.*

*Rangers lead the way!* 🎖️
