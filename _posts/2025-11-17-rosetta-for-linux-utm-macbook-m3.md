---
title: "Running x86 Binaries in Kali Linux on Apple Silicon with Rosetta and UTM"
date: 2025-11-17 00:00:00 +0000
categories: [Security, Tools]
tags: [utm, rosetta, apple-silicon, m3, kali, virtualization, arm64]
pin: false
math: false
mermaid: false
---

## Overview

Apple Silicon Macs (M1/M2/M3) use ARM64 architecture, which means running x86_64 Linux binaries requires translation. This guide covers installing UTM (a free virtualization tool) on your MacBook Pro M3 and enabling Rosetta for Linux to run x86_64 binaries natively within your Kali Linux VM.

This is essential for penetration testing where many tools are only available as x86_64 binaries.

## Prerequisites

- MacBook Pro with Apple Silicon (M1, M2, M3)
- macOS Monterey 12.3 or later (for Rosetta for Linux support)
- At least 8GB RAM allocated for VM
- Kali Linux ARM64 ISO or pre-built UTM image
- Admin access on macOS

## Step 1: Install UTM on macOS

UTM is a free, open-source virtualization tool optimized for Apple Silicon.

### Option A: Download from Website (Free)

```bash
# Visit https://mac.getutm.app/
# Click "Download" to get the latest version
# Open the .dmg and drag UTM to Applications
```

### Option B: Install via Homebrew

```bash
brew install --cask utm
```

### Option C: Mac App Store ($9.99)

Search "UTM" in the Mac App Store. This version auto-updates and supports the developer.

**Verification:**
```bash
# Check UTM is installed
ls /Applications/UTM.app
```

## Step 2: Create Kali Linux VM in UTM

### Download Kali Linux ARM64

```bash
# Get the ARM64 installer ISO from:
# https://www.kali.org/get-kali/#kali-installer-images
# Select "Apple Silicon (ARM64)" version
```

### Create New VM in UTM

1. Open UTM
2. Click **"Create a New Virtual Machine"**
3. Select **"Virtualize"** (not Emulate - faster on Apple Silicon)
4. Choose **"Linux"**
5. Browse to your Kali ARM64 ISO
6. Configure hardware:
   - **RAM:** 8GB minimum (8192 MB)
   - **CPU Cores:** 4-6 cores
   - **Storage:** 64GB+ recommended
7. Complete the wizard and install Kali

## Step 3: Enable Rosetta in UTM Settings

**Important:** Shut down the VM completely first.

1. In UTM, right-click your Kali VM → **"Edit"**
2. Navigate to **"Virtualization"** section
3. Check **"Enable Rosetta"** (or "Rosetta x86_64 Emulation")
4. Save and close settings

> **Note:** If you don't see this option, ensure you're using UTM 4.0+ and macOS 13 Ventura or later.

## Step 4: Mount Rosetta Share in Kali

Boot into your Kali VM and run:

### Create Mount Point

```bash
sudo mkdir -p /media/rosetta
```

### Mount the Rosetta VirtioFS Share

```bash
sudo mount -t virtiofs rosetta /media/rosetta
```

**Expected output:** No errors means success.

**Verify mount:**
```bash
ls -la /media/rosetta
```

You should see:
```
total 0
drwxr-xr-x 2 root root 0 Nov 17 14:00 .
drwxr-xr-x 3 root root 4096 Nov 17 14:00 ..
-r-xr-xr-x 1 root root 0 Nov 17 14:00 rosetta
```

## Step 5: Register Rosetta with binfmt_misc

This tells Linux to use Rosetta for x86_64 binaries automatically.

```bash
sudo /usr/sbin/update-binfmts --install rosetta /media/rosetta/rosetta \
    --magic "\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00" \
    --mask "\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff" \
    --credentials yes --preserve no --fix-binary yes
```

**Verify registration:**
```bash
cat /proc/sys/fs/binfmt_misc/rosetta
```

**Expected output:**
```
enabled
interpreter /media/rosetta/rosetta
flags: FCO
offset 0
magic 7f454c4602010100000000000000000002003e00
mask ffffffff00000000000000000000000000000000
```

## Step 6: Make Changes Persistent

### Add to /etc/fstab

```bash
echo "rosetta  /media/rosetta  virtiofs  ro,nofail  0  0" | sudo tee -a /etc/fstab
```

### Verify fstab Entry

```bash
tail -1 /etc/fstab
```

Should show:
```
rosetta  /media/rosetta  virtiofs  ro,nofail  0  0
```

The `nofail` option prevents boot issues if UTM's Rosetta share isn't available.

## Step 7: Test x86_64 Binary Execution

### Quick Test

```bash
# Download a known x86_64 binary
wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
tar xzf bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
cd bat-v0.24.0-x86_64-unknown-linux-gnu

# Check architecture
file bat
# Should show: ELF 64-bit LSB pie executable, x86-64

# Run it (should work via Rosetta)
./bat --version
```

**Success indicators:**
- Binary runs without "exec format error"
- Output displays normally
- No architecture-related errors

### Check What's Running

```bash
# Verify it's using Rosetta
ps aux | grep rosetta
```

## Troubleshooting

### Common Issue 1: Mount Point Doesn't Exist

**Problem:** `mount: /media/rosetta: mount point does not exist`

**Solution:**
```bash
sudo mkdir -p /media/rosetta
```

### Common Issue 2: VirtioFS Not Available

**Problem:** `mount: unknown filesystem type 'virtiofs'`

**Solution:**
- Ensure "Enable Rosetta" is checked in UTM VM settings
- Reboot the VM after enabling
- Check UTM version is 4.0+

### Common Issue 3: binfmt Registration Fails

**Problem:** `update-binfmts: unable to open /usr/sbin/update-binfmts`

**Solution:**
```bash
sudo apt update && sudo apt install binfmt-support
```

### Common Issue 4: Permission Denied

**Problem:** Rosetta binary cannot execute

**Solution:**
```bash
# Remount with execute permissions
sudo mount -o remount,exec /media/rosetta
```

### Common Issue 5: Rosetta Option Not Visible in UTM

**Problem:** Can't find Rosetta setting in UTM

**Solution:**
- Update UTM to latest version (4.0+)
- Requires macOS Ventura 13+ or later
- Only available on Apple Silicon Macs

## Key Takeaways

1. UTM with Rosetta for Linux enables near-native x86_64 performance on Apple Silicon
2. One-time setup makes all x86_64 binaries "just work"
3. Essential for security tools that lack ARM64 builds
4. Significantly faster than full emulation (QEMU TCG)
5. Transparent translation - no need to manually invoke Rosetta

## Quick Reference

```bash
# Install UTM (Homebrew)
brew install --cask utm

# Mount Rosetta (run in Kali VM)
sudo mkdir -p /media/rosetta
sudo mount -t virtiofs rosetta /media/rosetta

# Register binfmt handler
sudo /usr/sbin/update-binfmts --install rosetta /media/rosetta/rosetta \
    --magic "\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00" \
    --mask "\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff" \
    --credentials yes --preserve no --fix-binary yes

# Make persistent
echo "rosetta  /media/rosetta  virtiofs  ro,nofail  0  0" | sudo tee -a /etc/fstab

# Verify setup
cat /proc/sys/fs/binfmt_misc/rosetta
ls -la /media/rosetta
```

## Resources

- [UTM Official Website](https://mac.getutm.app/)
- [UTM GitHub Repository](https://github.com/utmapp/UTM)
- [Kali Linux ARM64 Downloads](https://www.kali.org/get-kali/#kali-installer-images)
- [Apple Developer - Rosetta for Linux](https://developer.apple.com/documentation/virtualization/running_intel_binaries_in_linux_vms_with_rosetta)
- [UTM Documentation](https://docs.getutm.app/)

---

*Environment: Kali Linux ARM64 VM on MacBook Pro M3 (18GB) via UTM*
