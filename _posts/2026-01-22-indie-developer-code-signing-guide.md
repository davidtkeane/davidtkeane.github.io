---
title: "Do Indie Developers Really Need Code Signing? My €400 Wake-Up Call"
date: 2026-01-22 17:00:00 +0000
categories: [Development, Security]
tags: [electron, code-signing, indie-developer, virustotal, windows, macos, false-positive, open-source, cybersecurity]
pin: false
math: false
mermaid: false
---

## Overview

A real-world case study with RangerChat Lite - I uploaded my Electron app to VirusTotal, got flagged by 1 out of 65 antivirus vendors, and learned that €400/year code signing certificates might not be worth it for indie developers.

---

## The Moment of Panic 😰

Picture this: You've just finished building your first Electron desktop app. Months of work. Beautiful UI. Works perfectly. You upload it to GitHub, create a release, and then... you decide to check it on VirusTotal.

**1 out of 65 vendors detected your app as malicious.**

My heart sank. Was my app infected? Did I accidentally include malware? Had my development machine been compromised?

Spoiler alert: None of the above. Welcome to the world of **false positives for unsigned applications**.

---

## The Victim: RangerChat Lite

Let me introduce you to my "flagged" application:

| Property | Value |
|----------|-------|
| **App Name** | RangerChat Lite |
| **File** | `RangerChat Lite-1.9.2-win-x64.exe` |
| **Size** | 91.73 MB |
| **Framework** | Electron (React + TypeScript) |
| **Purpose** | Blockchain chat client |
| **Detection Rate** | **1/65** (1.5%) |

The single vendor that flagged it? **"peeex"** with an "overlay" tag.

Not Norton. Not Kaspersky. Not Windows Defender. Not Malwarebytes.

A vendor I'd never heard of, flagging something about "overlays" - which makes sense because Electron apps with frameless windows literally use overlay rendering.

---

## What VirusTotal Actually Said

Here's the breakdown from my analysis:

### ✅ The Good News (64 of 65 vendors)

- **Windows Defender**: Clean ✓
- **Kaspersky**: Clean ✓
- **Norton**: Clean ✓
- **Malwarebytes**: Clean ✓
- **Avast/AVG**: Clean ✓
- **ESET**: Clean ✓
- **Bitdefender**: Clean ✓
- **Trend Micro**: Clean ✓
- ... and 56 more all clean

### ⚠️ The "Bad" News (1 of 65 vendors)

- **peeex**: Flagged with "overlay" tag

### 🔍 Behavior Tags Detected

- `disk` - File operations
- `network` - Network connectivity
- `crypto` - Cryptographic operations

Wait... a **blockchain chat client** has disk, network, and crypto operations? *Shocking.*

---

## Why This Happens: The Unsigned App Problem

My app wasn't signed. Here's what that means:

### What Code Signing Does

1. **Identity Verification**: Proves YOU made the app
2. **Integrity Check**: Proves it hasn't been tampered with
3. **Trust Signal**: Tells Windows/macOS "this developer is verified"

### What Happens Without It

1. **Windows SmartScreen**: "Unknown Publisher" warning
2. **macOS Gatekeeper**: Blocks app until user right-clicks → Open
3. **Some AV Tools**: Flag it as "suspicious" (not malicious, just unverified)

The "peeex" detection wasn't saying my app was malware. It was saying "this app does overlay stuff and we can't verify who made it."

---

## The Price of Trust: Code Signing Costs

So naturally, I researched how to fix this. Here's what I found:

### Apple Developer ID (macOS only)

| Item | Details |
|------|---------|
| **Cost** | $99/year |
| **Signs** | `.dmg`, `.app`, `.pkg` |
| **Benefit** | Removes Gatekeeper warnings, notarization |

### Windows EV Code Signing (Windows only)

| Item | Details |
|------|---------|
| **Cost** | $300-500/year |
| **Signs** | `.exe`, `.msi`, `.dll` |
| **Benefit** | Instant SmartScreen reputation, reduces false positives |

### Total for Both Platforms

**~€400/year** just to remove warning dialogs.

For context, that's:
- 4 months of a streaming service
- A nice weekend trip
- A lot of coffee ☕

---

## The Reality Check: Do I Actually Need This?

Let me be honest about my situation:

| Factor | My Reality |
|--------|-----------|
| **User Base** | Small, technical, early adopters |
| **App Type** | Open source, community project |
| **Revenue** | $0 (hobby project) |
| **False Positive Rate** | 1.5% (1/65) |
| **Major AV Detection** | 0% |

### What My Users Actually Experience

**On Windows (without signing):**

1. Download `.exe` from GitHub
2. SmartScreen shows "Unknown Publisher"
3. Click "More Info" → "Run Anyway"
4. Never see warning again

**On macOS (without signing):**

1. Download `.dmg` from GitHub
2. Gatekeeper blocks it
3. Right-click → Open → Confirm
4. Never see warning again

That's it. A one-time click.

---

## Who SHOULD Pay for Code Signing?

Code signing makes sense if:

| Scenario | Worth It? |
|----------|-----------|
| Selling commercial software | ✅ Yes |
| Enterprise distribution | ✅ Yes |
| Non-technical user base | ✅ Yes |
| Thousands of downloads/day | ✅ Yes |
| Hobby project for tech folks | ❌ Probably not |
| Open source with GitHub releases | ❌ Probably not |
| You're spending more on certs than earning | ❌ Definitely not |

---

## What I Did Instead (Free Solutions)

### 1. Documented the False Positive

In my README, I added:

```markdown
## 🐞 Known Issues

4. **Antivirus False Positive**: Some antivirus software (1/65 on VirusTotal) 
   may flag the app due to Electron's frameless overlay. This is a false 
   positive - [View VirusTotal Report](https://virustotal.com/...)
```

### 2. Provided the VirusTotal Link

Transparency builds trust. Anyone can click the link and see that 64/65 major vendors say it's clean.

### 3. Open Sourced Everything

The entire codebase is on GitHub. Anyone can:
- Review the code
- Build it themselves
- Verify I'm not hiding anything

### 4. Wrote This Blog Post

If you're reading this and questioning your own unsigned app, now you know you're not alone.

---

## The Commands That Scared No One

Part of my initial concern was that RangerChat Lite has "slash commands" in the chat:

```bash
/call @username  → Start a voice call
/hangup          → End the call
/peers           → List online users
```

I worried: "Does having commands make it look like malware?"

**No.** These are application-level commands that:
- Run inside the app's sandbox
- Don't execute system shell commands
- Are standard in chat apps (Discord, Slack, IRC all have them)

VirusTotal's behavior analysis correctly identified them as internal app functions, not arbitrary code execution.

---

## Lessons Learned

### 1. Don't Panic at Low Detection Rates

1/65 = 1.5% detection rate. That's noise, not signal.

### 2. Check WHICH Vendor Flagged You

If Windows Defender, Kaspersky, and Norton say you're clean, you're probably clean.

### 3. Electron Apps Get Flagged More Often

Electron packages an entire Chromium browser. It's a complex binary that heuristic scanners sometimes misinterpret.

### 4. €400/Year is a Business Decision

For commercial software with paying customers? Worth it.
For a passion project with <100 users? Save your money.

### 5. Transparency is Free

Document everything. Link to your VirusTotal report. Show your source code.

---

## The Verdict

**Am I going to spend €400/year on code signing?**

No. Not for RangerChat Lite.

**Would I reconsider if:**
- The app gained thousands of users? Maybe.
- I started charging money? Definitely.
- Multiple major AV vendors flagged it? Absolutely.

For now, my 98.5% clean bill of health from VirusTotal is good enough.

---

## Resources

- [My VirusTotal Report](https://www.virustotal.com/gui/file/aff8c67fc85e610f0a629853ab8b2d3cae56a300c1d0e581a77002c432fd8352/details)
- [RangerChat Lite on GitHub](https://github.com/davidtkeane/rangerplex-ai/tree/main/apps/ranger-chat-lite)
- [Electron Code Signing Docs](https://www.electronjs.org/docs/latest/tutorial/code-signing)
- [Understanding Windows SmartScreen](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-smartscreen/microsoft-defender-smartscreen-overview)

---

## About the Author

I'm David Keane, an indie developer building blockchain and AI tools. RangerChat Lite is part of the RangerPlex project - a suite of tools for decentralized communication.

If you found this helpful, consider starring the repo on GitHub. It's free, unlike code signing. 😄

---

*Have you dealt with false positives on your indie app? Share your story in the comments!*
