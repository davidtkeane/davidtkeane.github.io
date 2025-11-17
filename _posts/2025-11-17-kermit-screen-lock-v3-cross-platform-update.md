---
title: "Kermit Screen Lock v3.1.0 - Cross-Platform Update with CLI Arguments"
date: 2025-11-17 10:00:00 +0000
categories: [Security, Tools]
tags: [python, automation, tkinter, pygame, cross-platform, linux, macos]
pin: false
math: false
mermaid: false
image:
  path: /assets/img/kermit.gif
  alt: Kermit the Frog Screen Lock
---

## Overview

I've just released **Kermit Screen Lock v3.1.0**, a major update that transforms a fun macOS-only screen lock application into a fully cross-platform tool with powerful command-line options. This post covers the changes made, new features, and the exciting roadmap ahead.

![Kermit the Frog](/assets/img/kermit.gif)
_The iconic Kermit GIF that displays fullscreen during the lock_

## What is Kermit Screen Lock?

Kermit is a Python-based screen lock experience that displays a fullscreen animated GIF with looping audio. It's secured with a secret key combination that you need to remember to exit - perfect for a fun prank or actual screen protection.

**GitHub Repository:** [https://github.com/davidtkeane/kermit](https://github.com/davidtkeane/kermit)

---

## Major Updates in v3.0.0 & v3.1.0

### Cross-Platform Support (v3.0.0)

The original Kermit was macOS-only. Now it works on:

- **macOS** - Native support
- **Linux (Kali/Debian/Ubuntu)** - Full support
- **MacBook keyboard in VM** - Same physical keys work on both platforms!

The script automatically detects your operating system and applies the correct key bindings:

| Platform | Exit Keys | Pause Keys |
|----------|-----------|------------|
| macOS | Control + Option + Left Shift | Control + Option + P |
| Linux | Ctrl + Alt + Left Shift | Ctrl + Alt + P |

### Command-Line Arguments (v3.1.0)

Brand new CLI support lets you customize everything:

```bash
# Use custom GIF
python kermit.py --gif custom.gif

# Use custom audio
python kermit.py --audio music.mp3

# Set initial volume (50%)
python kermit.py --volume 0.5

# Silent mode - no audio
python kermit.py --no-sound

# Combine options
python kermit.py --gif cat.gif --audio meow.mp3 --volume 0.3

# Show help with examples
python kermit.py --help
```

### Graceful Error Handling

No more crashes! If files are missing, you get helpful messages:

```
ERROR: Missing required files

GIF file not found: custom.gif
  -> Check that the file path is correct

Audio file not found: custom.mp3
  -> Check that the file path is correct
  -> Or use --no-sound to run without audio

Current directory: /home/kali/Documents/Apps/kermit
```

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/davidtkeane/kermit.git
cd kermit
```

### 2. Install System Dependencies

**Linux (Kali/Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install python3-tk
```

**macOS:**
```bash
# tkinter is usually included
# If missing:
brew install python-tk@3.x
```

### 3. Install Python Packages

```bash
pip install -r requirements.txt
```

### 4. Run It!

```bash
python kermit.py
```

---

## Features at a Glance

- **Fullscreen Animated GIF Display** - Automatically scales to your screen
- **Looping MP3 Audio** - Continuous playback
- **Secret Exit Combination** - Platform-specific key combos
- **Pause/Resume** - Control both audio and animation
- **Volume Control** - Up/Down arrow keys
- **Custom Media Files** - Use your own GIF and audio
- **Silent Mode** - Animation without sound
- **Hidden Mouse Cursor** - Clean fullscreen experience
- **Cross-Platform** - macOS and Linux support

---

## Technical Implementation

### Platform Detection

```python
import platform

CURRENT_OS = platform.system()

if CURRENT_OS == "Darwin":  # macOS
    SECRET_KEYSYMS = {"Control_L", "Alt_L", "Shift_L"}
else:  # Linux
    SECRET_KEYSYMS = {"Control_L", "Alt_L", "Shift_L"}
```

### Argument Parsing

Using Python's `argparse` for robust CLI handling:

```python
def parse_arguments():
    parser = argparse.ArgumentParser(
        description=f"Kermit Screen Lock Experience v{VERSION}"
    )

    parser.add_argument(
        "--gif", type=str, default=DEFAULT_IMAGE_FILE,
        help="Path to GIF file"
    )

    parser.add_argument(
        "--volume", type=float, default=1.0,
        help="Initial volume level 0.0-1.0"
    )

    parser.add_argument(
        "--no-sound", action="store_true",
        help="Run without audio"
    )

    return parser.parse_args()
```

### File Validation

Pre-launch checks ensure a smooth experience:

```python
def validate_files(gif_path, audio_path, no_sound):
    import os
    errors = []

    if not os.path.isfile(gif_path):
        errors.append(f"GIF file not found: {gif_path}")
        errors.append("  -> Check that the file path is correct")

    if errors:
        print("ERROR: Missing required files\n")
        for error in errors:
            print(error)
        sys.exit(1)
```

---

## Future Roadmap (TODO)

### v3.2.0 - Security & Lock Mode

- **Timeout Feature** - `--timeout <minutes>` auto-exit
- **Lockdown Mode** - `--lockdown` blocks ALL escape methods
- **Password/PIN Protection** - Require authentication to exit
- **Block Alt-Tab, Alt-F4, Escape** - True screen lock

### v3.3.0 - Visual Feedback

- On-screen volume indicator
- Pause/mute overlay display
- Exit hint after inactivity
- Loading screen and splash

### v4.0.0 - Platform Support & Polish

- Windows platform testing
- Type hints throughout codebase
- Comprehensive logging system
- Unit tests

---

## Project Structure

```
kermit/
├── kermit.py           # Main script (400+ lines)
├── files/
│   ├── kermit.gif      # Animated GIF
│   └── kermit.mp3      # Audio file
├── README.md           # Full documentation
├── CHANGELOG.md        # Version history
├── TODO.md             # Roadmap & plans
├── requirements.txt    # Python dependencies
└── LICENSE             # MIT License
```

---

## Quick Reference

| Action | Keys (Linux) | Keys (macOS) |
|--------|--------------|--------------|
| **Exit** | Ctrl + Alt + Left Shift | Control + Option + Left Shift |
| **Pause** | Ctrl + Alt + P | Control + Option + P |
| **Volume Up** | Up Arrow | Up Arrow |
| **Volume Down** | Down Arrow | Down Arrow |

---

## Contributing

The project is open source! Feel free to:

1. Fork the repository
2. Submit pull requests
3. Report issues
4. Suggest features

Check out the [TODO.md](https://github.com/davidtkeane/kermit/blob/main/TODO.md) for planned features and contribute to the roadmap.

---

## Conclusion

This update transforms Kermit from a simple macOS prank tool into a legitimate cross-platform screen lock application. The addition of CLI arguments makes it highly customizable, and the error handling ensures a smooth user experience.

Next up: implementing the timeout and lockdown features for v3.2.0. Stay tuned!

**Repository:** [https://github.com/davidtkeane/kermit](https://github.com/davidtkeane/kermit)

Give it a star if you find it useful!
