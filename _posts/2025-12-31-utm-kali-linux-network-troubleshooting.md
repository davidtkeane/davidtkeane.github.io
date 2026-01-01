---
title: "UTM Kali Linux Network Troubleshooting on macOS (M1/M2/M3/M4)"
date: 2025-12-31 16:00:00 +0000
categories: [Virtualization, Troubleshooting]
tags: [utm, kali, linux, macos, networking, virtual-machine, apple-silicon, troubleshooting]
pin: false
math: false
mermaid: false
---

## Overview

This guide covers common network issues when running Kali Linux in UTM on Apple Silicon Macs (M1, M2, M3, M4). If your Kali VM can't connect to the internet, network icon keeps spinning, or you're getting QEMU errors, this guide is for you!

---

## Common Error: Shared Folder Permission Denied

**Error:**
```
QEMU error: QEMU exited from an error: qemu-aarch64-softmmu:
-device virtio-9p-pci,fsdev=virtfs0,mount_tag=share:
cannot initialize fsdev 'virtfs0': failed to open '/Users/username/share':
Operation not permitted
```

**Cause:** macOS is blocking UTM from accessing the shared folder.

### Fix 1: Grant Full Disk Access

1. Open **System Settings** → **Privacy & Security**
2. Click **Full Disk Access**
3. Click **+** button
4. Navigate to `/Applications/UTM.app` and add it
5. Toggle it **ON**
6. Restart UTM completely

### Fix 2: Files and Folders Permission

1. Open **System Settings** → **Privacy & Security**
2. Click **Files and Folders**
3. Find **UTM** in the list
4. Enable all folder access toggles

### Fix 3: Reset Folder Attributes

```bash
# Remove extended attributes blocking access
xattr -cr /path/to/shared/folder

# Verify permissions
ls -la /path/to/shared/folder
```

### Fix 4: Use a Simpler Share Path

```bash
# Create a new share folder in home directory
mkdir ~/VMShare
```

Then update UTM to share `~/VMShare` instead of nested paths.

### Fix 5: Re-add Shared Folder

1. Open UTM → Select VM → **Edit**
2. Go to **Sharing** tab
3. Remove the current shared folder
4. Click **+** to add it again (triggers new permission prompt)
5. Accept the permission dialog

---

## UTM Network Settings

### How to Access Network Settings

1. Open **UTM**
2. Select your Kali VM
3. Click **Edit** (or right-click → Edit)
4. Go to **Network** tab

### Recommended Network Configuration

**Option 1: Emulated VLAN (Most Compatible)**

| Setting | Value |
|---------|-------|
| Network Mode | **Emulated VLAN** |
| Emulated Network Card | **virtio-net-pci** |

Best for: General use, most stable option.

**Option 2: Shared Network (Simple NAT)**

| Setting | Value |
|---------|-------|
| Network Mode | **Shared Network** |
| Emulated Network Card | **virtio-net-pci** |

Best for: Quick setup, internet access without configuration.

**Option 3: Bridged Network (Advanced)**

| Setting | Value |
|---------|-------|
| Network Mode | **Bridged (Advanced)** |
| Bridged Interface | **en0** (WiFi) or **en1** (Ethernet) |
| Emulated Network Card | **virtio-net-pci** |

Best for: VM needs its own IP on your network, running servers.

### Network Mode Comparison

| Mode | Internet | See Host | Own IP | Complexity |
|------|----------|----------|--------|------------|
| Emulated VLAN | Yes | Yes | NAT | Low |
| Shared Network | Yes | Yes | NAT | Low |
| Bridged | Yes | Yes | Real IP | Medium |
| Host Only | No | Yes | Internal | Low |

---

## The Fix That Actually Worked (DHCP Offer But No ACK)

This is the specific issue I encountered and the solution that finally worked.

### The Problem

Running `sudo dhclient -v eth0` showed:
```
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 4
DHCPOFFER of 192.168.1.43 from 192.168.1.1
DHCPREQUEST for 192.168.1.43 on eth0 to 255.255.255.255 port 67
DHCPREQUEST for 192.168.1.43 on eth0 to 255.255.255.255 port 67
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 8
...
```

The router was **offering** an IP address, but the **DHCPACK** (acknowledgment) never came back. The VM could see the network, the router could see the VM, but DHCP couldn't complete.

### The Solution: Static IP

Since the router offered `192.168.1.43`, we know the network works. Just configure it manually!

**Step 1: Set IP immediately (temporary)**
```bash
sudo ip addr add 192.168.1.43/24 dev eth0
sudo ip route add default via 192.168.1.1
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

**Step 2: Test it works**
```bash
ping google.com
```

**Step 3: Make it permanent**
```bash
sudo nano /etc/network/interfaces
```

Add to the end of the file:
```
# Ethernet - Static IP (DHCP doesn't complete in bridged mode)
auto eth0
iface eth0 inet static
    address 192.168.1.43
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

Complete file looks like:
```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# Ethernet - Static IP (DHCP doesn't complete in bridged mode)
auto eth0
iface eth0 inet static
    address 192.168.1.43
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

**Step 4: Apply without reboot**
```bash
sudo systemctl restart networking
```

### About the Grayed Network Icon

After this fix, the network icon in Kali's taskbar may appear **grayed out**. This is **normal and expected**!

| Service | Managing eth0 | Icon Status |
|---------|---------------|-------------|
| NetworkManager | No | Grayed |
| /etc/network/interfaces | Yes ✅ | No icon change |

The icon is grayed because NetworkManager is no longer managing eth0 - the `/etc/network/interfaces` file handles it now. **Your network still works perfectly!**

### Result

```
✅ IP: 192.168.1.43
✅ Gateway: 192.168.1.1
✅ DNS: 8.8.8.8
✅ Internet: Working
✅ Survives reboot: Yes
```

---

## Troubleshooting Inside Kali

### Network Icon Spinning / Not Connecting

**Step 1: Restart NetworkManager**
```bash
sudo systemctl restart NetworkManager
```

**Step 2: Check Interface Status**
```bash
# List all interfaces
ip a

# Check specific interface
ip addr show eth0
ip addr show enp0s1
```

**Step 3: Force DHCP Request**
```bash
# Release and renew IP
sudo dhclient -r eth0
sudo dhclient -v eth0
```

### No Network Interface Found

**Check available interfaces:**
```bash
ip link show
```

**If no eth0, try:**
```bash
# Find correct interface name
ip link | grep -E "^[0-9]"

# Common names on UTM:
# - eth0
# - enp0s1
# - ens3
```

**Bring interface up manually:**
```bash
sudo ip link set eth0 up
sudo dhclient eth0
```

### NetworkManager Not Running

**Check status:**
```bash
sudo systemctl status NetworkManager
```

**Start it:**
```bash
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager
```

**If completely broken:**
```bash
sudo killall NetworkManager
sudo NetworkManager &
```

### View Real-time Network Logs

```bash
# Watch NetworkManager logs
journalctl -u NetworkManager -f

# Watch all network-related messages
dmesg | grep -i net
```

---

## Manual Network Configuration

If NetworkManager isn't working, configure manually:

### Using ip commands (temporary)

```bash
# Bring interface up
sudo ip link set eth0 up

# Set IP address manually
sudo ip addr add 192.168.64.10/24 dev eth0

# Add default gateway
sudo ip route add default via 192.168.64.1

# Set DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### Using /etc/network/interfaces (permanent)

```bash
sudo nano /etc/network/interfaces
```

Add:
```
auto eth0
iface eth0 inet dhcp
```

Or for static IP:
```
auto eth0
iface eth0 inet static
    address 192.168.64.10
    netmask 255.255.255.0
    gateway 192.168.64.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

Then:
```bash
sudo systemctl restart networking
```

---

## Test Network Connectivity

### Basic Tests

```bash
# Test local interface
ping -c 3 127.0.0.1

# Test gateway (find yours with: ip route)
ping -c 3 192.168.64.1

# Test internet (IP)
ping -c 3 8.8.8.8

# Test DNS resolution
ping -c 3 google.com
```

### If Ping Works But No Internet

DNS might be broken:

```bash
# Check current DNS
cat /etc/resolv.conf

# Temporarily fix DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Test
nslookup google.com
```

---

## UTM-Specific Fixes

### Reset VM Network

1. Shut down VM completely (not restart)
2. In UTM, go to VM settings → **Network**
3. Delete the network device
4. Add a new network device
5. Start VM

### Change Network Card Type

If `virtio-net-pci` doesn't work, try:

| Card Type | Compatibility | Speed |
|-----------|---------------|-------|
| virtio-net-pci | Best | Fastest |
| e1000 | Good | Fast |
| rtl8139 | Legacy | Slow |

### Check QEMU Network Backend

In VM settings, ensure:
- Network backend is properly configured
- No conflicting port forwards
- MAC address is unique (if running multiple VMs)

---

## Complete Reset Procedure

If nothing works, try a complete network reset:

**Inside Kali:**
```bash
# Stop NetworkManager
sudo systemctl stop NetworkManager

# Flush all network config
sudo ip addr flush dev eth0
sudo ip route flush table main

# Restart networking
sudo systemctl restart networking
sudo systemctl start NetworkManager

# Force DHCP
sudo dhclient -v eth0
```

**In UTM:**
1. Shut down VM
2. Edit VM → Network → Delete network adapter
3. Save
4. Edit VM → Network → Add new network adapter
5. Set to Emulated VLAN + virtio-net-pci
6. Save and start VM

---

## Rosetta for Linux (ARM64 VMs)

If running an ARM64 Kali on Apple Silicon:

### Enable Rosetta in UTM

1. Edit VM → **System**
2. Check **Enable Rosetta** (if available)
3. This helps with x86 binary compatibility

### Install Rosetta Support in Kali

```bash
# Mount Rosetta share (if configured)
sudo mkdir -p /media/rosetta
sudo mount -t virtiofs rosetta /media/rosetta

# Register Rosetta as binfmt handler
sudo /usr/sbin/update-binfmts --install rosetta /media/rosetta/rosetta \
    --magic "\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00" \
    --mask "\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff" \
    --credentials yes --preserve no --fix-binary yes
```

---

## Quick Reference Commands

```bash
# Check IP address
ip a

# Check routing table
ip route

# Check DNS
cat /etc/resolv.conf

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Force DHCP
sudo dhclient -v eth0

# Watch network logs
journalctl -u NetworkManager -f

# Test connectivity
ping -c 3 8.8.8.8
ping -c 3 google.com

# List network interfaces
nmcli device status

# Connect to network
nmcli connection up "Wired connection 1"

# Show all connections
nmcli connection show
```

---

## Troubleshooting Flowchart

```
Network not working?
│
├─► Check UTM Network Settings
│   └─► Set to Emulated VLAN + virtio-net-pci
│
├─► Inside VM: ip a
│   ├─► No interface? → Check UTM network adapter
│   └─► Interface exists but no IP? → Continue below
│
├─► sudo dhclient -v eth0
│   ├─► Got IP? → Test with ping 8.8.8.8
│   ├─► DHCPOFFER but no DHCPACK? → Use static IP! ✅
│   │   └─► See "The Fix That Actually Worked" section
│   └─► No response at all? → Check UTM network mode
│
├─► ping 8.8.8.8
│   ├─► Works? → DNS issue, fix /etc/resolv.conf
│   └─► Fails? → Routing issue, check ip route
│
├─► Network icon grayed out?
│   └─► Normal! /etc/network/interfaces is managing it
│
└─► Still broken?
    └─► Complete reset procedure above
```

---

## Summary

| Problem | Solution |
|---------|----------|
| Permission denied (share) | Grant UTM Full Disk Access |
| No network in VM | Set Emulated VLAN mode |
| NetworkManager spinning | `sudo dhclient -v eth0` |
| DHCP offers but no ACK | Use static IP in /etc/network/interfaces ✅ |
| No interface | Check UTM network adapter settings |
| Can ping IP not domain | Fix DNS in /etc/resolv.conf |
| Grayed network icon | Normal! /etc/network/interfaces manages it |
| Nothing works | Complete reset procedure |

---

## Key Takeaways

1. **Full Disk Access** is often needed for UTM shared folders
2. **Emulated VLAN** is the most reliable network mode
3. **virtio-net-pci** is the fastest network card type
4. **dhclient** can force DHCP when NetworkManager fails
5. Always **fully shut down** VM after changing settings
6. Check **journalctl** logs for detailed error messages

---

## Resources

- [UTM Documentation](https://docs.getutm.app/)
- [UTM GitHub Issues](https://github.com/utmapp/UTM/issues)
- [Kali Linux on UTM](https://www.kali.org/docs/virtualization/install-utm-guest-vm/)
- [Apple Silicon VM Networking](https://developer.apple.com/documentation/virtualization)

---

*Virtual machines can be tricky, but once configured correctly, they run smoothly. Save this guide for future reference!*

