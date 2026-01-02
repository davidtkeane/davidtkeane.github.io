---
title: "venv_setup: The Ultimate Python Virtual Environment Manager"
date: 2026-01-02 01:00:00 +0000
categories: [Programming, Python]
tags: [python, virtual-environment, venv, cli-tool, automation, cross-platform]
pin: false
math: false
mermaid: false
---

## Overview

Managing Python virtual environments can be tedious. Creating, activating, installing dependencies, switching between projects... it adds up. So I built **venv_setup** - a comprehensive CLI tool that handles everything from a single interface.

**Download:** [venv_setup.py on GitHub](https://github.com/davidtkeane/Rangers-Scripts/blob/main/Programming-Scripts/System-Scripts/Environment-Managers/venv_setup.py)

---

## The Problem I Was Solving

Every Python project needs its own virtual environment. But the workflow is repetitive:

```bash
# The old way - every single time
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip list
# ... forget which venv is active
# ... forget where venvs are located
```

I wanted ONE tool that could:
- Create/delete/list all my virtual environments
- Auto-detect if I'm in a project with a venv
- Prompt me to install dependencies when I activate
- Work on macOS, Linux, AND Windows

---

## Features

### Interactive Menu

Run `python3 venv_setup.py` for a full interactive menu:

| Option | Feature |
|--------|---------|
| 1 | Create new virtual environment |
| 2 | Activate existing environment |
| 3 | Delete environment |
| 4 | List all environments |
| 5 | Show environment info (size, packages) |
| 6 | Install from requirements.txt |
| 7 | Update all packages |
| 8 | Search installed packages |
| 9 | Auto-detect venv in current directory |

### CLI Quick Commands

```bash
# List all virtual environments
python3 venv_setup.py --list

# Auto-detect venv in current directory
python3 venv_setup.py --detect

# Show info for specific venv
python3 venv_setup.py --info myproject

# Show installed packages
python3 venv_setup.py --packages myproject

# Full help
python3 venv_setup.py --help
```

### Auto-Install Dependencies

This was my favorite addition. When you activate an environment, the script checks for:
- `requirements.txt`
- `requirements-dev.txt`
- `pyproject.toml`

If found, it asks if you want to install them automatically!

```
Activating environment 'myproject'...

Found dependency files in current directory:
  - requirements.txt (23 packages)
  - requirements-dev.txt (8 packages)

Install dependencies now? (y/n):
```

---

## My Mistakes Building This

### Mistake #1: Hardcoding the Python Path

**What I did wrong:**
```python
#!/Volumes/KaliPro/Applications/miniconda3/envs/ranger/bin/python
```

This worked on MY machine with my external drive. But when I tried running it elsewhere? Instant failure.

**The fix:**
```python
#!/usr/bin/env python3
```

**Lesson:** Always use `#!/usr/bin/env python3` for portable scripts.

### Mistake #2: Sudo Prompt for Read-Only Commands

The script asked for sudo password even when running `--list` or `--help`. Annoying!

**The fix:** Added a `needs_sudo()` function:
```python
def needs_sudo():
    read_only_args = ['--list', '--detect', '--info', '--packages', '--help', '-h']
    for arg in sys.argv[1:]:
        if arg in read_only_args:
            return False
    return True
```

Now read-only commands skip the sudo prompt entirely.

### Mistake #3: Not Cross-Platform Testing

I built this on macOS. When testing on Windows, the activation paths were completely wrong.

**macOS/Linux:** `source .venv/bin/activate`
**Windows:** `.venv\Scripts\activate.bat`

**The fix:** Platform detection at startup:
```python
PLATFORM = platform.system().lower()
IS_WINDOWS = PLATFORM == 'windows'
IS_MACOS = PLATFORM == 'darwin'
IS_LINUX = PLATFORM == 'linux'
```

---

## Installation

```bash
# Download the script
curl -O https://raw.githubusercontent.com/davidtkeane/Rangers-Scripts/main/Programming-Scripts/System-Scripts/Environment-Managers/venv_setup.py

# Make executable
chmod +x venv_setup.py

# Optional: Create alias
echo 'alias venv="python3 ~/bin/venv_setup.py"' >> ~/.zshrc
source ~/.zshrc

# Now use anywhere
venv --list
venv --detect
```

### Requirements

```bash
pip install colorama tqdm
```

---

## Easter Egg

Try `python3 venv_setup.py --bunny` for a surprise!

---

## What I Learned

1. **Portable shebangs matter** - Use `#!/usr/bin/env python3`
2. **Read-only commands shouldn't need elevated privileges**
3. **Cross-platform means testing on ALL platforms**
4. **Auto-detection saves time** - Detecting context (current venv, dependency files) makes tools much more useful

---

## Download

**GitHub:** [venv_setup.py](https://github.com/davidtkeane/Rangers-Scripts/blob/main/Programming-Scripts/System-Scripts/Environment-Managers/venv_setup.py)

**Version:** 2.3 Enhanced Edition

---

Rangers lead the way!
