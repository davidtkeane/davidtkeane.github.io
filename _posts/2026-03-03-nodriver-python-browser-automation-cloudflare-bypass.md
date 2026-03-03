---
layout: post
title: "nodriver — Python Browser Automation That Bypasses Cloudflare (Successor to Undetected-Chromedriver)"
date: 2026-03-03 02:00:00 +0000
categories: [AI, Automation, Tools]
tags: [nodriver, browser-automation, python, cloudflare-bypass, webscraping, ai-agents, chrome, tutorial, homelab]
author: David Keane
description: "nodriver is the successor to Undetected-Chromedriver — a fully async Python library that controls Chrome directly via DevTools Protocol, bypasses Cloudflare and anti-bot systems, and requires zero Selenium dependencies. Install, test, and compare with PinchTab."
---

# nodriver — Python Browser Automation That Bypasses Cloudflare

[nodriver](https://github.com/ultrafunkamsterdam/nodriver) is the successor to **Undetected-Chromedriver** — a fully async Python library that controls Chrome directly via the Chrome DevTools Protocol (CDP). No Selenium, no chromedriver binary, no WebDriver fingerprint. It bypasses Cloudflare, hCaptcha, Imperva, and most modern anti-bot systems.

**What you'll have at the end:**
- ✅ nodriver installed in your Python environment
- ✅ Chrome controlled via Python — navigate, extract, screenshot
- ✅ Understanding of how it compares to PinchTab
- ✅ A reusable test script ready to point at any site

**Version:** nodriver 0.48.1
**Language:** Python (fully async)
**License:** AGPL-3.0
**Repo:** [github.com/ultrafunkamsterdam/nodriver](https://github.com/ultrafunkamsterdam/nodriver)

---

## Why nodriver?

Most browser automation tools leave a fingerprint. Selenium sets `navigator.webdriver = true`. Standard chromedriver is detected by virtually every major anti-bot system within milliseconds.

nodriver talks directly to Chrome via CDP — the same protocol Chrome DevTools uses internally. From the website's perspective, it looks like a real user.

```
Your Python Script
      ↓
Chrome DevTools Protocol (WebSocket)
      ↓
Chrome Browser
      ↓
Any Website (Cloudflare, hCaptcha, Imperva — all bypassed)
```

---

## Install

```bash
pip install nodriver
```

That's it. Single package, no binary downloads, no chromedriver management. You need Chrome or Chromium installed (already on your Mac).

Verify:
```bash
pip show nodriver | grep Version
# Version: 0.48.1
```

---

## Quickstart — Navigate and Extract

```python
import asyncio
import nodriver as uc

async def main():
    browser = await uc.start()
    page = await browser.get("https://example.com")
    await asyncio.sleep(2)

    title = await page.evaluate("document.title")
    print(f"Title: {title}")

    browser.stop()

uc.loop().run_until_complete(main())
```

---

## Full Test Script

This is the script I ran against my own site — grabs title, URL, page text, screenshot, and all links:

```python
"""
nodriver test — navigate to a site, extract content, take screenshot
"""

import asyncio
import nodriver as uc


async def main():
    print("Starting Chrome via nodriver...")
    browser = await uc.start(headless=False)  # headless=True for no window

    print("Navigating to davidtkeane.com...")
    page = await browser.get("https://davidtkeane.com")

    await asyncio.sleep(3)  # let page fully load

    # Get page title
    title = await page.evaluate("document.title")
    print(f"\nTitle: {title}")

    # Get page URL
    url = await page.evaluate("window.location.href")
    print(f"URL: {url}")

    # Grab visible text (first 500 chars)
    text = await page.evaluate("document.body.innerText")
    print(f"\nPage text (first 500 chars):\n{text[:500]}")

    # Take a screenshot
    await page.save_screenshot("/tmp/screenshot.png")
    print("\nScreenshot saved to /tmp/screenshot.png")

    # Find all links on page
    links = await page.evaluate("""
        Array.from(document.querySelectorAll('a')).slice(0, 10).map(a => ({
            text: a.innerText.trim(),
            href: a.href
        }))
    """)
    print(f"\nFirst 10 links on page:")
    for link in links:
        if link.get('text') and link.get('href'):
            print(f"  [{link['text'][:40]}] → {link['href'][:60]}")

    await asyncio.sleep(2)
    browser.stop()
    print("\nDone!")


uc.loop().run_until_complete(main())
```

**Output from testing against davidtkeane.com:**

```
Starting Chrome via nodriver...
Navigating to davidtkeane.com...

Title: Ranger Products - Transform Disabilities into Superpowers | David T. Keane
URL: https://davidtkeane.com/

Page text (first 500 chars):
RangerProducts
WP-Notes
Page Builder
Browser
AI Assistant
SEO Tools
Marketplace
Buy Now
Blog

Transforming lives for:
👨‍🏫 Teachers & Students
💼 Employers & Employees
🎓 College Students & Professors
🔧 White Hat Hackers & Modders

Transform Your Disabilities into Superpowers
Built by someone with ADHD, autism, and dyslexia who refused to let labels define limits.
6 products. 1 mission...

Screenshot saved to /tmp/screenshot.png
Done!
successfully removed temp profile /var/folders/.../uc_9rwar9kz
```

Works immediately. Auto-cleans temp profile on exit.

---

## Core API Reference

### Start browser

```python
# Headed (shows browser window)
browser = await uc.start(headless=False)

# Headless (no window — for servers/VPS)
browser = await uc.start(headless=True)
```

### Navigate

```python
page = await browser.get("https://example.com")
await asyncio.sleep(2)  # wait for JS to load
```

### Find elements

```python
# By text content
elem = await page.find("Login")

# By CSS selector
elem = await page.select("input[name='email']")

# By XPath
elem = await page.xpath("//button[@type='submit']")
```

### Interact

```python
# Click
await elem.click()

# Type text
await elem.send_keys("hello@example.com")

# Press key
await page.keyboard.send("Enter")

# Scroll
await page.scroll_down(500)
```

### Extract content

```python
# Page title
title = await page.evaluate("document.title")

# All visible text
text = await page.evaluate("document.body.innerText")

# Run any JavaScript
result = await page.evaluate("window.location.href")
```

### Screenshots and PDFs

```python
# Screenshot
await page.save_screenshot("/tmp/page.png")

# Full page screenshot (scrolling)
await page.save_screenshot("/tmp/full.png", full_page=True)
```

### Tabs

```python
# Open new tab
page2 = await browser.get("https://google.com", new_tab=True)

# List all tabs
print(browser.tabs)
```

### Cookies (session persistence)

```python
# Save cookies after login
await browser.cookies.save("cookies.json")

# Load cookies next run (skip login)
await browser.cookies.load("cookies.json")
```

### Cloudflare bypass

```python
# Auto-solve Cloudflare checkbox (requires opencv-python)
await page.cf_verify()
```

---

## Headless on a Linux VPS

```bash
# Install Chromium on Ubuntu
sudo apt install -y chromium-browser

# Run headless
python3 script.py  # headless=True in uc.start()
```

---

## nodriver vs PinchTab

Both tools control Chrome from code. Different approaches, different strengths:

| Feature | PinchTab | nodriver |
|---------|----------|----------|
| Language | Go (binary) | Python (async) |
| Install | 9MB binary | `pip install nodriver` |
| Interface | HTTP API on port 9867 | Python `async/await` |
| AI integration | HTTP calls from n8n/any tool | Python scripts |
| Anti-bot bypass | Basic | Strong (Cloudflare, hCaptcha) |
| Accessibility tree | ✅ ~800 tokens/page | ❌ use `.innerText` |
| Screenshot | `pinchtab ss` | `page.save_screenshot()` |
| PDF export | `pinchtab pdf` | ❌ not built-in |
| Session persistence | ❌ | ✅ cookie save/load |
| Multi-tab | ✅ | ✅ |
| Cloudflare bypass | ❌ | ✅ |
| Best for | n8n/AI agent HTTP control | Python automation scripts |

**My setup:** Both installed. PinchTab for n8n workflow integration, nodriver for Python scripts needing Cloudflare bypass.

---

## Use Cases

- **Web scraping** — extract data from sites with anti-bot protection
- **Login automation** — log in once, save cookies, reuse session
- **AI agents** — give Python AI scripts a real browser
- **Price monitoring** — check prices on heavily protected e-commerce sites
- **Form automation** — fill and submit forms programmatically
- **Testing** — automated UI testing without Selenium overhead
- **Cloudflare sites** — bypass challenge pages automatically

---

## n8n Integration

Since nodriver is Python, run it as a subprocess from n8n:

```
n8n Execute Command node
  → python3 /opt/scripts/scrape.py --url https://example.com
  → Capture stdout JSON output
```

Or run as a microservice with FastAPI:

```python
from fastapi import FastAPI
import nodriver as uc

app = FastAPI()

@app.get("/scrape")
async def scrape(url: str):
    browser = await uc.start(headless=True)
    page = await browser.get(url)
    title = await page.evaluate("document.title")
    text = await page.evaluate("document.body.innerText")
    browser.stop()
    return {"title": title, "text": text[:1000]}
```

Then point n8n HTTP Request nodes at `http://localhost:8001/scrape?url=https://example.com`.

---

## Resources

- [nodriver GitHub](https://github.com/ultrafunkamsterdam/nodriver)
- [nodriver PyPI](https://pypi.org/project/nodriver/)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [PinchTab (also installed)](https://github.com/pinchtab/pinchtab)

---

## Support This Content

If this guide saved you time, consider buying me a coffee!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

---

*Written 2026-03-03 — tested on M3 MacBook Pro with nodriver 0.48.1. Installed in seconds, working against davidtkeane.com immediately.*

*Rangers lead the way!* 🎖️
