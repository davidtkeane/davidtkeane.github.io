---
title: "CTF Steganography: c4ptur3-th3-fl4g Walkthrough"
date: 2025-12-31 12:00:00 +0000
categories: [CTF, Digital Forensics]
tags: [ctf, steganography, steghide, zsteg, binwalk, kali, docker, tryhackme]
pin: false
math: false
mermaid: false
---

## Overview

This post documents my journey through the **c4ptur3-th3-fl4g** CTF steganography challenges. I'll share the problems I hit, the mistakes I made, and how I solved each task. If you're learning digital forensics or CTF techniques, you'll probably hit these same walls!

## The Setup

I was working on my MacBook Pro (M4 Max) and needed Linux tools for steganography analysis. Here's my setup journey...

---

## Mistake #1: Trying to Install steghide on macOS

**What I tried:**
```bash
brew install steghide
```

**Error:**
```
Warning: No available formula with the name "steghide".
Error: No formulae or casks found for steghide.
```

**Why it failed:** steghide isn't available on Homebrew for macOS - it's primarily a Linux tool!

**The fix:** Use Kali Linux in Docker instead:
```bash
docker start Kali
docker exec -it -u root Kali bash
apt update && apt install steghide -y
```

**Lesson:** Not all security tools are available natively on macOS. Keep a Kali Docker container ready!

---

## Mistake #2: Permission Denied in Docker

**What I typed:**
```bash
apt update && apt install steghide -y
```

**Error:**
```
Error: List directory /var/lib/apt/lists/partial is missing. - Acquire (13: Permission denied)
```

**Why:** The Kasm Kali container uses a non-root user by default.

**What I tried next (with typo!):**
```bash
sudo!!
```

**Error:**
```
bash: sudoapt: command not found
```

**The fix:** Exit and re-enter as root:
```bash
exit
docker exec -it -u root Kali bash
```

**Lesson:** When using Docker containers, know whether you need root. Use `-u root` flag to enter as root.

---

## Mistake #3: Using steghide on PNG Files

**What I tried:**
```bash
steghide --extract -sf asset-preview.png
```

**What happened:** It asked for a passphrase but would never work properly.

**Why it failed:** steghide only supports **JPEG** and **BMP** files, NOT PNG!

**The fix:** Use **zsteg** for PNG files:
```bash
apt install ruby -y
gem install zsteg
zsteg asset-preview.png
```

**Output:**
```
b1,rgba,lsb,xy      .. text: "S337w3333"
```

**Lesson:** Different file formats need different tools!

| File Type | Tool |
|-----------|------|
| JPG/BMP | steghide |
| PNG | zsteg |
| Any | binwalk, strings |

---

## Mistake #4: binwalk Extraction Permissions

**What I tried:**
```bash
binwalk -e meme_1559010886025.jpg
```

**Error:**
```
Extractor Exception: Binwalk extraction uses many third party utilities,
which may not be secure. If you wish to have extraction utilities executed
as the current user, use '--run-as=root'
```

**The fix:**
```bash
binwalk -e --run-as=root meme_1559010886025.jpg
```

**Lesson:** binwalk requires explicit permission to run extractors as root for security reasons.

---

## Mistake #5: Missing unrar Tool

**What happened:**
```bash
binwalk -e --run-as=root meme_1559010886025.jpg

WARNING: Extractor.execute failed to run external extractor 'unrar e '%e'':
[Errno 2] No such file or directory: 'unrar'
```

**Why:** binwalk found a RAR archive inside the image but couldn't extract it.

**The fix:**
```bash
# Install unrar
apt install unrar -y

# Manual extraction works better
dd if=meme_1559010886025.jpg of=hidden.rar bs=1 skip=74407
unrar e hidden.rar
```

**Output:**
```
Extracting  hackerchat.png                                            OK
All OK
```

**Lesson:** binwalk identifies embedded files but needs external tools to extract them. Install common extractors: `unrar`, `p7zip`, `unzip`.

---

## The Correct Workflow

Here's what finally worked for each task:

### Task 1: JPG with Empty Passphrase

```bash
steghide --extract -sf filename.jpg
# Just press Enter (empty password)
```

**Answer:** `SpaghettiSteg`

### Task 2: PNG Steganography

```bash
zsteg asset-preview.png
```

**Answer:** `S337w3333` (leetspeak for "SeetWeeed")

### Task 3: Embedded RAR in JPG

```bash
# First, scan to see what's inside
binwalk meme_1559010886025.jpg

# Output shows:
# 74407    RAR archive data, version 5.x
# 74478    PNG image, 147 x 37

# Extract the RAR
dd if=meme_1559010886025.jpg of=hidden.rar bs=1 skip=74407
unrar e hidden.rar

# Got: hackerchat.png
```

### Task 4: Hidden Text in PNG

```bash
# Check metadata
exiftool hackerchat.png

# Check for strings
strings hackerchat.png

# Check PNG chunks
zsteg hackerchat.png
```

---

## Docker Workflow Tips

### Quick Aliases for Kali Docker

Add these to `~/.zshrc`:
```bash
# Kali Docker aliases
alias kali-start='docker start Kali && docker exec -it -u root Kali bash'
alias kali='docker exec -it -u root Kali bash'
alias kali-stop='docker stop Kali'
```

### Copying Files to/from Container

```bash
# Copy file INTO container
docker cp ~/Downloads/image.jpg Kali:/tmp/

# Copy file OUT of container
docker cp Kali:/tmp/extracted.png ~/Downloads/
```

---

## Stego Tool Cheatsheet

| Tool | Install | Use Case | Example |
|------|---------|----------|---------|
| **steghide** | `apt install steghide` | JPG/BMP with password | `steghide --extract -sf file.jpg` |
| **zsteg** | `gem install zsteg` | PNG LSB steganography | `zsteg file.png` |
| **binwalk** | `apt install binwalk` | Find embedded files | `binwalk -e --run-as=root file.jpg` |
| **exiftool** | `apt install exiftool` | Metadata analysis | `exiftool file.jpg` |
| **strings** | Pre-installed | Find readable text | `strings file.jpg \| grep flag` |
| **xxd** | Pre-installed | Hex dump | `xxd file.jpg \| head -50` |
| **stegseek** | `apt install stegseek` | Crack steghide passwords | `stegseek file.jpg wordlist.txt` |

---

## Common CTF Stego Techniques

### 1. Empty Passphrase First
Always try an empty password with steghide - many CTF creators use no password:
```bash
steghide --extract -sf file.jpg
# Just hit Enter
```

### 2. Check Metadata
Hidden flags often live in EXIF data:
```bash
exiftool file.jpg | grep -i "comment\|flag\|secret"
```

### 3. Scan for Embedded Files
Images can contain hidden archives:
```bash
binwalk file.jpg
# Look for: RAR, ZIP, PNG, PDF entries
```

### 4. LSB Analysis
Least Significant Bit hiding is common in PNGs:
```bash
zsteg file.png -a  # Try all methods
```

### 5. Visual Analysis
Some flags are hidden in color planes:
```bash
# Use stegsolve (GUI) or
convert file.png -channel R -separate red.png
convert file.png -channel G -separate green.png
convert file.png -channel B -separate blue.png
```

---

## Summary

| Task | Method | Tool | Answer |
|------|--------|------|--------|
| 1 | Empty passphrase | steghide | `SpaghettiSteg` |
| 2 | LSB extraction | zsteg | `S337w3333` |
| 3 | File carving | binwalk + unrar | `hackerchat.png` |
| 4 | Metadata/strings | exiftool/strings | (in file) |

---

## Key Takeaways

1. **steghide is for JPG/BMP only** - Use zsteg for PNG
2. **Try empty passwords first** - CTF creators often skip passwords
3. **Docker is your friend** - Keep Kali ready for Linux tools
4. **binwalk needs extractors** - Install unrar, p7zip, etc.
5. **Run as root in Docker** - Use `-u root` or `--run-as=root`
6. **Manual extraction works** - Use `dd` when binwalk fails
7. **Check everything** - Metadata, strings, embedded files, LSB

---

## Resources

- [steghide Documentation](https://steghide.sourceforge.io/)
- [zsteg GitHub](https://github.com/zed-0xff/zsteg)
- [binwalk GitHub](https://github.com/ReFirmLabs/binwalk)
- [TryHackMe - c4ptur3-th3-fl4g](https://tryhackme.com/room/c4ptur3th3fl4g)
- [Kali Linux Docker](https://www.kali.org/docs/containers/official-kali-docker-images/)

---

*Making mistakes is the best teacher. Now I know the right tool for each file format, and so do you!*

**Remember:** Steganography is about patience and methodology. Try every tool, check every layer, and always start simple (empty passwords, metadata) before going complex.

