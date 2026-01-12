---
title: "macOS Time Machine: Fix 'Not Available' and 'Out of Space' Errors"
date: 2026-01-12 09:00:00 +0000
categories: [macOS, Troubleshooting]
tags: [macos, time-machine, backup, m3-pro, apple, troubleshooting, apfs, full-disk-access, tmutil]
pin: false
math: false
mermaid: false
---

## Overview

Two frustrating Time Machine errors and how to fix them:

1. **"Try backing up again when 'Time Machine' is available"** - even when your backup drive is plugged in
2. **"Time Machine is out of space"** - on a drive you just formatted

This post covers diagnosing both issues, the quick GUI fix, setting quotas via terminal, and the Full Disk Access gotcha that catches everyone.

---

## The Problem

I opened the Time Machine app on my M3 Pro Mac and immediately got a desktop notification:

> "Try backing up again when 'Time Machine' is available"

**The confusing part:** My 4TB external drive was connected, mounted, and visible in Finder. The Time Machine volume existed. So why wasn't it working?

---

## What I Checked First

### 1. Is the drive actually connected?

```bash
diskutil list external
```

**Result:** Drive was there - a 4TB external with an APFS "Time Machine" volume.

### 2. Is Time Machine configured?

```bash
tmutil destinationinfo
```

**Result:** Showed a destination was configured:
```
Name          : Time Machine
Kind          : Local
ID            : 4B5ED0B0-4B3E-4A2F-976E-B302A27937A3
```

### 3. Is the volume mounted?

```bash
mount | grep "Time Machine"
```

**Result:** Yes, mounted at `/Volumes/Time Machine`

### 4. What's Time Machine's status?

```bash
tmutil status
```

**Result:**
```
Backup session status:
{
    ClientID = "com.apple.backupd";
    Percent = "-1";
    Running = 0;
}
```

So the drive was connected, mounted, and configured... but Time Machine wasn't recognizing it properly.

---

## The Root Cause

The Time Machine destination ID in the system configuration didn't match the actual volume. This can happen when:

- The drive was reformatted
- The volume was recreated
- macOS updated and lost the connection
- The drive was used on a different Mac

The volume was essentially "orphaned" - it existed, but Time Machine's internal database didn't recognize it as a valid destination.

---

## My First Attempt (Failed)

I tried to remove and re-add the destination via terminal:

```bash
sudo tmutil removedestination 4B5ED0B0-4B3E-4A2F-976E-B302A27937A3
```

**Error:**
```
tmutil: removedestination requires Full Disk Access privileges.
To allow this operation, select Full Disk Access in the Privacy
tab of the Security & Privacy preference pane, and add Terminal
to the list of applications which are allowed Full Disk Access.
```

I could have granted Terminal Full Disk Access, but there was an easier way...

---

## The Fix (2 Minutes)

**Via System Settings (no terminal needed):**

1. Open **System Settings**
2. Go to **Time Machine** (under General)
3. Click the **minus (-)** button to remove the current destination
4. Click the **plus (+)** button to add your Time Machine volume back
5. Click **Back Up Now**

That's it! The backup started immediately.

---

## What I Should Have Done

Instead of diving into terminal diagnostics, I should have:

1. **Started with System Settings** - The GUI handles permissions automatically
2. **Removed and re-added the destination** - This re-establishes the connection

**Lesson:** Sometimes the GUI is faster than the CLI, especially when macOS permissions are involved.

---

## Useful Time Machine Commands

For future reference, here are helpful diagnostic commands:

| Task | Command |
|------|---------|
| Check destination | `tmutil destinationinfo` |
| Check backup status | `tmutil status` |
| List backups | `tmutil listbackups` |
| Start backup (CLI) | `tmutil startbackup` |
| Stop backup | `tmutil stopbackup` |
| Check external drives | `diskutil list external` |
| Check mount status | `mount \| grep "Time Machine"` |

---

## Prevention Tips

To avoid this issue in the future:

1. **Don't rename Time Machine volumes** - Keep the original name
2. **Safely eject before unplugging** - Prevents corruption
3. **Use the same Mac** - Switching Macs can cause destination issues
4. **Check after macOS updates** - Major updates can reset configurations

---

## Quick Diagnostic Flowchart

```
Time Machine not backing up?
           │
           ▼
┌──────────────────────────┐
│ Is the drive connected?  │
│ (Check Finder/diskutil)  │
└────────────┬─────────────┘
             │
        ┌────┴────┐
        │         │
       YES        NO
        │         │
        ▼         ▼
┌──────────┐  ┌───────────────┐
│ Go to    │  │ Connect drive │
│ System   │  │ and try again │
│ Settings │  └───────────────┘
└────┬─────┘
     │
     ▼
┌────────────────────────────┐
│ Remove destination (-)     │
│ Re-add destination (+)     │
│ Click "Back Up Now"        │
└────────────────────────────┘
```

---

## Key Takeaways

1. **"Not available" usually means broken link** - The destination ID doesn't match the volume
2. **GUI fix is faster** - System Settings handles permissions automatically
3. **Remove and re-add** - This is the universal Time Machine fix
4. **Terminal needs Full Disk Access** - Extra steps if you want CLI control

---

## Part 2: "Time Machine Is Out of Space" Error

After fixing the initial issue and running my first backup, I got ANOTHER error:

> "Time Machine is out of space"

Wait, what? I just formatted the drive! Let me investigate...

---

## Diagnosing the Space Issue

### Check APFS Container Details

```bash
diskutil apfs list disk7
```

**Result:**
```
+-- Container disk7
    Size (Capacity Ceiling):      4.1 TB
    Capacity In Use By Volumes:   4.1 TB (100.0% used)
    Capacity Not Allocated:       101 MB (0.0% free)

    +-> Volume disk7s1 - Fanx4TB
        Capacity Consumed:         2.2 TB

    +-> Volume disk7s2 - Time Machine
        Capacity Consumed:         1.9 TB
```

**The problem:** Both volumes share the same 4.1TB APFS container with NO size limits!

| Volume | Used |
|--------|------|
| Fanx4TB | 2.2 TB |
| Time Machine | 1.9 TB |
| **Total** | **4.1 TB (100% FULL!)** |

---

## Where Are Time Machine Backups Stored?

Time Machine stores backups in TWO locations:

### 1. External Drive (Primary)
- Path: `/Volumes/Time Machine 1/`
- Contains: Full backup history
- My usage: 1.9 TB

### 2. Local Snapshots (Internal SSD)
- Temporary snapshots on your Mac's internal drive
- Auto-deleted when space is needed (purgeable)
- Check with: `tmutil listlocalsnapshots /`

```bash
# List local snapshots
tmutil listlocalsnapshots /
```

Output showed 18+ snapshots from the past 24 hours - these are normal and auto-managed.

---

## The Fix: Set a Time Machine Quota

To prevent Time Machine from consuming unlimited space, set a quota:

```bash
# Get your destination ID
tmutil destinationinfo

# Set quota to 1500GB (1.5TB)
sudo tmutil setquota YOUR-DESTINATION-ID 1500
```

In my case:
```bash
sudo tmutil setquota B62B3495-6C9E-49F5-B353-314643115DA8 1500
```

---

## Full Disk Access Required!

If you get this error:

```
tmutil: setquota requires Full Disk Access privileges.
```

You need to grant Terminal (or your terminal app) Full Disk Access:

1. Open **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Click the **lock icon** (enter password)
3. Click **+** button
4. Press **Cmd + Shift + G** and type: `/Applications/Utilities/`
5. Select **Terminal.app** and click Open
6. **IMPORTANT: Quit Terminal completely (Cmd + Q)**
7. **Reopen Terminal** - the permission won't work until you restart!
8. Run your command again

**Note:** The permission change requires a full Terminal restart to take effect. Just closing the window isn't enough - you must Quit the app entirely.

---

## Updated Commands Reference

| Task | Command |
|------|---------|
| Check destination | `tmutil destinationinfo` |
| Check backup status | `tmutil status` |
| List backups | `tmutil listbackups` |
| **Set size quota** | `sudo tmutil setquota DEST_ID SIZE_GB` |
| List local snapshots | `tmutil listlocalsnapshots /` |
| Delete local snapshots | `tmutil deletelocalsnapshots /` |
| Check APFS container | `diskutil apfs list diskX` |
| Start backup (CLI) | `tmutil startbackup` |
| Stop backup | `tmutil stopbackup` |

---

## APFS Volume Space Sharing Explained

When you create multiple APFS volumes in the same container, they share space dynamically by default. This is usually great - but for Time Machine it can be problematic.

**Without quota:**
- Time Machine grows until the entire container is full
- Other volumes (like Fanx4TB) compete for the same space
- Result: "Out of space" errors

**With quota:**
- Time Machine is limited to a specific size (e.g., 1.5TB)
- Automatically deletes old backups to stay under the limit
- Leaves room for other volumes

---

## Key Takeaways

1. **"Not available" usually means broken link** - Remove and re-add in System Settings
2. **"Out of space" on a new drive** - Check if APFS volumes are sharing space
3. **Set a quota** - Use `tmutil setquota` to limit Time Machine size
4. **Terminal needs Full Disk Access** - Grant it in Privacy & Security settings
5. **RESTART TERMINAL** - Permission changes require a full app restart to take effect

---

## The Happy Ending

- **Initial fix:** 2 minutes (remove/re-add destination)
- **Space fix:** Set 1.5TB quota
- **Backup status:** Running successfully within limits
- **Data protected:** M3 Pro backed up to 4TB external drive

---

*Time Machine is powerful but can be greedy with space. Always set a quota when sharing an APFS container with other volumes!*

