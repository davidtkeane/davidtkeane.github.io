---
title: "TryHackMe 'The Game' CTF: Reverse Engineering a Godot Game"
date: 2026-01-01 03:00:00 +0000
categories: [CTF, TryHackMe]
tags: [tryhackme, ctf, godot, reverse-engineering, gamedev, tetris, gdre]
pin: false
math: false
mermaid: false
---

## Overview

This walkthrough covers TryHackMe's "The Game" room - a CTF challenge that involves reverse engineering a Tetris-like game built with the Godot engine. The goal is to find a hidden flag by modifying the game's source code.

**Room:** [The Game](https://tryhackme.com/room/hfb1thegame)
**Difficulty:** Easy
**Time:** They said 5 minutes... it took longer!

> **Note:** The creators recommend using Windows for this room, as Linux can cause issues with the download and setup.

---

## Tools Required

Before starting, download these tools:

| Tool | Purpose | Download |
|------|---------|----------|
| **Godot Engine** | Game engine to edit the project | [godotengine.org](https://godotengine.org/download/windows/) |
| **GDRE Decompiler** | Extract source from .pck files | [GitHub Releases](https://github.com/GDRETools/gdsdecomp/releases) |

---

## Step 1: Run the Game

Download and extract the challenge zip file. Inside you'll find:
- Windows executable (`.exe`)
- Mac executable

Run the `.exe` and you'll see a Tetris-like game with a curious message in the corner:

> **"Score more than 999999"**

<!-- Screenshot placeholder: Game running with score requirement visible -->
*[Screenshot: The game showing "Score more than 999999" requirement]*

Scoring 999,999 points in Tetris legitimately? That's not a challenge, that's a life sentence! There must be another way...

---

## Step 2: Identify the Game Engine

The game icon has a distinctive look - it's the default Godot Engine icon! This tells us:

1. The game was built with Godot
2. We can use Godot tools to reverse engineer it
3. The source code is likely packed in a `.pck` file

<!-- Screenshot placeholder: Game icon -->
*[Screenshot: Game icon showing Godot-like appearance]*

---

## Step 3: Extract the Source Code with GDRE

Fire up **GDRE Tools** (gdsdecomp):

### 3.1 Open GDRE Tools
Launch the decompiler application.

<!-- Screenshot placeholder: Step 1 -->
*[Screenshot: GDRE Tools main interface]*

### 3.2 Select "Recover Project"
From the RE Tools menu, choose "Recover Project."

<!-- Screenshot placeholder: Step 2 -->
*[Screenshot: Recover Project option]*

### 3.3 Select the Game Executable
Browse to and select the game's `.exe` file.

<!-- Screenshot placeholder: Step 3 -->
*[Screenshot: Selecting the exe file]*

### 3.4 Extract Files
Choose a target directory and click "Extract."

<!-- Screenshot placeholder: Step 4 -->
*[Screenshot: Extraction settings]*

The decompiler will extract all game assets, scripts, and project files.

---

## Step 4: Import into Godot Engine

Now we open the extracted project in Godot:

### 4.1 Launch Godot and Click "Import"

<!-- Screenshot placeholder: Step 6 -->
*[Screenshot: Godot import button]*

### 4.2 Select `project.godot`
Navigate to your extracted folder and select the `project.godot` file.

<!-- Screenshot placeholder: Step 7 -->
*[Screenshot: Selecting project.godot]*

### 4.3 Import the Project

<!-- Screenshot placeholder: Step 8 -->
*[Screenshot: Import confirmation]*

The project is now loaded in Godot with full access to the source code!

---

## Step 5: Find the Score Check

Remember the "999999" requirement? Let's find it in the code.

### 5.1 Open "Find in Files"
Use Godot's search feature: **Edit → Find in Files** (or `Ctrl+Shift+F`)

<!-- Screenshot placeholder: Step 9 -->
*[Screenshot: Find in Files menu]*

### 5.2 Search for "999999"

<!-- Screenshot placeholder: Step 10 -->
*[Screenshot: Search results]*

**Found it!** The search reveals a condition checking if the score exceeds 999999.

### 5.3 Examine the Code

Click the search result to jump to the code:

```gdscript
# The original code
if score >= 999999:
    # Show something special... the flag perhaps?
    $ButtonContainer/T.show()
```

<!-- Screenshot placeholder: Step 11 -->
*[Screenshot: The code with score check]*

---

## Step 6: Modify the Code

We don't need to score 999,999 points. We just need the game to *think* we did!

### Change the Condition

```gdscript
# Original:
if score >= 999999:

# Modified (triggers immediately):
if score >= 0:
```

By changing `999999` to `0`, the condition is true from the start!

---

## Step 7: Run and Capture the Flag

Press **F5** to run the modified game.

<!-- Screenshot placeholder: Step 12 -->
*[Screenshot: The flag revealed!]*

**The flag appears instantly!** No need to play Tetris for hours.

---

## Summary

| Step | Action |
|------|--------|
| 1 | Run game, notice "999999" requirement |
| 2 | Identify Godot engine from icon |
| 3 | Use GDRE to extract source code |
| 4 | Import project into Godot |
| 5 | Search for "999999" in code |
| 6 | Change condition to `score >= 0` |
| 7 | Run game, get flag! |

---

## Key Takeaways

1. **Game icons can reveal the engine** - Default icons are a giveaway
2. **GDRE Tools are essential** - For reversing Godot games
3. **Always search for magic numbers** - Hints in-game often appear in code
4. **Modify, don't play fair** - CTFs reward creative thinking

---

## Tools Reference

```bash
# GDRE Decompiler
https://github.com/GDRETools/gdsdecomp/releases

# Godot Engine
https://godotengine.org/download/

# TryHackMe Room
https://tryhackme.com/room/hfb1thegame
```

---

## Lessons Learned

**What I thought:** "5 minutes? This should be quick!"

**Reality:** Setting up tools, understanding Godot, and figuring out the workflow took time.

**The actual hack:** Once you know the process, it really is about 5 minutes:
1. Extract with GDRE (1 min)
2. Import to Godot (1 min)
3. Search and modify (2 min)
4. Run and capture (1 min)

---

*This room is a great introduction to game reverse engineering. The skills learned here apply to many Godot-based CTF challenges!*

**Happy Hacking!** 🎮🚩

