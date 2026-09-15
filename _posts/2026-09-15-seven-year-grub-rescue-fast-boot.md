---
title: "Seven Years of grub rescue, Killed by One BIOS Toggle"
date: 2026-09-15 01:00:00 +0000
categories: [Linux, Troubleshooting]
tags: [grub, dualboot, kali, parrot, bios, fastboot, gparted, uefi, asus, rog, strix, gl504gw, ai-assisted]
pin: false
math: false
mermaid: false
---

## The screen I stared at for seven years

```
error: ../../../grub-core/commands/search.c:371:no such device: 555bc766-1cde-4b89-a39e-1c7d764fac83.
error: ../../../grub-core/kern/fs.c:122:unknown filesystem.
grub rescue>
```

If you have ever dual-booted Linux, you know that prompt. It is the boot equivalent of your car turning over but not catching. Everything is *there* — the disk, the OS, your files — the machine just refuses to reach it.

I lived with that prompt, on and off, for **seven years**. And the fix, when it finally came, took **thirty seconds** and touched neither GRUB, nor the filesystem, nor the partition table. It was a single setting in the BIOS.

Here is the whole saga, and how it got solved in one long night.

## A short history of one very stubborn machine

The setup has been a moving target for seven years:

- **First install:** Kali + Parrot, side by side, on a 1TB 5400rpm spinning HDD. Slow, but it booted.
- **Upgrade one:** cloned everything onto a 1TB SSD.
- **Upgrade two:** cloned it all *again* onto a 4TB SSD.
- **The exile:** for about a year, my Kali install ("kali-old") lived on an **external HDD**, then got moved back inside the ASUS.
- Somewhere in there I dragged partitions from drive to drive with GParted so many times it felt like **Tetris** — shove this block left, grow that one, drop the next into the gap.

And the whole time, the same ghost kept coming back: **the ASUS could see the drive, but GRUB could not see kali-old.**

The last time I "fixed" it, the trick was adding the drive by hand in the GRUB menu. This time that didn't work. So — because past-me was clearly a lunatic — I installed a *second* Kali ("KaliRog") **just so I could see kali-old from it**. That kind of worked, except KaliRog then wouldn't boot properly thanks to a pile of GNOME errors. Fixing the boot problem gave me a boot problem. Classic.

This week I finally deleted KaliRog, grew kali-old back into the freed space with GParted... and got dropped straight back to `grub rescue>`. Seven years, and the ghost was still there.

So this time I decided to actually *understand* it instead of working around it.

## The exact hardware (for anyone Googling their model)

If you landed here by searching your laptop model plus "grub rescue", here is the exact machine — the fix may well apply to yours:

| | |
|---|---|
| **Laptop** | ASUS ROG Strix **GL504GW** (`Strix GL504GW_GL504GW`) |
| **BIOS** | American Megatrends (AMI), version **GL504GW.305** (2019) |
| **CPU** | Intel Core **i7-8750H** (8th gen, Coffee Lake) |
| **RAM** | 64 GB |
| **The problem disk** | Crucial **MX500 4TB SATA** SSD — Kali + Parrot live here |
| **The always-fine disk** | WD_BLACK **SN850X 4TB NVMe** — Windows lives here |

The fingerprint to look for: **a Linux install on a SATA drive, Windows on an NVMe drive, and intermittent `grub rescue` that only ever affects Linux.** Windows boots every time; Linux is a coin flip.

And this almost certainly is **not** ASUS-only. Any UEFI firmware with a "Fast Boot" style setting that skips full storage initialisation can cause it — vendors just name it differently ("Fast Boot", "Quick Boot", "Fast POST"). ASUS/AMI calls it **Fast Boot** in the Boot menu. (Don't confuse it with *Windows* Fast Startup — that's a separate feature inside Windows and not what we're touching here.)

## Rule one: image the drive before you touch anything

Before a single change, I took a full **Clonezilla** image of the 4TB drive to an external disk. Everything that follows was done knowing that if I bricked it, I could roll the whole thing back. If you take one thing from this post: **image first, debug second.**

## Ruling things out, one at a time

The trap with an intermittent bug is that it *lies*. The symptom points at a dozen different culprits. The only way through is to eliminate them with evidence, not hunches. Here is what got crossed off, and how.

### It's not the filesystem

`grub rescue>` says `unknown filesystem`, so the ext4 must be corrupt, right? No.

```bash
sudo dumpe2fs -h /dev/sda5 | grep -i "filesystem features"
# has_journal ext_attr resize_inode dir_index filetype needs_recovery
# extent 64bit flex_bg sparse_super large_file huge_file dir_nlink
# extra_isize metadata_csum
```

No `orphan_file`, nothing modern GRUB can't read. The filesystem was fine.

### It's not GRUB's installation

I reinstalled GRUB **three times** — plain, with a fresh core, with the boot hint corrected by hand. Each one reported "Installation finished. No error reported." Each one still dropped to rescue. When three clean reinstalls change nothing, the bootloader is not your problem.

### It's not a corrupt partition table

This was my favourite wrong theory. At the rescue prompt, `ls` showed a partition — `(hd2,gpt2)` — that my running system swore did not exist. Aha, a phantom! A stale GPT!

```bash
sudo gdisk -l /dev/sda
# Found valid GPT with protective MBR; using GPT.
# Number  Start        End          Size       Code  Name
#    1    10204064     5696351543   2.6 TiB    0700
#    3    7606151168   7731150847   59.6 GiB   2700  Swap
#    4    7731150848   7814037134   39.5 GiB   2700  ParrotOS
#    5    5696352256   7606151167   910.7 GiB  8300  Kali-Old
```

Clean, valid, no phantom. That `gpt2`? It was partition 2 of a *completely different disk* — the NVMe's 16MB Microsoft reserved partition. A red herring I chased for an hour. **Good thing I checked before "repairing" a table that was never broken.**

### It's not RAID mode

```bash
dmesg | grep -i ahci
# ahci 0000:00:17.0: AHCI vers 0001.0301, ... SATA mode
```

Plain AHCI, no Intel RST, no fake-RAID. Cross it off.

### It's not the USB drives

I had a couple of USB SSDs plugged in. Maybe they were shuffling GRUB's disk numbering? I pulled them and rebooted. Straight to rescue. Not that either. (I was sure it wouldn't be — but you check anyway.)

## The clue that cracked it

Here is the detail that had been hiding in plain sight for seven years.

**When it dropped to rescue, I could always get in by hitting the boot menu (F8) and picking the Kali partition.** Same GRUB, same disk, same everything — but that path *always worked*.

Then I mapped what GRUB saw at boot against my actual hardware:

| GRUB saw | Partitions | Actual disk |
|---|---|---|
| `hd2` | **5** (read perfectly) | **NVMe** — Windows. Boots every single time. |
| `hd0` / `hd1` | **0 and 1** | The **SATA SSD** — which actually has **four** partitions, including kali-old |

GRUB could read the NVMe flawlessly but **could barely see the SATA SSD** — the exact disk kali-old lives on. And the *only* thing that reliably fixed it was **sitting in the F8 boot menu for a few seconds first**.

Time. The fix was time.

## The actual cause

**Fast Boot.**

On a normal boot, the BIOS "Fast Boot" setting fires the bootloader *as fast as possible* — before the firmware has fully woken up and enumerated the SATA controller. So GRUB starts, goes looking for kali-old's UUID, and the SATA SSD **isn't awake yet**. It can't read a disk that isn't ready → `no such device` → `grub rescue>`.

Hit F8, and the firmware has to fully enumerate every boot device just to *draw the menu*. By the time you pick Kali, the SATA SSD is awake, GRUB reads it, and it boots. I had been **manually giving the disk time to wake up for seven years without realising it.**

The NVMe? Initialises instantly. Always ready. That's why Windows never, ever failed.

## The fix

On this ASUS ROG Strix GL504GW (AMI BIOS):

```
1. Reboot → tap F2 (or Del) to enter BIOS/UEFI setup
2. Press F7 for Advanced Mode
3. Boot tab → Fast Boot → Disabled
4. (Optional) Boot Option #1 → your Kali entry
5. F10 → Save & Exit
```

If you're on different hardware, look for the same idea under **Boot**: "Fast Boot",
"Quick Boot", or "Fast POST" — set it to Disabled. That's the setting that decides
whether the firmware waits for your storage before handing off to the bootloader.

Save. Exit. It booted straight into Kali on its own — no F8, no rescue — for the first time in seven years.

**Expected result:**
```
host: Kali-ROG   root: /dev/sda5   up 1 minute   kernel: 7.1.5+kali-amd64
```

## Will `apt upgrade` break it again?

No — and this is the reassuring part. The fix lives in the **BIOS**, not in GRUB. Kernel upgrades run `update-grub` and rewrite GRUB's config all they like; it doesn't matter, because the rescue prompt was **never a GRUB problem**. It was a disk that wasn't awake in time, and the firmware now waits for it. Upgrade away.

(If you ever *do* see rescue again after a big firmware update, check Fast Boot first. It resets sometimes.)

## What I'd tell my seven-years-ago self

- **Image the drive before you touch anything.** Clonezilla turns "I might brick this" into "I can undo this."
- **Intermittent bugs lie.** The symptom pointed at GRUB, the filesystem, the partition table, RAID, and USB — every one of them innocent. Eliminate with evidence, not vibes.
- **The workaround is a clue.** My F8 habit *was* the diagnosis, sitting there for seven years. When a manual step reliably fixes something, ask *what that step actually does* — the answer is often the real cause.
- **The fix took 30 seconds. Finding it took 30 hours.** That's normal. You don't get to the 30-second fix without the 30 hours of ruling things out.

Seven years, three drives, one external-HDD exile, a whole second Kali install, more GParted-Tetris than I care to admit — and in the end it was one toggle in the BIOS.

*Ah well. Keep firing.*
