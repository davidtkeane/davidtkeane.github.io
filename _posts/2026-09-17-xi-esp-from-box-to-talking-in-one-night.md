---
title: "xi-esp: From Box to Talking AI in One Night (and the Four Little Things That Tripped Us)"
date: 2026-09-17 00:30:00 +0000
categories: [Hardware, ESP32]
tags: [esp32-s3, xiaozhi, arduino-cli, esptool, ili9341, backup, lessons, ranger]
pin: false
math: false
mermaid: false
---

## Overview

A €30 board arrived in the post: an ESP32-S3 with a 2.8" capacitive touchscreen, listed as
"Supports Xiaozhi". Six hours later it was sitting on the desk telling me it was 2:25 in the
morning and asking why I wasn't in bed.

This is the story of that evening — identifying a no-name board from a photo, getting the
first pixels up, building a backup tool that actually works, finding the *official* AI
firmware hiding under a different manufacturer's name, and the four small mistakes that each
looked like a different bug entirely. Those four are the reason this post exists.

We call the board **xi-esp** so it never gets mixed up with the Waveshare ESP32s on the bench.

## What arrived

| | |
|---|---|
| MCU | ESP32-S3, 16 MB flash, 8 MB PSRAM, native USB |
| Display | 2.8" IPS 240×320, ILI9341, SPI |
| Touch | FT6336 capacitive, I2C |
| Audio | ES8311 codec + amp + **MEMS mic on board** — speaker plugs into a 1.25 mm socket |
| Extras | WS2812 RGB LED, microSD, LiPo charger, BAT/UART/I2C/GPIO sockets |

The listing didn't name the board. The back of the PCB did the talking: the touch flex was
silk-screened `IO15(SCL) IO16(SDA)`, the breakout header said `IO2 IO3 IO14 IO21`, and that
was enough to match it against a vendor's IO-allocation spreadsheet. **LCDwiki ES3C28P**,
sold by half a dozen sellers under half a dozen names.

Lesson zero: **photograph the back of the board before you plug it in.** The chips and the
silkscreen identify it; the listing never will.

## Step 1: Hello screen (Arduino, no IDE)

`arduino-cli` was already on the Mac. One core, one library, one sketch:

```bash
arduino-cli core install esp32:esp32
arduino-cli lib install "GFX Library for Arduino"
```

Arduino_GFX takes the pins in the constructor, so there's no library header to edit per board:

```cpp
Arduino_DataBus *bus = new Arduino_ESP32SPI(46 /*DC*/, 10 /*CS*/, 12 /*SCK*/, 11 /*MOSI*/, 13 /*MISO*/);
Arduino_GFX     *gfx = new Arduino_ILI9341(bus, GFX_NOT_DEFINED /*RST*/, 1 /*rotation*/, true /*IPS*/);
```

Flash with the right FQBN (S3, 16 MB, OPI PSRAM, serial over the native USB port):

```bash
arduino-cli compile --fqbn "esp32:esp32:esp32s3:CDCOnBoot=cdc,FlashSize=16M,PSRAM=opi,PartitionScheme=app3M_fat9M_16MB" .
arduino-cli upload  --fqbn "..." -p /dev/cu.usbmodemXXXX .
```

"RANGERS LEAD THE WAY" in green, touch coordinates streaming over serial. First pixels in
twelve minutes. Then the Ranger helmet logo, converted from a PNG to an RGB565 array with
twenty lines of Pillow, drawn on black. Tap the screen, it swaps between white and grey.

## Step 2: A backup tool you can trust

Before anything that took real hours went onto the board, I wanted a full flash image I
could put back. This is where the first trap was waiting.

### Trap 1 — esptool's stub loader dies on USB-JTAG

`esptool read_flash` failed every time after about 64 KB:

```
A fatal error occurred: Serial data stream stopped: Possible serial noise or corruption.
```

Every baud rate. Every chunk size. Retries. The fix was one flag: **`--no-stub`**. esptool
normally uploads a small helper program into the chip's RAM for speed; on the ESP32-S3's
native USB-JTAG serial port on macOS, that helper drops the stream. The chip's built-in ROM
loader is slow — about 100 seconds per megabyte, 27 minutes for the full 16 MB — but it has
never failed once. Two independent reads of the same megabyte came back byte-identical.

Writes are unaffected (the stub is fine in that direction, and esptool hash-verifies them).

So the tool reads in 1 MB chunks, resumes if interrupted, re-reads a 64 KB sample afterwards
and compares it, stores an md5, and refuses to restore a file whose md5 doesn't match. It also
identifies boards by the USB serial number (which is the chip's MAC), so the other ESP32 on
the same Mac shows up as `DO NOT FLASH` and can't be hit by accident.

### Trap 2 — never edit a script that's running

I ran the first backup, it worked. Then I handed the tool over and, while the second 27-minute
backup was running in another terminal, I added a couple of commands to the script. When the
backup finished, the terminal ended with:

```
xi-esp.sh: line 169: unexpected EOF while looking for matching `"'
```

The backup was fine — I checked the md5 independently. But it *looked* like a failure, on the
one tool whose whole job is to be trusted. Bash doesn't load a script into memory; it reads it
from disk as it goes. Edit the file underneath a running instance and the running shell reads
your half-finished changes. **Check `ps` before you edit a script; edit a copy and `mv` it into
place.** A rename is atomic — the running shell keeps the old file.

## Step 3: The two bugs that pretended to be touch bugs

### Trap 3 — "white" that was 3 % brighter than grey

I made a white version of the helmet by scaling every pixel so the brightest one became 255.
Tapping the screen "did nothing". The serial log showed every tap swapping bitmaps perfectly.
The brightest pixel after a Lanczos resize is a ringing artefact at 248; the helmet's actual
grey is 186. Scaling from the peak made "white" 195. Invisible.

**Normalise from the object's median, never from the max.** Resizing inflates the max.

### Trap 4 — the IPS panel wants inversion ON

Next report: "black helmet on a white background". The whole screen was a negative. This
panel is IPS, and IPS ILI9341s need the inversion command sent; Arduino_GFX exposes it as the
`ips` flag in the constructor. Rather than guess again, I shipped a build where **holding a
finger on the screen for one second flips inversion live** and asked which way looked right.
One hold — "boom" — black background, white helmet. Baked in as the default.

Two rules came out of that pair: **when "X isn't working", read the serial log before touching
X** — both times the log showed X working. And **on any new panel, put an inversion toggle in
the first sketch.**

## Step 4: The official Xiaozhi firmware, under another name

Xiaozhi is the open-source ESP32-S3 AI voice-assistant firmware (`78/xiaozhi-esp32`, 48
supported boards, prebuilt binaries). Our board wasn't in the list. Its 3.5" sibling was, with
different pins. Dead end?

I put three pin tables side by side — the vendor's spreadsheet, the seller's own firmware fork,
and every 2.8" board in the official repo. **`freenove-esp32s3-display-2.8-lcd` matched ours
pin for pin**: same I2S lines, same amp-enable, same codec I2C, same display wiring, same LED,
and `DISPLAY_INVERT_COLOR true` — the very thing from Trap 4. The Freenove README even says
"likely the same hardware design as LCDwiki ES3C28P". Same reference design, different sticker.

Download the official v2.5.0 merged binary, write it at `0x0`, hash verified in 47 seconds.
The board came up in Wi-Fi-setup mode with its own hotspot and a captive portal — in English —
that listed the house network. Password in, six-digit code on screen, code into the console,
speaker into the socket. "Ni hao." It answered in Chinese. Switched the language and persona
in the console. "Hello, how are you?"

Third sentence from the board: *"Do you know what time it is?"*
"Yes — do you?"
*"It's 2:25 and it's late. Why are you not in bed?"*

## What we learned

1. **Photograph the PCB.** Silkscreen + chip markings identify a no-name board; the listing doesn't.
2. **`esptool --no-stub` for reads on S3 USB-JTAG.** Slow, reliable. Writes can keep the stub.
3. **A backup isn't a backup until it's verified** — re-read a sample, store an md5, refuse mismatches.
4. **Never edit a running bash script.** `ps` first; copy, edit, `mv`.
5. **Normalise images from the median, not the max.**
6. **IPS panels: inversion on.** Ship a runtime toggle in the first sketch instead of guessing.
7. **Read the serial log before "fixing" what the user reports.** Twice tonight the thing reported broken was working.
8. **Search the official board list by pins, not by name.** Reference designs get resold under many names.

## What's next

The cloud step was the test. The board only streams audio; the server does speech-to-text, the
language model, and text-to-speech. `xiaozhi-esp32-server` is self-hostable and has an Ollama
backend — so the next job is pointing this same board at a server in this house, with a local
model as the brain. No account, no cloud, and the desk Ranger keeps telling me to go to bed.

Rangers lead the way!
