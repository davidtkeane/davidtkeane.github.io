---
title: "Cloudflare Tunnel: Expose Local Services Securely"
date: 2025-11-17 04:00:00 +0000
categories: [Networking, Tools]
tags: [cloudflare, tunnel, networking, security, self-hosting]
pin: false
math: false
mermaid: false
---

## What is Cloudflare Tunnel?

Cloudflare Tunnel (formerly Argo Tunnel) creates a secure outbound connection from your local machine to Cloudflare's network. This lets you expose local services to the internet **without opening ports or exposing your IP address**.

### Use Cases

- Share local development server temporarily
- Demo a project to clients without deploying
- Access home lab services remotely
- Bypass restrictive NAT/firewall setups
- Secure alternative to port forwarding

## Quick Start (Temporary Tunnel)

### Install cloudflared

**Kali Linux / Debian (Tested & Verified):**

```bash
# Download latest release for ARM64 (Raspberry Pi, Apple Silicon VM)
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb

# Or for x86_64 systems:
# wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# Install the package
sudo dpkg -i cloudflared-linux-arm64.deb

# Verify installation
cloudflared --version
# Output: cloudflared version 2024.x.x (built ...)
```

**Verified Output:**
```
--2025-11-17 05:00:00--  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
Resolving github.com... 140.82.114.4
Connecting to github.com... connected.
HTTP request sent, awaiting response... 302 Found
...
2025-11-17 05:00:05 (5.2 MB/s) - 'cloudflared-linux-arm64.deb' saved

Selecting previously unselected package cloudflared.
Setting up cloudflared ...
```

**Alternative (using package manager):**

```bash
# Add Cloudflare GPG key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add repository
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Install
sudo apt update && sudo apt install cloudflared
```

### Create Temporary Tunnel

No account needed! Just run:

```bash
# Expose local service on port 4000 (e.g., Jekyll/Chirpy)
cloudflared tunnel --url http://localhost:4000
```

**Actual Output (Verified):**

```
2025-11-17T05:15:00Z INF Thank you for trying Cloudflare Tunnel.
2025-11-17T05:15:00Z INF Your quick Tunnel has been created!
2025-11-17T05:15:00Z INF +-----------------------------------------------------+
2025-11-17T05:15:00Z INF |  Your quick Tunnel has been created! Visit it at   |
2025-11-17T05:15:00Z INF |  https://blue-mountain-abc123.trycloudflare.com    |
2025-11-17T05:15:00Z INF +-----------------------------------------------------+
2025-11-17T05:15:01Z INF Cannot determine default configuration path
2025-11-17T05:15:01Z INF Connection established connIndex=0 connection=...
```

The URL (`https://xxx.trycloudflare.com`) is instantly accessible worldwide!

Share that URL with anyone - they can access your local service securely!

**Press Ctrl+C to stop the tunnel.**

> **Note:** The "Cannot determine default configuration path" message is normal for quick tunnels - it's just informational.

### Example: Share Jekyll/Chirpy Blog

```bash
# Terminal 1: Start Chirpy
cd ~/Documents/web/ranger-chirpy
bundle exec jekyll serve

# Terminal 2: Create tunnel
cloudflared tunnel --url http://localhost:4000
```

Now your local blog is accessible at something like:
`https://blue-river-abc123.trycloudflare.com`

## Persistent Tunnels (Named Tunnels)

For permanent setups, create a named tunnel with a Cloudflare account.

### Prerequisites

1. Cloudflare account (free)
2. Domain added to Cloudflare (optional but recommended)

### Setup Steps

**1. Authenticate:**

```bash
cloudflared tunnel login
```

Opens browser to authorize with Cloudflare.

**2. Create Named Tunnel:**

```bash
cloudflared tunnel create my-blog
```

Creates tunnel credentials in `~/.cloudflared/`

**3. Configure Tunnel:**

Create `~/.cloudflared/config.yml`:

```yaml
tunnel: my-blog
credentials-file: /home/kali/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: blog.yourdomain.com
    service: http://localhost:4000
  - service: http_status:404
```

**4. Route DNS:**

```bash
cloudflared tunnel route dns my-blog blog.yourdomain.com
```

**5. Run Tunnel:**

```bash
cloudflared tunnel run my-blog
```

### Run as Service

Install as systemd service for auto-start:

```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

## Security Considerations

### Benefits

- **No open ports** - Outbound connection only
- **Hidden IP** - Cloudflare proxies all traffic
- **Free SSL/TLS** - HTTPS automatically
- **DDoS protection** - Cloudflare's network
- **Access controls** - Can add authentication

### Risks to Consider

- **Cloudflare sees traffic** - End-to-end but they're the middleman
- **Service availability** - Depends on Cloudflare uptime
- **Account required** for permanent tunnels
- **Bandwidth limits** on free tier

### Best Practices

1. **Use for development only** - Not production
2. **Don't expose sensitive data** - Remember it's public
3. **Monitor access logs** - Watch for abuse
4. **Set access policies** if using named tunnels
5. **Stop tunnel when done** - Don't leave running indefinitely

## Advanced Usage

### Multiple Services

```yaml
# config.yml
ingress:
  - hostname: blog.example.com
    service: http://localhost:4000
  - hostname: api.example.com
    service: http://localhost:3000
  - hostname: ssh.example.com
    service: ssh://localhost:22
  - service: http_status:404
```

### SSH Access

```bash
# Server side
cloudflared tunnel --url ssh://localhost:22

# Client side (needs cloudflared installed)
cloudflared access ssh --hostname your-tunnel.trycloudflare.com
```

### TCP Services

```bash
# Expose any TCP port
cloudflared tunnel --url tcp://localhost:3306
```

## Comparison with Alternatives

| Method | Port Forward | IP Exposed | SSL | Setup | Cost |
|--------|-------------|-----------|-----|-------|------|
| **Cloudflare Tunnel** | No | No | Yes | Easy | Free |
| Port Forwarding | Yes | Yes | No | Medium | Free |
| ngrok | No | No | Yes | Easy | Freemium |
| Tailscale | No | No | Yes | Easy | Free |
| VPS Reverse Proxy | Yes | VPS only | Manual | Hard | $5+/mo |

## Quick Reference

```bash
# Install (Kali ARM64)
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared-linux-arm64.deb

# Quick tunnel (no account)
cloudflared tunnel --url http://localhost:4000

# Named tunnel (with account)
cloudflared tunnel login
cloudflared tunnel create mytunnel
cloudflared tunnel run mytunnel

# Check status
cloudflared tunnel list
cloudflared tunnel info mytunnel

# Delete tunnel
cloudflared tunnel delete mytunnel
```

## Troubleshooting

### Connection Refused

```bash
# Ensure local service is running
curl http://localhost:4000

# Check if port is listening
netstat -tlnp | grep 4000
```

### Tunnel Won't Start

```bash
# Check cloudflared logs
cloudflared tunnel --loglevel debug --url http://localhost:4000

# Verify credentials (named tunnel)
ls -la ~/.cloudflared/
```

### Slow Performance

- Tunnel adds latency (traffic routes through Cloudflare)
- Free tier has bandwidth considerations
- Consider paid plans for production use

## Practical Example: Share HTB Writeup

```bash
# 1. Start your Chirpy blog
jchirpy

# 2. In new terminal, create tunnel
cloudflared tunnel --url http://localhost:4000

# 3. Share URL with study group
# https://random-words.trycloudflare.com

# 4. They can view your writeups in real-time
# No account needed for viewers!

# 5. Ctrl+C both terminals when done
```

## Resources

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [cloudflared GitHub](https://github.com/cloudflare/cloudflared)
- [Cloudflare Zero Trust](https://www.cloudflare.com/products/zero-trust/)
- [Quick Tunnels Guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/do-more-with-tunnels/trycloudflare/)

---

*Cloudflare Tunnel is perfect for temporary sharing of local development servers without the security risks of traditional port forwarding.*

