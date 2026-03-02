---
layout: post
title: "PinchTab — Browser Automation Bridge for AI Agents"
date: 2026-03-02 20:00:00 +0000
categories: [AI, Automation, Tools]
tags: [pinchtab, browser-automation, ai-agents, chrome, golang, n8n, homelab, tutorial]
author: David Keane
description: "PinchTab is a 9MB Go binary that gives AI agents direct control over Chrome. Here's how I installed it, tested it against my own site, and plan to use it with n8n workflows."
---

# PinchTab — Browser Automation Bridge for AI Agents

I came across [PinchTab](https://github.com/pinchtab/pinchtab) today — a 9MB Go binary that gives AI agents direct control over a Chrome browser via HTTP. Created on February 15, 2026 and already at 2,800+ stars. Here's what it does and how I got it running in minutes.

**What you'll have at the end:**
- ✅ PinchTab running locally on your Mac
- ✅ AI agents controlling Chrome via HTTP API
- ✅ 5-13x cheaper page extraction than screenshots
- ✅ Ready to integrate with n8n workflows

**Time required:** ~5 minutes
**Cost:** Free (MIT licence)
**Language:** Go (single binary, no dependencies)

---

## What is PinchTab?

PinchTab is a standalone HTTP server that lets AI agents control a Chrome browser programmatically. Instead of taking screenshots (expensive in tokens), it extracts the accessibility tree — clean structured text at around 800 tokens per page.

```
AI Agent / n8n Workflow
        ↓
  HTTP API (:9867)
        ↓
    PinchTab
        ↓
   Chrome Browser
```

It supports both headless and headed Chrome, persistent sessions, stealth injection to avoid bot detection, and multi-instance orchestration for parallel tasks.

---

## Installation — macOS Apple Silicon (M3/M4)

**Step 1 — Download the binary**

```bash
curl -L -o pinchtab https://github.com/pinchtab/pinchtab/releases/download/v0.7.6/pinchtab-darwin-arm64
chmod +x pinchtab
```

**Step 2 — Add to PATH**

```bash
sudo cp pinchtab /usr/local/bin/pinchtab
```

**Step 3 — Verify**

```bash
pinchtab --version
# pinchtab 0.7.6
```

That's it. Single binary, no dependencies, no Docker required.

---

## Quick Test

**Terminal 1 — Start the server:**

```bash
pinchtab
# Starts on http://127.0.0.1:9867
```

**Terminal 2 — Test it:**

```bash
# Navigate to a URL
pinchtab nav https://davidtkeane.com
```

Output:
```json
{
  "title": "Ranger Products - Transform Disabilities into Superpowers | David T. Keane",
  "url": "https://davidtkeane.com/"
}
```

Works immediately. No config, no API keys, no setup.

---

## Full Command Reference

```bash
# Navigation
pinchtab nav <url>                    # Navigate to URL

# Page inspection
pinchtab snap -i -c                   # Interactive elements only (compact)
pinchtab snap -d                      # Only changes since last snapshot
pinchtab text                         # Extract all readable text
pinchtab text --raw                   # Raw text extraction

# Interaction
pinchtab click <ref>                  # Click element by reference
pinchtab type <ref> <text>            # Type into element
pinchtab press <key>                  # Press key (Enter, Tab, Escape)
pinchtab fill <ref> <text>            # Fill input directly
pinchtab hover <ref>                  # Hover element
pinchtab scroll <ref|pixels>          # Scroll to element or by pixels
pinchtab select <ref> <value>         # Select dropdown option
pinchtab focus <ref>                  # Focus element

# Output
pinchtab ss -o screenshot.png         # Screenshot
pinchtab pdf -o page.pdf              # Export as PDF
pinchtab eval "document.title"        # Run JavaScript

# Management
pinchtab tabs                         # List tabs
pinchtab tabs new <url>               # Open new tab
pinchtab tabs close <id>              # Close tab
pinchtab health                       # Check server status
pinchtab dashboard                    # Profile orchestrator UI
```

---

## Token Efficiency — Why This Matters

| Method | Tokens per page | Cost ratio |
|--------|----------------|------------|
| Screenshot (GPT-4o) | ~4,000–10,000 | Expensive |
| PinchTab accessibility tree | ~800 | **5-13x cheaper** |

For AI agents that browse many pages, this is a significant saving. Instead of sending a PNG to a vision model, you send clean structured text.

---

## Environment Variables

```bash
PINCHTAB_URL=http://127.0.0.1:9867   # Server URL (for CLI)
BRIDGE_TOKEN=your-secret-token        # Auth token (optional)
BRIDGE_PORT=9867                      # Change port
BRIDGE_HEADLESS=true                  # Run headless (default)
```

---

## Integration with n8n

Since PinchTab exposes an HTTP API on port 9867, you can control it directly from n8n using **HTTP Request** nodes:

```
n8n HTTP Request node
  → POST http://127.0.0.1:9867/navigate
  → Body: { "url": "https://example.com" }
```

Combine with the **AI Agent** node in n8n for fully autonomous web browsing workflows — navigate, extract, interact, repeat.

---

## Use Cases

- **Web scraping** — extract structured data from any site
- **AI agent browsing** — let your AI agents navigate and interact with websites
- **Automated testing** — click through flows and verify pages
- **Price monitoring** — check token/crypto prices on DEX sites
- **Form automation** — fill and submit forms programmatically
- **PDF generation** — export any web page as a clean PDF

---

## Linux / VPS Installation

```bash
# Download linux-amd64 binary
curl -L -o pinchtab https://github.com/pinchtab/pinchtab/releases/download/v0.7.6/pinchtab-linux-amd64
chmod +x pinchtab
sudo mv pinchtab /usr/local/bin/

# Run headless (required on VPS — no display)
BRIDGE_HEADLESS=true pinchtab
```

Works on Ubuntu 24.04. Needs Chrome or Chromium installed:

```bash
sudo apt install -y chromium-browser
```

---

## Resources

- [PinchTab GitHub](https://github.com/pinchtab/pinchtab)
- [Releases](https://github.com/pinchtab/pinchtab/releases)
- [n8n](https://n8n.io)

---

## Support This Content

If this guide saved you time, consider buying me a coffee!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

---

*Written 2026-03-02 — tested on M3 Pro Mac with PinchTab v0.7.6. Single binary install, working in under 5 minutes.*

*Rangers lead the way!* 🎖️
