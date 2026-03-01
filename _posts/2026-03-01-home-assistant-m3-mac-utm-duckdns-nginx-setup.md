---
layout: post
title: "Home Assistant on M3 Mac with UTM, DuckDNS, NGINX & Tailscale — Complete Setup Guide"
date: 2026-03-01 01:00:00 +0000
categories: [Homelab, Cloud, Networking]
tags: [homeassistant, utm, duckdns, nginx, tailscale, m3mac, apple-silicon, homelab, cloud, tutorial]
author: David Keane
description: "Step-by-step guide to running Home Assistant OS on an M3 Mac using UTM, with secure remote HTTPS access via DuckDNS, NGINX, and Tailscale — completely free, no Nabu Casa required."
---

# Home Assistant on M3 Mac — Free Remote Access with DuckDNS, NGINX & Tailscale

Running Home Assistant on an Apple Silicon Mac is easier than you think — but there are some real gotchas that will trip you up. This guide is based on my actual experience setting it up on an M3 Pro Mac, including every problem I hit and exactly how I fixed it.

**What you'll have at the end:**
- ✅ Home Assistant OS running locally in a VM on your M3 Mac
- ✅ Secure HTTPS remote access via DuckDNS + NGINX (no port auth needed)
- ✅ Zero-trust remote access via Tailscale (no open ports needed)
- ✅ DuckDNS keeping your domain pointing at your home IP automatically
- ✅ NGINX handling SSL/TLS encryption
- ✅ Tailscale MagicDNS hostname for easy internal access
- ✅ No Nabu Casa subscription needed

**Time required:** ~2 hours
**Cost:** Free
**Skill level:** Intermediate

---

## What You Need

- M3 Mac (M1/M2/M4 also works)
- UTM virtualisation app (free)
- Home Assistant OS AArch64 image
- A free DuckDNS account
- A free Tailscale account
- Access to your router's port forwarding settings

---

## Part 1 — Install UTM and Home Assistant OS

### Step 1 — Download UTM

Download UTM from the official site — it's free and purpose-built for Apple Silicon:

- [https://mac.getutm.app/](https://mac.getutm.app/)

> The App Store version costs a few euros but auto-updates. The website version is identical and free.

### Step 2 — Download the HA OS Image

Go to the official Home Assistant OS releases page on GitHub and download the AArch64 image:

- Look for: `haos_generic-aarch64-X.X.qcow2.xz`
- Download the latest release

**⚠️ Critical Step — Extract the file BEFORE importing:**

The `.xz` extension means it's compressed. You must extract it first or your VM will boot to an EFI shell (`Shell>`) and go no further.

Open Terminal and run:

```bash
cd ~/Downloads
xz -d haos_generic-aarch64-*.qcow2.xz
```

You should now have a plain `.qcow2` file. That's what you import into UTM.

### Step 3 — Create the VM in UTM

1. Open UTM → click **+** (Create a New Virtual Machine)
2. Select **Virtualize** — NOT Emulate (critical for Apple Silicon performance)
3. Select **Linux**
4. Skip the Boot Image screen → click **Continue**
5. Set RAM to at least **2048 MB** (4GB recommended)
6. Set CPU cores to **2 minimum**
7. Skip storage → **Continue**
8. Skip shared directory → **Continue**
9. Check **"Open VM Settings when created"** → click **Save**

### Step 4 — Replace the Default Disk

This is where most guides skip a step. UTM creates a blank default disk — you need to delete it and import your `.qcow2` instead.

In the VM Settings that just opened:

1. Click **Drives** in the sidebar
2. **Delete** the default drive UTM created
3. Click **New Drive** → **Import**
4. Select your extracted `.qcow2` file
5. Confirm it appears as the only drive

### Step 5 — Set the Network

Still in VM Settings:

1. Click **Network** in the sidebar
2. Mode: **Bridged (Advanced)**
3. Bridged Interface: type `en0` (WiFi) or check yours first:

```bash
# Find your network interface
ping homeassistant.local
# The IP shown tells you which interface to use
ifconfig | grep -A 1 "inet 192"
```

### Step 6 — Resize the Disk (Important!)

**Before starting the VM**, resize the disk. The default HA OS image has almost zero free space, which will block you from installing any add-ons.

1. In UTM Settings → **Drives** → click your qcow2 drive
2. Change size to **32768 MB** (32GB)
3. Click Save

> If you skip this step you'll see: `Failed to install — not enough free space (0.0GB)` when trying to install add-ons.

### Step 7 — Start the VM

Press Play. You'll see a lot of boot text scrolling. After 2-3 minutes you'll see:

```
ha >
```

**That's the Home Assistant CLI — it means HA OS is running correctly.** Don't panic, it's not an error.

Open your Mac browser and go to:

```
http://homeassistant.local:8123
```

Complete the onboarding wizard to create your account.

---

## Part 2 — DuckDNS (Free Dynamic DNS)

Your home broadband IP changes periodically. DuckDNS gives you a stable subdomain that always points to your current IP.

### Step 1 — Create Your Domain

1. Go to [https://www.duckdns.org](https://www.duckdns.org)
2. Sign in with Google or GitHub
3. Create a subdomain (e.g. `myhomelab.duckdns.org`)
4. Copy your **token** — the long string shown at the top of the page

> If your preferred name is taken, try adding a hyphen or number. `cloud-sec.duckdns.org` instead of `cloudsec.duckdns.org` for example.

### Step 2 — Install the DuckDNS Add-on

In Home Assistant:

1. Settings → Add-ons → Add-on Store → search **Duck**
2. Install **DuckDNS**
3. Go to **Configuration tab**

Fill in:

```yaml
domains:
  - yourname.duckdns.org
token: your-token-here
accept_terms: true
```

**Common mistakes that cause errors:**

| Mistake | Error you'll see |
|---------|-----------------|
| Spaces before/after token | `WARNING: KO` |
| Domain without `.duckdns.org` | `does not match regular expression` |
| `accept_terms: false` | `WARNING: KO` |
| Importing `.qcow2.xz` instead of `.qcow2` | `Shell>` EFI prompt on boot |

4. Click **Save**
5. Info tab → enable **Watchdog** → click **Start**
6. Check **Logs** — you want to see:

```
INFO: Starting DuckDNS...
OK
```

### Step 3 — Disable Let's Encrypt in DuckDNS

Leave Let's Encrypt disabled in the DuckDNS add-on. NGINX will handle SSL in the next step. Trying to run Let's Encrypt through DuckDNS causes a `deploy_challenge hook returned with non-zero exit code` error that's tricky to resolve.

Set:
```yaml
lets_encrypt:
  accept_terms: false
```

---

## Part 3 — NGINX (SSL Proxy)

NGINX sits in front of Home Assistant and handles HTTPS encryption. Without it, your connection is unencrypted.

### Step 1 — Install NGINX Add-on

1. Settings → Add-ons → Add-on Store → search **nginx**
2. Install **NGINX Home Assistant SSL proxy**
3. Configuration tab:

```yaml
domain: yourname.duckdns.org
active: true
```

4. Note the port: **443** (you'll need this for port forwarding)
5. Enable **Watchdog** → click **Start**
6. Check Logs — good output looks like:

```
INFO: Generating dhparams (this will take some time)...
INFO: Running nginx...
```

The dhparams generation takes a minute or two — that's normal.

---

## Part 4 — Port Forwarding on Your Router

Your router needs to forward external traffic to your Home Assistant VM.

**Find your HA IP first:**

```bash
ping homeassistant.local
# Returns something like: PING homeassistant.local (192.168.1.16)
```

**Set up the port forwarding rule:**

| Field | Value |
|-------|-------|
| Name | HomeAssistant |
| Protocol | TCP |
| External/WAN Port | 8123 |
| Internal IP | 192.168.1.x (your HA VM's IP) |
| Internal/LAN Port | 443 |

> The WAN port (8123) can be anything you want. The LAN port must match NGINX (443). Using a non-standard external port adds a small layer of security.

Save the rule on your router.

---

## Part 5 — Set External URL in Home Assistant

This makes the HA mobile app work automatically when you leave home:

1. Settings → System → Network
2. **Home Assistant URL** → set to:

```
https://yourname.duckdns.org:8123
```

3. Save

---

## Part 6 — Test It

### Test 1 — DNS resolving correctly

```bash
ping yourname.duckdns.org
# Should return your router's external IP
```

### Test 2 — External HTTPS access

```bash
curl -k https://yourname.duckdns.org:8123
```

Or just open it in your browser. You should see the Home Assistant login page.

---

## Troubleshooting Reference

| Problem | Cause | Fix |
|---------|-------|-----|
| VM shows `Shell>` on boot | `.qcow2.xz` not extracted | Run `xz -d file.qcow2.xz` first |
| VM shows `Shell>` on boot | Selected Emulate instead of Virtualize | Recreate VM, choose Virtualize |
| `Failed to install — 0.0GB free` | Default image has no disk space | Stop VM → UTM → Drives → resize to 32GB |
| `WARNING: KO` in DuckDNS logs | Wrong token / `accept_terms: false` | Check token for spaces, set accept_terms: true |
| `does not match regular expression` | Domain entered without `.duckdns.org` | Use full format: `name.duckdns.org` |
| `deploy_challenge non-zero exit code` | Let's Encrypt DNS challenge failing | Disable LE in DuckDNS, let NGINX handle SSL |
| Site can't be reached externally | Port forwarding not set up | Add rule: WAN 8123 → HA IP:443 |
| `ping https://...` fails | Ping doesn't support https:// prefix | Use `ping domain.duckdns.org` (no https://) |
| Tailscale IP not reachable | Tailscale not running on Mac | Run `tailscale up` on your Mac first |
| `ERR_SSL_UNRECOGNIZED_NAME_ALERT` | Cert not generated yet / serve not enabled | Enable serve in add-on config + HTTPS in Tailscale admin |
| `FATAL: Tailscale's HTTPS support is disabled` | HTTPS certificates not enabled in Tailscale admin | Go to login.tailscale.com/admin/dns → Enable HTTPS |
| Tailscale hostname not resolving | MagicDNS not enabled / --accept-dns missing | Enable MagicDNS in admin console + `tailscale up --accept-dns` |
| `Some peers advertising routes but --accept-routes is false` | Missing flag on tailscale up | Run `tailscale up --accept-routes --accept-dns` |
| Can't find proxy toggle in add-on config | Renamed in newer versions | Look for "Share Home Assistant with Serve or Funnel" → set to `serve` |

---

## Architecture Overview

```
── Public Internet Access (DuckDNS + NGINX) ──
Internet
   │
   ▼
Router (Port Forward: WAN 8123 → LAN 443)
   │
   ▼
NGINX Add-on (port 443) — SSL/TLS termination
   │
   ▼
Home Assistant OS (UTM VM on M3 Mac)
   │
   ▼
Your smart devices

── Private Access (Tailscale) ──
Your phone/laptop (Tailscale)
   │  WireGuard encrypted tunnel
   ▼
Home Assistant OS (Tailscale IP: 100.x.x.x)
   No open router ports required
```

---

## Part 5 (Bonus) — Tailscale (Zero-Trust Remote Access)

Tailscale is a WireGuard-based VPN that connects all your devices into a private network. No open ports required — more secure than DuckDNS + NGINX for private access.

### Step 1 — Install Tailscale Add-on

1. Settings → Add-ons → Add-on Store → search **Tailscale**
2. Install → Start
3. Follow the login link shown in logs to connect HA to your Tailscale account

### Step 2 — Connect Your Mac to Tailscale

Make sure Tailscale is running on your Mac:

```bash
tailscale up --accept-routes --accept-dns
```

> If you skip `--accept-routes`, you won't be able to reach subnets advertised by other Tailscale nodes.
> If you skip `--accept-dns`, MagicDNS hostnames won't resolve.

### Step 3 — Enable MagicDNS and HTTPS Certificates

1. Go to [https://login.tailscale.com/admin/dns](https://login.tailscale.com/admin/dns)
2. Enable **MagicDNS** → Save
3. Scroll down → find **HTTPS Certificates** → click **Enable HTTPS** → Save

> ⚠️ If you skip enabling HTTPS certificates you'll get `FATAL: Tailscale's HTTPS support is disabled` in the add-on logs

### Step 4 — Add Trusted Proxies to configuration.yaml

Open `configuration.yaml` in File Editor and add:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
    - 127.0.0.1
    - 192.168.1.0/24
  ip_ban_enabled: true
  login_attempts_threshold: 5
```

Save → Settings → System → **Restart Home Assistant**

### Step 5 — Enable Tailscale Serve in Add-on

1. Settings → Add-ons → Tailscale → **Configuration tab**
2. Find **"Share Home Assistant with Serve or Funnel"**
3. Change from `disabled` → **`serve`**

> Note: Older video guides call this "proxy" — newer versions of the add-on renamed it to "serve"

4. Leave **Share on port** as **443**
5. Click **Save** → **Restart** the add-on

### Step 6 — Watch the Logs

Settings → Add-ons → Tailscale → **Log tab**

You should see:

```
cert("homeassistant.xxx.ts.net"): registered ACME account.
cert("homeassistant.xxx.ts.net"): requesting cert...
cert("homeassistant.xxx.ts.net"): got cert       ← success!

Available within your tailnet:
https://homeassistant.xxx.ts.net/
|-- proxy http://127.0.0.1:8123
```

### Step 7 — Access HA with Full HTTPS — No Port!

```
https://homeassistant.tailXXXXXX.ts.net
```

You get a proper padlock, a valid TLS certificate, and no port number needed. This works from any device connected to your Tailscale network.

### Verify Tailscale is working

```bash
tailscale status
# Should show homeassistant listed with its Tailscale IP
ping homeassistant.tailXXXXXX.ts.net
# Should resolve to 100.x.x.x
```

---

## Three Ways to Access Home Assistant Remotely

| Method | URL format | Requires | Best for |
|--------|-----------|---------|---------|
| DuckDNS + NGINX | `https://name.duckdns.org:8123` | Open router port | Anyone, any device |
| Tailscale IP | `http://100.x.x.x:8123` | Tailscale on device | Quick access |
| Tailscale hostname | `http://homeassistant.xxx.ts.net:8123` | Tailscale + MagicDNS | Easy to remember |
| **Tailscale HTTPS (Serve)** | `https://homeassistant.xxx.ts.net` | Tailscale Serve + HTTPS cert | **Best — padlock, no port** |

---

## Nabu Casa vs DuckDNS + NGINX + Tailscale

| | Nabu Casa | DuckDNS + NGINX | Tailscale |
|--|-----------|-----------------|-----------|
| Remote access | Yes | Yes | Yes |
| Port forwarding needed | No | Yes | No |
| SSL/HTTPS | Automatic | Manual setup | WireGuard (built-in) |
| Cloud backup | Yes | No | No |
| Cost | ~€6/month | Free | Free (personal) |
| Complexity | Very easy | Medium | Easy |
| Open ports on router | No | Yes | No |

Nabu Casa is the easiest option and supports the HA developers. DuckDNS + NGINX gives you public HTTPS access. Tailscale gives you the most secure private access with zero open ports.

---

## Resources

- [Home Assistant Official Site](https://www.home-assistant.io/)
- [HA macOS Installation Guide](https://www.home-assistant.io/installation/macos/)
- [UTM for Mac](https://mac.getutm.app/)
- [DuckDNS](https://www.duckdns.org)
- [HA Community — UTM Apple Silicon Guide](https://community.home-assistant.io/t/guide-home-assistant-on-apple-silicon-mac-using-ha-os-aarch64-image/444785)
- [YouTube: Secure HA Remote Access with DuckDNS + NGINX](https://www.youtube.com/watch?v=jdyZ6lp1Emg)
- [Tailscale](https://tailscale.com)
- [Tailscale Admin Console — DNS / MagicDNS](https://login.tailscale.com/admin/dns)

---

## Support This Content

If this guide saved you time, consider buying me a coffee!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

---

*Written 2026-03-01 — based on a real setup session on an M3 Pro Mac using UTM 4.3.5 and Tailscale 1.94.1. All steps verified working including full HTTPS via Tailscale Serve.*
