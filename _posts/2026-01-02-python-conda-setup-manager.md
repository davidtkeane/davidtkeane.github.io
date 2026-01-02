---
title: "conda_setup: The Ultimate Conda Environment Manager"
date: 2026-01-02 02:00:00 +0000
categories: [Programming, Python]
tags: [python, conda, anaconda, miniconda, cli-tool, automation, data-science]
pin: false
math: false
mermaid: false
---

## Overview

If you use Conda for Python environments (especially for data science, ML, or scientific computing), you know the commands can get verbose. I built **conda_setup** to streamline everything into one powerful CLI tool.

**Download:** [conda_setup.py on GitHub](https://github.com/davidtkeane/Rangers-Scripts/blob/main/Programming-Scripts/System-Scripts/Environment-Managers/conda_setup.py)

---

## Why Conda?

Virtual environments (`venv`) are great for pure Python projects. But when you need:
- NumPy, SciPy, TensorFlow with optimized binaries
- Non-Python dependencies (like CUDA, MKL, OpenBLAS)
- Reproducible environments across machines

...Conda is the answer. But the commands are lengthy:

```bash
# The old way
conda create -n myenv python=3.11
conda activate myenv
conda install numpy pandas scikit-learn
conda env export > environment.yml
conda env list
conda env remove -n oldenv
```

With conda_setup, it's all in one place with an interactive menu AND CLI shortcuts.

---

## Features

### Interactive Menu (20 Options!)

Run `python3 conda_setup.py` for the full menu:

| Option | Feature |
|--------|---------|
| 1 | Create new environment |
| 2 | Activate environment |
| 3 | Delete environment |
| 4 | List all environments |
| 5 | Clone environment |
| 6 | Export to environment.yml |
| 7 | Import from environment.yml |
| 8 | Install package |
| 9 | Uninstall package |
| 10 | Update all packages |
| 11 | Search packages (conda-forge) |
| 12 | Show environment info |
| 13 | Auto-detect current environment |
| 14 | Show installed packages |
| 15 | Clean cache |
| 16 | Check conda health |
| 17 | Update conda itself |
| 18 | Show environment stats |
| 19 | Settings |
| 20 | Exit |

### CLI Quick Commands

```bash
# List all environments
python3 conda_setup.py --list

# Auto-detect active environment
python3 conda_setup.py --detect

# Show environment info
python3 conda_setup.py --info myenv

# Search for a package
python3 conda_setup.py --search pytorch

# Show packages in environment
python3 conda_setup.py --packages myenv

# Full help with all options
python3 conda_setup.py --help
```

### Auto-Install Dependencies

When switching environments, the script checks for:
- `environment.yml`
- `requirements.txt`

And offers to install them automatically:

```
Switching to environment 'ml-project'...

Found dependency files:
  - environment.yml (45 packages)
  - requirements.txt (12 pip packages)

Install dependencies now? (y/n):
```

---

## My Mistakes Building This

### Mistake #1: The External Drive Shebang

Same issue as venv_setup - I hardcoded my external drive path:

```python
#!/Volumes/KaliPro/Applications/miniconda3/envs/ranger/bin/python
```

When the drive wasn't mounted? Script wouldn't run at all.

**The fix:**
```python
#!/usr/bin/env python3
```

### Mistake #2: Duplicate Function Definitions

I had `parse_args()` defined TWICE in the file. Python just used the second one, but it caused confusion and the first definition's features were lost.

**Lesson:** Always search your file for duplicate function names before adding new ones!

### Mistake #3: Sudo for Everything

The original script asked for sudo password on EVERY run, even for:
- `--list` (just reads conda info)
- `--help` (just shows help text)
- `--search` (just queries conda-forge)

**The fix:**
```python
def needs_sudo():
    read_only_args = ['--list', '--help', '-h', '--no-color',
                      '--info', '--detect', '--packages', '--search', '--bunny']
    for arg in sys.argv[1:]:
        if arg in read_only_args:
            return False
    return True
```

Now read-only commands are instant - no password prompt.

### Mistake #4: Version Number Mismatch

The script said "v5.3" at the top but "v5.4" in the menu header. Small thing, but unprofessional.

**Lesson:** Keep version numbers in ONE place, or use a constant:
```python
VERSION = "5.6"
```

---

## Installation

```bash
# Download the script
curl -O https://raw.githubusercontent.com/davidtkeane/Rangers-Scripts/main/Programming-Scripts/System-Scripts/Environment-Managers/conda_setup.py

# Make executable
chmod +x conda_setup.py

# Optional: Create alias
echo 'alias cenv="python3 ~/bin/conda_setup.py"' >> ~/.zshrc
source ~/.zshrc

# Now use anywhere
cenv --list
cenv --detect
cenv --search numpy
```

### Requirements

- Python 3.6+
- Anaconda or Miniconda installed
- colorama (`pip install colorama`)

---

## Pro Tips

### Quick Environment Switching

```bash
# See what's available
cenv --list

# Check current environment
cenv --detect

# Get detailed info
cenv --info ml-project
```

### Package Discovery

```bash
# Search conda-forge for packages
cenv --search tensorflow

# See what's installed
cenv --packages myenv
```

### Environment Backup

The export feature creates a complete `environment.yml`:

```yaml
name: ml-project
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.11
  - numpy=1.24.0
  - pandas=2.0.0
  - scikit-learn=1.3.0
  - pip:
    - custom-package==1.0.0
```

Recreate on any machine with:
```bash
conda env create -f environment.yml
```

---

## Easter Egg

Try `python3 conda_setup.py --bunny` for a hopping good time!

---

## What I Learned

1. **Shebang portability is crucial** - External drive paths break everything
2. **Check for duplicate functions** - Easy to miss, hard to debug
3. **Read-only commands shouldn't need privileges** - UX matters
4. **Version numbers need a single source of truth**
5. **Auto-detection saves mental overhead** - Users shouldn't have to remember state

---

## Download

**GitHub:** [conda_setup.py](https://github.com/davidtkeane/Rangers-Scripts/blob/main/Programming-Scripts/System-Scripts/Environment-Managers/conda_setup.py)

**Version:** 5.6 Enhanced Edition

---

Rangers lead the way!
