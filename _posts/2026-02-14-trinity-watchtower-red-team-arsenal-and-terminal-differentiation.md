---
layout: post
title: "Trinity Watchtower: Red Team Arsenal & Terminal Differentiation"
date: 2026-02-14 22:00:00 +0000
categories: [cybersecurity, penetration-testing, nci-assignment]
tags: [red-team, blue-team, metasploit, nmap, nikto, zsh, siem, elk-stack, trinity-watchtower]
author: David Keane
---

# Building a Complete Red Team Arsenal for NCI Cloud Security Assignment

Today was all about transforming my Trinity Watchtower SIEM into a full-scale penetration testing laboratory for my NCI Master's Cloud Architecture and Security assignment. The goal? Deploy a complete red team arsenal, conduct professional security assessments, and demonstrate defense-in-depth security principles.

## The Challenge

I needed to:
1. Deploy offensive security tools on my Contabo VPS (red team)
2. Test them against my AWS EC2 WordPress target
3. Verify that my OVH Bravo SIEM (blue team) detects the attacks
4. Manage multiple SSH sessions without getting confused
5. Document everything professionally for my NCI assignment

## The Infrastructure

**Trinity Watchtower Fleet:**
- **Mac M3 Pro** (100.118.23.119) - Command center
- **Contabo VPS** (100.103.164.7) - Red team attack platform
- **OVH Bravo** (100.77.2.103) - Blue team SIEM (ELK Stack 8.17.1)
- **AWS EC2** (100.119.131.76) - Target server (WordPress)

All connected via Tailscale VPN for secure private networking.

## Red Team Arsenal Deployment

I installed 7 essential penetration testing tools on Contabo:

```bash
# Network scanning
sudo apt install -y nmap tshark

# Web vulnerability scanning
sudo apt install -y nikto dirb

# Exploitation frameworks
sudo apt install -y metasploit-framework sqlmap

# Password cracking
sudo apt install -y hydra

# Wordlists
sudo mkdir -p /usr/share/wordlists
cd /usr/share/wordlists
sudo wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
# 134MB, 14.3 million passwords!
```

**Gotcha Alert:** Ubuntu doesn't have a "wordlists" package! You have to download rockyou.txt manually from GitHub.

## Terminal Differentiation with Zsh

Managing 4 different SSH sessions was confusing with identical bash prompts. Solution? Color-coded zsh prompts!

**Contabo Red Team (Attack Server):**
```bash
sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting
echo "PROMPT='%F{red}🔴 RED-TEAM%f %F{cyan}%~%f %F{red}➜%f '" >> ~/.zshrc
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
zsh
```

**OVH Bravo SIEM (Defense Server):**
```bash
sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting
echo "PROMPT='%F{blue}🔵 BLUE-SIEM%f %F{cyan}%~%f %F{blue}➜%f '" >> ~/.zshrc
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
zsh
```

**AWS EC2 Target (When I restart it):**
```bash
sudo yum install -y zsh  # Amazon Linux uses yum, not apt!
echo "PROMPT='%F{cyan}🎯 TARGET-AWS%f %F{cyan}%~%f %F{cyan}➜%f '" >> ~/.zshrc
zsh
```

Now my terminals look like this:
- 🎖️ **Mac**: `(base) 🎖️ COMMAND ~ ➜`
- 🔴 **Red Team**: `🔴 RED-TEAM ~ ➜`
- 🔵 **Blue Team**: `🔵 BLUE-SIEM ~ ➜`
- 🎯 **Target**: `🎯 TARGET-AWS ~ ➜`

**The zsh-autosuggestions plugin is AMAZING** - it shows ghost text of previous commands as you type, and you just press → (right arrow) to accept them. Huge time saver!

## Reconnaissance Phase

I ran three scans from Contabo against AWS:

**1. Service Version Scan:**
```bash
nmap -sV -Pn 100.119.131.76
```

**Results:**
```
PORT     STATE SERVICE  VERSION
22/tcp   open  ssh      OpenSSH 9.6 (protocol 2.0)
80/tcp   open  http     Apache httpd 2.4.62
443/tcp  open  ssl/http Apache httpd 2.4.62
3306/tcp open  mysql    MariaDB (unauthorized)
```

**2. Web Vulnerability Scan:**
```bash
nikto -h http://100.119.131.76
```

**Findings:**
- Strong security headers (X-Content-Type-Options, X-Frame-Options)
- ETag header reveals inode number (information disclosure)
- Server version disclosure (Apache 2.4.62)

**3. Stealth Scan (Low and Slow):**
```bash
nmap -sS -T2 -p- 100.119.131.76
# Took 401 seconds, but confirmed all 4 ports
```

## The Big Discovery: Layered Security

Port 3306 (MySQL) being open caught my attention. Time to verify with **Metasploit Framework**!

```bash
msfconsole -q

# Test MySQL version detection
msf6 > use auxiliary/scanner/mysql/mysql_version
msf6 auxiliary(scanner/mysql/mysql_version) > set RHOSTS 100.119.131.76
msf6 auxiliary(scanner/mysql/mysql_version) > set RPORT 3306
msf6 auxiliary(scanner/mysql/mysql_version) > run

[*] 100.119.131.76:3306 - Scanned 1 of 1 hosts (100% complete)

# Test database login
msf6 > use auxiliary/scanner/mysql/mysql_login
msf6 auxiliary(scanner/mysql/mysql_login) > set RHOSTS 100.119.131.76
msf6 auxiliary(scanner/mysql/mysql_login) > set USERNAME wordpress-user
msf6 auxiliary(scanner/mysql/mysql_login) > set PASSWORD <password>
msf6 auxiliary(scanner/mysql/mysql_login) > run

[-] 100.119.131.76:3306 - LOGIN FAILED: wordpress-user:<password>
    (Incorrect: Host '100.103.164.7' is not allowed to connect to this MariaDB server)
```

**This was BRILLIANT!** ✨

The error message revealed **defense-in-depth security**:
- ❌ **Vulnerability:** MySQL port 3306 exposed to network
- ✅ **Mitigation:** Host-based access control blocking external connections

This is **layered security** in action! Even though the port is exposed (which is a vulnerability), the database is still protected by application-layer access controls.

## Professional Security Analysis

I had two options:
1. Document the layered security as-is (professional approach)
2. Attempt to bypass the controls (script kiddie approach)

**I chose Option 1** - because this demonstrates:
- Systematic penetration testing methodology (reconnaissance → verification → exploitation)
- Understanding of defense-in-depth principles
- Ethical hacking practices (respect security controls)
- Real-world security analysis (multiple layers working together)

**Perfect for my NCI Master's assignment!** This shows mature security thinking, not just tool usage.

## The Filebeat Mystery

One problem remained: **Trinity Watchtower SIEM didn't detect the nikto scan!**

```bash
# Query Elasticsearch for nikto detection
curl -u elastic:RangerSecure2026 \
  "http://100.77.2.103:9200/filebeat-*/_search?q=user_agent.original:Nikto&size=10"

# Result: 0 hits
```

**Root Cause:** AWS Filebeat was running but not harvesting logs!

```bash
# Check Filebeat metrics
curl http://100.119.131.76:5066/stats | jq '.filebeat.harvester'

{
  "open_files": 0,
  "running": 0,
  "started": 0,
  "stopped": 0
}
```

**The Fix:** Added Apache log paths to `/etc/filebeat/filebeat.yml`:

```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/httpd/access_log
    - /var/log/httpd/error_log
    - /var/log/messages
    - /var/log/secure
```

After restarting Filebeat, the harvesters started! Still working on getting logs to actually flow to Elasticsearch though.

**Lesson learned:** Service running ≠ service working! Always check metrics.

## Cost Management: AWS Free Tier

After all this testing, I stopped my AWS EC2 instance to conserve free tier credits. Smart cloud architecture isn't just about security - it's also about cost optimization!

## What I Created Today

**Documentation (5 comprehensive guides):**
1. `RED-TEAM-SETUP.md` - Complete offensive security arsenal guide
2. `BLUE-TEAM-SETUP.md` - Defensive SIEM monitoring guide
3. `TERMINAL-SETUP.md` - Zsh terminal differentiation guide
4. `METASPLOIT-MYSQL-ATTACK.md` - MySQL verification attack guide
5. `NIKTO_SCAN_DETECTION_RESULTS.md` - Filebeat troubleshooting investigation
6. `CURRENT-STATUS.md` - Complete infrastructure status report

**Memory System:**
- 90+ operational memories saved to SQLite database
- 74 conversations archived in qBase JSON inverted-index
- 70,600+ searchable keywords

## Key Takeaways

1. **Terminal differentiation is essential** - Color-coded zsh prompts prevent confusion when managing multiple SSH sessions
2. **Zsh autosuggestions are a game-changer** - Ghost text command completion saves massive time
3. **Layered security works** - Port exposure doesn't automatically mean service compromise
4. **Professional methodology matters** - Document findings rather than forcing exploitation
5. **Verify, don't assume** - Just because a service is running doesn't mean it's working correctly
6. **Ubuntu uses apt, Amazon Linux uses yum** - Don't mix up your package managers!
7. **Cost optimization matters** - Stop instances when not in use to preserve free tier credits

## Next Steps

When I restart AWS for the next testing phase:
1. Complete zsh installation on AWS EC2
2. Fix Filebeat log shipping to Elasticsearch
3. Configure Kibana alerts for security events
4. Run additional penetration tests (dirb, sqlmap)
5. Verify Trinity Watchtower detects all attacks
6. Document complete attack → detection lifecycle for NCI assignment

## Tools Used

- **nmap** - Network scanning and service detection
- **nikto** - Web vulnerability scanning
- **Metasploit Framework** - Exploitation and verification
- **zsh** - Enhanced shell with autosuggestions
- **ELK Stack 8.17.1** - Elasticsearch, Logstash, Kibana SIEM
- **Filebeat** - Log shipping agent
- **Tailscale** - Private VPN mesh networking

## Final Thoughts

This assignment is teaching me that **professional cybersecurity isn't about breaking things** - it's about understanding how security controls work together, documenting findings systematically, and respecting the defenses you discover.

The Metasploit MySQL discovery was perfect: I found a vulnerability (exposed port), verified it with professional tools, discovered the mitigation (host-based access control), and documented the layered security approach. That's exactly what real penetration testers do.

**Trinity Watchtower is now a complete offensive/defensive security laboratory!** 🎖️

---

*Building secure cloud infrastructure, one layer at a time.*

**Rangers lead the way!** 🎖️
