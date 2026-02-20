---
layout: post
title: "Resizing a Kali Linux VM Disk in UTM on macOS - The Complete Adventure"
date: 2026-02-07 04:00:00 +0000
categories: [virtualization, linux, macos]
tags: [utm, kali, qemu, qcow2, partition, resize, swap, macos, apple-silicon]
---

# Resizing a Kali Linux VM Disk in UTM on macOS

Today I needed to expand my Kali Purple VM from 64GB to 100GB to make room for running large AI models (specifically a 19GB Ollama model). What should have been straightforward turned into a learning adventure involving quarantine flags, partition tables, and swap files. Here's the complete story.

## The Setup

- **Host:** M3 Pro MacBook Pro (macOS)
- **VM Software:** UTM (QEMU-based)
- **Guest OS:** Kali Purple (ARM64)
- **Original Disk:** 64GB QCOW2
- **Target Disk:** 100GB

## Problem 1: The 32GB VM Wouldn't Start

Before I even got to resizing, my 32GB RAM VM refused to boot with this error:

```
QEMU error: QEMU exited from an error: qemu-aarch64-softmmu:
-device virtio-9p-pci,fsdev=virtfs0,mount_tag=share:
cannot initialize fsdev 'virtfs0':
failed to open '/Users/ranger/scripts/Rangers_Stuff/share':
Operation not permitted
```

### The Diagnosis

This looked like a memory issue, but it wasn't! The error was about the **shared folder**, not RAM.

I checked the folder's extended attributes:

```bash
xattr -l /Users/ranger/scripts/Rangers_Stuff/share
```

Output:
```
com.apple.quarantine: 0082;00000000;QEMUHelper;
```

**The culprit:** macOS had quarantined the shared folder - ironically, by QEMU itself!

### The Fix

```bash
xattr -dr com.apple.quarantine /Users/ranger/scripts/Rangers_Stuff/share
```

After removing the quarantine flag, the 32GB VM booted perfectly. Lesson learned: when UTM/QEMU fails, check for quarantine flags on shared folders!

## Problem 2: Resizing the QCOW2 Disk

With the VM shut down, resizing the virtual disk itself was easy:

```bash
# Check current size
qemu-img info "/path/to/disk.qcow2"
# Output: virtual size: 64 GiB

# Resize to 100GB
qemu-img resize "/path/to/disk.qcow2" 100G

# Verify
qemu-img info "/path/to/disk.qcow2"
# Output: virtual size: 100 GiB
```

**Pro tip:** Always backup your QCOW2 file before resizing:

```bash
cp disk.qcow2 BACKUP-disk.qcow2
```

The 64GB copy took a few minutes but saved me from potential disaster.

## Problem 3: The Partition Layout Challenge

After booting the VM, I checked the layout:

```bash
lsblk
```

```
NAME   SIZE  TYPE MOUNTPOINTS
vda    100G  disk
├─vda1 512M  part /boot/efi
├─vda2 62.5G part /
└─vda3 976M  part [SWAP]
```

The problem: **36GB of free space was at the END of the disk**, but the swap partition (vda3) was blocking expansion of the root partition (vda2).

```
[ EFI 512M ][ ROOT 62.5G ][ SWAP 976M ][ ~~~FREE 36GB~~~ ]
```

## The Solution: Delete Swap, Expand Root, Create Swapfile

### Step 1: Turn Off and Delete Swap Partition

```bash
sudo swapoff /dev/vda3
sudo parted /dev/vda rm 3
```

When parted asked about fixing the GPT to use all space, I selected **Fix**.

### Step 2: Expand the Root Partition

I tried `growpart` but it wasn't installed, and the VM had no network. No problem - parted works directly:

```bash
sudo parted /dev/vda resizepart 2 100%
```

When warned the partition is in use, select **Yes** - online resizing is supported.

### Step 3: Resize the Filesystem

```bash
sudo resize2fs /dev/vda2
```

Output:
```
resize2fs 1.47.2 (1-Jan-2025)
Filesystem at /dev/vda2 is mounted on /; on-line resizing required
old_desc_blocks = 8, new_desc_blocks = 13
The filesystem on /dev/vda2 is now 26083067 (4k) blocks long.
```

### Step 4: Create a Swapfile Instead

With 32GB RAM, I decided 8GB swap was plenty (emergency overflow, not regular use):

```bash
# Create 8GB swapfile
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make it permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Step 5: Clean Up /etc/fstab

Edit `/etc/fstab` to remove the old swap partition entry (the line referencing `/dev/vda3` or its UUID).

## The Result

```bash
df -h /
```

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda2        98G   53G   41G  57% /
```

```bash
free -h
```

```
               total   used   free   shared  buff/cache  available
Mem:            31Gi   1.9Gi  27Gi   30Mi    2.1Gi       29Gi
Swap:          8.0Gi   0B     8.0Gi
```

**Success!**

| Before | After |
|--------|-------|
| 64GB disk | 98GB usable |
| 62.5GB root | 98GB root |
| 976MB swap partition | 8GB swapfile |
| Blocked by swap | 41GB free! |

## Swap Sizing Guide

While figuring this out, I learned some swap sizing wisdom:

| Swap Size | Verdict |
|-----------|---------|
| 1GB | Too small - OOM killer strikes fast |
| 4GB | Minimum reasonable for 16GB+ RAM |
| 8GB | Sweet spot for VMs |
| 10GB | Generous but fine |
| 20GB | Overkill, wastes disk |

**Key insight:** If your AI model is swapping regularly, the answer isn't more swap - it's more RAM or a smaller model. Swap is a parachute, not a jetpack!

## Why I Needed 100GB

I'm running RangerBot, a consciousness-enhanced AI model for my Master's thesis. The 32B version needs ~19GB just for the model weights, plus working memory. With 98GB disk and 32GB RAM + 8GB swap, I now have plenty of headroom.

```bash
ollama pull davidkeane1974/rangerbot-32b:v4
ollama run davidkeane1974/rangerbot-32b:v4
```

The model loads and inference is fast - even inside a VM!

## Key Takeaways

1. **Quarantine flags can block VMs** - Check `xattr` on shared folders if UTM fails
2. **Always backup before resizing** - A 64GB copy is worth the wait
3. **Swap partitions block expansion** - Delete and use swapfiles instead
4. **parted works without network** - No need to install growpart
5. **Online resize works** - No need to boot from live USB
6. **Swapfiles are more flexible** - Easy to resize later without repartitioning

## Commands Summary

```bash
# Remove quarantine (on macOS host)
xattr -dr com.apple.quarantine /path/to/share

# Resize QCOW2 (VM must be off)
qemu-img resize disk.qcow2 100G

# Inside VM - expand partition
sudo swapoff /dev/vda3
sudo parted /dev/vda rm 3
sudo parted /dev/vda resizepart 2 100%
sudo resize2fs /dev/vda2

# Create swapfile
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Hope this helps someone else wrestling with UTM VM disk expansion!

---

*Written while running a 32 billion parameter AI model inside a Kali VM on an M3 Pro. The future is weird and wonderful.*

**Rangers lead the way!** 🎖️
