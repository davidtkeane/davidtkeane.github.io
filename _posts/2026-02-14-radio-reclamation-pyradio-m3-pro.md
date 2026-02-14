---
layout: post
title: "Radio Reclamation: Fixing PyRadio on MacBook Pro M3 (Python 3.13 Upgrade)"
date: 2026-02-14 09:00:00 +0000
categories: [macOS, Python, Music]
tags: [pyradio, pipx, m3pro, troubleshooting]
pinned: true
---

# 🎖️ The Mission: Restoring the Trance Frequency

In the middle of a heavy 9.5-hour deployment for my NCI MSc Cyber-Security project, my command center hit a snag. My favorite terminal-based radio player, **PyRadio**, went dark. Every attempt to launch it resulted in the dreaded `bad interpreter` error.

If you've recently upgraded to **Python 3.13** on a MacBook Pro M3, you've likely hit the same wall. Here is how I reclaimed the frequency.

---

## 🛡️ The Problem: The "Broken Pipe" & The Zombie Package

When macOS or Homebrew updates your system Python (e.g., from 3.12 to 3.13), it severs the links to virtual environments created by `pipx`. 

**The Symptoms:**
- `zsh: /Users/ranger/.local/bin/pyradio: bad interpreter`
- `BrokenPipeError: [Errno 32] Broken pipe` when trying to play streams.
- `ModuleNotFoundError: No module named 'requests'` even after reinstalling.

The root cause was two-fold:
1. **Python Substrate Shift:** The environment was looking for a Python 3.12 binary that no longer existed.
2. **The PyPI Zombie:** The version of `pyradio` on PyPI (0.5.2) is a "zombie" version—outdated and broken.

---

## ⚔️ The Tactical Fix: Strategic Reinstallation

To fix this, we had to bypass the standard `pip install` and go directly to the source.

### 1. Nuke the Old Environment
First, clear the broken links:
```bash
pipx uninstall pyradio
pipx reinstall-all  # Fixes other broken tools like bbot or openai
```

### 2. Install the Authentic 0.9.x Branch
We installed directly from the official GitHub repository to get the modern features and Python 3.13 support:
```bash
pipx install git+https://github.com/s-n-g/pyradio.git
```

### 3. Inject Missing Reinforcements
Modern `pyradio` requires a few extra "soldiers" in its virtual environment to handle logging and network requests:
```bash
pipx inject pyradio requests psutil dnspython netifaces rich python-dateutil
```

---

## ⌨️ Tactical Keybindings: Command & Control

Once we were back on the air, we mapped out the core controls for the M3 Pro keyboard.

### 🔊 Volume Control (Mac Specific)
The fastest way to adjust volume on a Mac isn't the top row—it's the keys under your right hand:
*   **Volume Up:** Press `.` (Period) or `+`
*   **Volume Down:** Press `,` (Comma) or `-`
*   **Mute:** Press `v`

### 💾 Archiving the Beats
I've started saving every song. Here are the keys to build your tactical archive:
*   **Mark as Favorite (Like):** Press `w` (lowercase)
*   **Toggle Title Logging:** Press `W` (Capital) - This writes every song title to a log file.
*   **The Tape Deck (Record):** Press `|` (Shift + ``) - This records the actual audio stream to an `.mkv` file.

### 🔍 Advanced Recon
*   **Next/Prev Station:** `j` / `k` (Vim keys!) or Arrows.
*   **Search Stations:** `/`
*   **Help Overlay:** `?` (Press this while playing to see every secret command).

---

## 📁 Intelligence Retrieval: Where are the files?

PyRadio on macOS stores your tactical data in a specific sector. To see every song you've "Liked" or Logged today, use this command:

```bash
cat ~/pyradio-recordings/pyradio-titles.log
```

**Recordings Location:** All your recorded audio files live in `~/pyradio-recordings/`.

---

## ⚠️ Tactical Warning: Disk Space Alert!

If you are like me and decide to **"Save Every Song"** using the `|` (Record) feature, be warned: high-bitrate trance streams consume disk space rapidly. A 10-hour session can easily eat several gigabytes. Monitor your `~/pyradio-recordings/` folder regularly!

**Status:** PyRadio is 100% operational on Python 3.13. 

*Rangers lead the way!* 🎖️
