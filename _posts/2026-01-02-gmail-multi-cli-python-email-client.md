---
title: "Gmail Multi-CLI: A Python Email Client for Multiple Accounts"
date: 2026-01-02 03:00:00 +0000
categories: [Programming, Python]
tags: [python, gmail, email, cli-tool, automation, imap, smtp]
pin: false
math: false
mermaid: false
---

## Overview

Managing multiple Gmail accounts from the terminal? That's what **Gmail Multi-CLI** does. Check emails, send messages, test connections - all from the command line without opening a browser.

**Download:** [gmail_multi.py on GitHub](https://github.com/davidtkeane/gmail-multi-cli/blob/main/gmail_multi.py)

---

## Why I Built This

I have 3 Gmail accounts - personal, work, and a project-specific one. Constantly switching between browser tabs was inefficient. I wanted:

- Quick email checks without opening Chrome
- Send emails from terminal during coding sessions
- Test all accounts are working with one command
- Automate email notifications in scripts

---

## Features

### Interactive Menu

Run `python3 gmail_multi.py` for the full menu:

| Option | Feature |
|--------|---------|
| 1 | Check new emails |
| 2 | Check older emails |
| 3 | Read email by ID |
| 4 | Send email |
| 5 | Forward email |
| 6 | Search emails |
| 7 | Switch account |
| 8 | Exit |

### CLI Quick Commands

```bash
# List configured accounts
gmail --accounts

# Test connection to all accounts
gmail --test

# Quick check for new emails (default account)
gmail --check

# Check ALL accounts
gmail --check-all

# Send email interactively
gmail --send

# Send email with arguments
gmail --quick-send recipient@email.com "Subject" "Body text"

# Full help
gmail --help
```

### Auto-Install Dependencies

The script checks for required packages on startup:

```python
def check_and_install_packages():
    required_packages = {
        'colorama': 'colorama',
        'psutil': 'psutil',
    }
    # ... auto-installs if missing
```

No more `ModuleNotFoundError` surprises!

---

## Setup

### 1. Get Gmail App Password

Google requires App Passwords for third-party email clients:

1. Go to [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
2. Select "Mail" and your device
3. Copy the 16-character password

### 2. Configure Accounts

Edit the `EMAIL_ACCOUNTS` dictionary in the script:

```python
EMAIL_ACCOUNTS = {
    "personal": {
        "email": "your.email@gmail.com",
        "password": "xxxx xxxx xxxx xxxx",  # App Password
        "imap_server": "imap.gmail.com",
        "smtp_server": "smtp.gmail.com"
    },
    "work": {
        "email": "work.email@gmail.com",
        "password": "yyyy yyyy yyyy yyyy",
        "imap_server": "imap.gmail.com",
        "smtp_server": "smtp.gmail.com"
    }
}
```

### 3. Run It

```bash
# Make executable
chmod +x gmail_multi.py

# Create alias for easy access
echo 'alias gmail="python3 ~/path/to/gmail_multi.py"' >> ~/.zshrc
source ~/.zshrc

# Use it
gmail --check
```

---

## My Mistakes Building This

### Mistake #1: Hardcoded External Drive Path

**Original shebang:**
```python
#!/Volumes/KaliPro/Applications/miniconda3/envs/ranger/bin/python
```

When the external drive wasn't mounted, the script wouldn't run at all.

**The fix:**
```python
#!/usr/bin/env python3
```

### Mistake #2: No Auto-Install for Dependencies

Users would clone the repo and immediately get:
```
ModuleNotFoundError: No module named 'colorama'
```

**The fix:** Auto-detect and offer to install:
```python
try:
    import colorama
except ImportError:
    print("colorama not found. Install now? (y/n)")
    if input().lower() == 'y':
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'colorama'])
```

### Mistake #3: No CLI Arguments

The original version was menu-only. To check emails, you had to:
1. Run the script
2. Select account
3. Navigate menu
4. Select "Check new emails"

Now it's just: `gmail --check`

---

## Security Notes

**NEVER commit your App Passwords to Git!**

The repo includes a `.env` file template, but your actual passwords should be:
1. In a local-only file
2. Added to `.gitignore`
3. Or use environment variables

```bash
# Example using environment variables
export GMAIL_PERSONAL_PASS="xxxx xxxx xxxx xxxx"
export GMAIL_WORK_PASS="yyyy yyyy yyyy yyyy"
```

---

## Usage Examples

### Morning Email Check

```bash
# Check all accounts at once
gmail --check-all

# Output:
# === personal@gmail.com ===
# 3 new emails
# === work@gmail.com ===
# 7 new emails
```

### Quick Send from Terminal

```bash
gmail --quick-send boss@company.com "Status Update" "The deployment completed successfully."
```

### Test All Connections

```bash
gmail --test

# Output:
# Testing personal@gmail.com... OK
# Testing work@gmail.com... OK
# All accounts connected successfully!
```

---

## Easter Egg

Try `gmail --bunny` for a colorful surprise!

---

## What I Learned

1. **Portable shebangs are essential** - Never hardcode paths to specific Python installations
2. **Auto-install improves UX dramatically** - Users shouldn't fight dependency errors
3. **CLI arguments > menu-only** - Power users want quick commands
4. **Security first** - Never commit credentials, even to "private" repos

---

## Download

**GitHub:** [gmail-multi-cli](https://github.com/davidtkeane/gmail-multi-cli)

**Direct Link:** [gmail_multi.py](https://github.com/davidtkeane/gmail-multi-cli/blob/main/gmail_multi.py)

**Version:** 3.0.0

---

Rangers lead the way!
