---
title: "CipherStream Tor Relay: Running Strong From 2025 to 2026!"
date: 2026-01-01 05:30:00 +0000
categories: [Privacy, Milestones]
tags: [tor, relay, privacy, new-year, cipherstream, nyx, networking]
pin: false
math: false
mermaid: false
---

## Happy New Year! The Relay That Spans Two Years!

That's right - my Tor relay **CipherStream** has been running since 2025 and is STILL going strong in 2026!

*Technically* that means it's been up for an entire year... right?

*(Okay fine, it's been about 12 hours, but it DOES span two calendar years!)*

## The Stats at Midnight

As the clock struck midnight on New Year's Eve, here's what CipherStream was doing:

| Metric | Value |
|--------|-------|
| **Uptime** | 12 hours (spanning 2 years!) |
| **Data Sent** | 689.23 MB |
| **Data Received** | 705.27 MB |
| **Circuits Open** | 10 |
| **Connections Served** | 1,043 |
| **NTor Handshakes** | 109/109 (100% success!) |

## What CipherStream Does

CipherStream is a **middle relay** in the Tor network. This means:

- It helps route encrypted traffic for users worldwide
- It sees neither the source nor destination of traffic
- It contributes bandwidth to the Tor network
- It helps journalists, activists, and privacy-conscious people stay anonymous

```
User → [Guard Relay] → [CipherStream] → [Exit Relay] → Internet
                            ↑
                     You are here!
```

## The Heartbeat Logs

Every 6 hours, Tor sends a "heartbeat" showing the relay's health:

```
[NOTICE] Heartbeat: Tor's uptime is 12:00 hours, with 10 circuits open.
I've sent 689.23 MB and received 705.27 MB.
I've received 1043 connections on IPv4 and 0 on IPv6.
I've made 275 connections with IPv4 and 0 with IPv6.
```

```
[NOTICE] Circuit handshake stats since last time: 0/0 TAP, 109/109 NTor.
```

**100% NTor handshake success rate** - the relay is performing perfectly!

## Bandwidth Accounting

I've configured CipherStream with a 40GB monthly limit to avoid killing my internet:

```
[NOTICE] Heartbeat: Accounting enabled.
Sent: 697.36 MB, Received: 801.97 MB,
Used: 801.97 MB / 40.00 GB, Rule: max.
The current accounting interval ends on 2026-01-03 15:00:00
```

**Only 2% of monthly quota used** - plenty of room to help more users!

## The Setup

Running on my M4 Max MacBook Pro with this config:

```bash
# /opt/homebrew/etc/tor/torrc
Nickname CipherStream
ORPort 9001
ContactInfo your@email.com

# Bandwidth limits
AccountingMax 40 GB
AccountingStart month 3 15:00

# Relay type (middle only, no exit)
ExitPolicy reject *:*
```

## Monitoring with Nyx

I use **nyx** (the Tor relay monitor) to watch the relay in real-time:

```bash
# Install
brew install nyx

# Run
nyx
```

It shows beautiful real-time graphs of:
- Bandwidth usage
- Connection counts
- Circuit information
- Log messages

## The IPv6 "Issue"

You might notice this in the logs:

```
[NOTICE] Unable to find IPv6 address for ORPort 9001
```

**This is NOT an error!** It's just Tor noting that I don't have IPv6. The relay works perfectly fine on IPv4 only.

To silence it, add to torrc:
```bash
ORPort 9001 IPv4Only
```

## New Year's Resolutions for CipherStream

For 2026, my Tor relay goals are:

1. **Increase bandwidth limit** - Maybe bump to 100GB/month
2. **Get the Stable flag** - Requires 7+ days uptime
3. **Get the Guard flag** - Requires good uptime and bandwidth
4. **Help more users** - Every connection counts!

## Why Run a Tor Relay?

Every relay makes the Tor network:
- **Faster** - More bandwidth for everyone
- **Stronger** - Harder to attack or surveil
- **More anonymous** - More relays = better privacy

If you have spare bandwidth, consider running a relay too! Check out my full guide: [Setting Up a Tor Relay on macOS](/posts/setting-up-tor-relay-macos/)

## Cheers to 2026!

Here's to another year of:
- Privacy for everyone
- Fighting surveillance
- Helping people communicate freely
- Making the internet a better place

**CipherStream**: Running from 2025 to 2026 and beyond!

---

## Quick Stats Summary

```
╔══════════════════════════════════════════════════════╗
║           CIPHERSTREAM TOR RELAY                     ║
╠══════════════════════════════════════════════════════╣
║  Status:        ONLINE                               ║
║  Uptime:        12 hours (2 calendar years!)         ║
║  Fingerprint:   908581586DCB67BBEC17D2D5DCE69A2D... ║
║  Sent:          689.23 MB                            ║
║  Received:      705.27 MB                            ║
║  Circuits:      10 active                            ║
║  Connections:   1,043 served                         ║
║  Quota:         2% used (801 MB / 40 GB)             ║
╚══════════════════════════════════════════════════════╝
```

---

*Happy New Year from CipherStream! Here's to privacy, freedom, and a great 2026!*

**Remember:** Running a Tor relay is legal, ethical, and helps people around the world access information freely. Be part of the solution!

