---
layout: post
title: "Zsh Terminal Differentiation: Managing Multiple SSH Sessions Without Losing Your Mind"
date: 2026-02-14 18:00:00 +0000
categories: [linux, terminal, productivity]
tags: [zsh, ssh, terminal, autosuggestions, ubuntu, amazon-linux, devops, sysadmin]
author: David Keane
---

# Stop Getting Lost in Multiple SSH Sessions - Use Color-Coded Zsh Prompts!

## The Problem

Picture this: You're managing a cybersecurity lab with 4 different servers. You have terminal windows open for your red team attack server, blue team SIEM, target server, and your local Mac. They all have identical bash prompts:

```
ubuntu@vps-008e89ad:~$
ubuntu@vps-008e89ad:~$
ec2-user@ip-172-31-18-130:~$
(base) ➜  ~
```

**Which server am I on right now?** 🤔

You type `sudo rm -rf /var/log/*` and hit enter... then realize you just deleted logs on the WRONG SERVER. 😱

## The Solution: Color-Coded Zsh Prompts

I solved this problem by:
1. Installing **zsh** (Z shell) on all my servers
2. Adding **color-coded prompts** with emojis for instant visual identification
3. Enabling **zsh-autosuggestions** for ghost text command completion
4. Changing server **hostnames** to match their roles

Now my terminals look like this:

- 🎖️ **Mac Command Center**: `(base) 🎖️ COMMAND ~ ➜`
- 🔴 **Red Team Attack**: `🔴 RED-TEAM ~ ➜`
- 🔵 **Blue Team SIEM**: `🔵 BLUE-SIEM ~ ➜`
- 🎯 **Target Server**: `🎯 TARGET-AWS ~ ➜`

**Instant visual identification!** No more confusion, no more mistakes.

## What is Zsh?

**Zsh (Z Shell)** is an extended version of the Bourne Shell (bash) with tons of improvements:
- Better tab completion
- Command history sharing
- Spelling correction
- Theme and plugin support
- **Autosuggestions** - shows ghost text of previous commands as you type

It's the default shell on macOS (since Catalina), and it's perfect for power users managing multiple servers.

## Installation Guide

### Ubuntu Servers (Contabo, OVH, DigitalOcean, etc.)

```bash
# Update package list
sudo apt update

# Install zsh and plugins
sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting

# Verify installation
which zsh
# Output: /usr/bin/zsh

# Check version
zsh --version
# Output: zsh 5.9 (or similar)
```

### Amazon Linux (AWS EC2)

```bash
# Amazon Linux uses yum, not apt!
sudo yum install -y zsh

# Verify installation
which zsh
# Output: /usr/bin/zsh

# Note: zsh-autosuggestions and syntax-highlighting
# aren't in default repos, need manual installation (see below)
```

## Setting Up Color-Coded Prompts

### Red Team Attack Server (Contabo)

```bash
# Create .zshrc configuration
cat >> ~/.zshrc << 'EOF'
# Red Team Prompt Configuration
PROMPT='%F{red}🔴 RED-TEAM%f %F{cyan}%~%f %F{red}➜%f '

# Enable autosuggestions (Ubuntu only)
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable syntax highlighting (Ubuntu only)
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

# Switch to zsh
zsh
```

### Blue Team SIEM Server (OVH Bravo)

```bash
# Create .zshrc configuration
cat >> ~/.zshrc << 'EOF'
# Blue Team SIEM Prompt Configuration
PROMPT='%F{blue}🔵 BLUE-SIEM%f %F{cyan}%~%f %F{blue}➜%f '

# Enable autosuggestions (Ubuntu only)
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable syntax highlighting (Ubuntu only)
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

# Switch to zsh
zsh
```

### Target Server (AWS EC2)

```bash
# Create .zshrc configuration
cat >> ~/.zshrc << 'EOF'
# Target Server Prompt Configuration
PROMPT='%F{cyan}🎯 TARGET-AWS%f %F{cyan}%~%f %F{cyan}➜%f '
EOF

# Switch to zsh
zsh
```

## Understanding the Prompt Format

Let me break down the zsh prompt syntax:

```bash
PROMPT='%F{red}🔴 RED-TEAM%f %F{cyan}%~%f %F{red}➜%f '
```

- `%F{red}` - Start red color
- `🔴 RED-TEAM` - Emoji and text
- `%f` - End color (reset to default)
- `%F{cyan}` - Start cyan color
- `%~` - Current directory (with ~ for home)
- `%f` - End color
- `%F{red}➜%f` - Red arrow symbol
- Space at end - cursor position

**Available colors:**
- `red`, `green`, `blue`, `cyan`, `magenta`, `yellow`, `white`, `black`

**Useful prompt codes:**
- `%~` - Current directory (with ~ for home)
- `%/` - Full current directory path
- `%n` - Username
- `%m` - Hostname
- `%D` - Date
- `%T` - Time (24-hour format)

## The Magic of Zsh Autosuggestions 👻

This is the **killer feature** that makes zsh worth it!

As you type commands, zsh shows **ghost text** (greyed out) of previous commands you've run:

```bash
# You type: curl
# Zsh shows: curl http://100.77.2.103:9200/_cat/indices?v

# Press → (right arrow) to accept the suggestion!
```

**How it works:**
- Zsh remembers your command history
- As you type, it matches against previous commands
- Shows the completion in grey text
- Press **→ (right arrow)** to accept
- Press **→ End** to accept and move to end of line
- Keep typing to ignore the suggestion

**This saves SO MUCH TIME** when running repeated commands with long parameters!

## Changing Server Hostnames

Want your server's actual hostname to match the role? Here's how:

### Red Team Server (Contabo)

```bash
# Set new hostname
sudo hostnamectl set-hostname red-team

# Update /etc/hosts (replace old hostname)
sudo sed -i 's/vps-008e89ad/red-team/g' /etc/hosts

# Verify the change
hostnamectl

# Apply immediately without reboot
exec bash
zsh
```

### Blue Team SIEM (OVH)

```bash
# Set new hostname
sudo hostnamectl set-hostname blue-siem

# Update /etc/hosts
sudo sed -i 's/vps-e87f8afd/blue-siem/g' /etc/hosts

# Verify
hostnamectl

# Apply immediately
exec bash
zsh
```

### AWS EC2 Target

```bash
# Set new hostname
sudo hostnamectl set-hostname target-aws

# Update /etc/hosts
sudo sed -i 's/ip-172-31-18-130/target-aws/g' /etc/hosts

# Verify
hostnamectl

# Apply immediately
exec bash
zsh
```

Now when you SSH in, you'll see:
- `ubuntu@red-team:~$` (before zsh)
- `🔴 RED-TEAM ~ ➜` (after zsh)

## Making Zsh Your Default Shell

Want zsh to load automatically when you SSH in?

```bash
# Make zsh your default shell
chsh -s $(which zsh)

# Verify
echo $SHELL
# Output: /usr/bin/zsh

# Next login will automatically use zsh!
```

**Note:** You might need to log out and back in for this to take effect.

## Installing Zsh Autosuggestions on Amazon Linux (Manual Method)

Amazon Linux doesn't have zsh-autosuggestions in default repos. Here's how to install it manually:

```bash
# Clone the repository
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# Add to .zshrc
echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

# Reload configuration
source ~/.zshrc
```

## Bonus: Syntax Highlighting

**Zsh-syntax-highlighting** makes your commands colorful:
- ✅ Green = valid command
- ❌ Red = invalid command/typo
- 🔵 Blue = existing file/directory

```bash
# Ubuntu installation
sudo apt install -y zsh-syntax-highlighting
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

# Amazon Linux (manual)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
echo "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

# Reload
source ~/.zshrc
```

## Troubleshooting

### Problem: Colors not showing up

**Solution:** Make sure your terminal supports 256 colors:
```bash
echo $TERM
# Should show: xterm-256color or similar

# If not, add to .zshrc:
export TERM=xterm-256color
```

### Problem: Emojis showing as boxes

**Solution:** Your terminal needs Unicode support. Try:
- macOS Terminal: Works by default
- iTerm2: Works perfectly
- Windows Terminal: Works great
- PuTTY: Enable UTF-8 in settings

### Problem: Autosuggestions not working

**Solution:** Check if the plugin is loaded:
```bash
# Test if plugin exists
ls /usr/share/zsh-autosuggestions/

# If missing, reinstall
sudo apt install -y zsh-autosuggestions

# Make sure .zshrc has the source line
cat ~/.zshrc | grep autosuggestions
```

### Problem: "command not found" after switching to zsh

**Solution:** Your PATH might not be set correctly. Add to `~/.zshrc`:
```bash
# Set PATH
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

## My Complete .zshrc Configuration

Here's my production `.zshrc` for the red team server:

```bash
# Red Team Prompt Configuration
PROMPT='%F{red}🔴 RED-TEAM%f %F{cyan}%~%f %F{red}➜%f '

# Enable 256 colors
export TERM=xterm-256color

# Autosuggestions plugin
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting plugin
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Command history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Enable completion
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Aliases
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
```

## Before and After Comparison

**Before (all servers with bash):**
```
ubuntu@vps-008e89ad:~$
ubuntu@vps-e87f8afd:~$
ec2-user@ip-172-31-18-130:~$
(base) ➜  ~
```

**After (with color-coded zsh):**
```
🔴 RED-TEAM ~ ➜
🔵 BLUE-SIEM ~ ➜
🎯 TARGET-AWS ~ ➜
🎖️ COMMAND ~ ➜
```

## Key Takeaways

1. **Visual differentiation prevents mistakes** - Color-coded prompts with emojis make it instantly obvious which server you're on
2. **Zsh autosuggestions save massive time** - Ghost text completion of previous commands is a game-changer
3. **Ubuntu uses apt, Amazon Linux uses yum** - Don't mix up your package managers!
4. **Hostname changes require /etc/hosts update** - Don't forget to update both files
5. **Syntax highlighting catches typos** - See invalid commands in red before you run them
6. **Make it your default shell** - Use `chsh -s $(which zsh)` for automatic loading

## Use Cases

This setup is perfect for:
- 🔐 **Penetration testers** managing red team/blue team infrastructure
- ☁️ **DevOps engineers** managing multiple cloud servers
- 🛡️ **Security analysts** running SIEM and monitoring systems
- 💻 **System administrators** managing production/staging/development environments
- 🎓 **Students** working on cybersecurity assignments (like my NCI Master's!)

## Next Steps

After setting up zsh, you might want to explore:
- **Oh My Zsh** - Framework for managing zsh configuration (themes and plugins)
- **Powerlevel10k** - Advanced prompt theme with Git integration
- **Zsh-completions** - Additional command completions
- **Aliases** - Custom shortcuts for frequently-used commands

## Tools Used

- **zsh** - Z Shell (extended Bourne shell)
- **zsh-autosuggestions** - Ghost text command completion
- **zsh-syntax-highlighting** - Colorful command syntax
- **hostnamectl** - Systemd hostname control

## Final Thoughts

Terminal differentiation might seem like a small thing, but when you're managing multiple servers for cybersecurity testing, it's **essential for preventing mistakes**.

The combination of color-coded prompts, emojis, and zsh autosuggestions transforms terminal management from confusing to delightful. I can now glance at any terminal window and instantly know which server I'm on.

**Total setup time:** 5 minutes per server
**Mistakes prevented:** Countless
**Productivity boost:** Massive

If you manage more than 2 servers, **do yourself a favor and set this up today**. Your future self will thank you!

---

*Managing multiple servers doesn't have to be confusing.*

**Rangers lead the way!** 🎖️

## Quick Reference Card

| Server Type | Hostname | Prompt | Color | Emoji |
|------------|----------|---------|-------|-------|
| Command Center | command | `🎖️ COMMAND ~ ➜` | Default | 🎖️ |
| Red Team | red-team | `🔴 RED-TEAM ~ ➜` | Red | 🔴 |
| Blue Team | blue-siem | `🔵 BLUE-SIEM ~ ➜` | Blue | 🔵 |
| Target | target-aws | `🎯 TARGET-AWS ~ ➜` | Cyan | 🎯 |

**Ubuntu Install:** `sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting`
**Amazon Linux Install:** `sudo yum install -y zsh`
**Set Hostname:** `sudo hostnamectl set-hostname <name>`
**Make Default:** `chsh -s $(which zsh)`

Copy, paste, customize, and never get confused again! 🚀
