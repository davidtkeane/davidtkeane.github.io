---
layout: post
title: "Deploying Enterprise-Grade Cloudflare Security: A 6-Hour Journey"
date: 2026-02-14 01:00:00 +0000
categories: [cloud-security, infrastructure, networking]
tags: [cloudflare, dns, ssl-tls, ddos-protection, cdn, security, web-security, enterprise, trinity-architecture]
author: David Keane
---

## The Mission: Protecting davidtkeane.com with Enterprise Security

Today I deployed enterprise-grade security infrastructure for my entire domain using Cloudflare. What I thought would be a 30-minute DNS migration turned into a **6-hour odyssey** through the depths of domain management, nameserver delegation, and cloud security configuration.

The result? **$0/month enterprise infrastructure** protecting my Trinity Node architecture, NCI Cloud Security project, and personal domain with DDoS protection, WAF, global CDN, and TLS 1.3 encryption.

Here's the real story - challenges included.

---

## The Goal

**Protect these critical systems:**
- **davidtkeane.com** (main domain)
- **cloudsec.davidtkeane.com** (NCI MSc Cloud Security project - AWS EC2)
- **openclaw.davidtkeane.com** (Trinity Node Alpha - Contabo VPS)
- **Trinity Infrastructure** (Alpha, Bravo nodes for security research)

**What I needed:**
- ✅ DDoS protection (automatic mitigation)
- ✅ Web Application Firewall (WAF)
- ✅ SSL/TLS 1.3 encryption
- ✅ Global CDN (faster loading worldwide)
- ✅ Bot filtering and protection
- ✅ Hide origin server IPs (security through obscurity)

**Budget:** $0 (Cloudflare Free tier)

---

## The Challenge: 5 Hours in DNS Hell

### The Setup

I started confident. "Just add the domain to Cloudflare, change the nameservers, done in 30 minutes!"

**Famous last words.**

### The Problem

After adding davidtkeane.com to Cloudflare, I needed to change my nameservers from InMotion's servers to Cloudflare's:
- **Old:** `ns.inmotionhosting.com`, `ns2.inmotionhosting.com`
- **New:** `abby.ns.cloudflare.com`, `owen.ns.cloudflare.com`

Simple, right? **Find the DNS settings, change the nameservers, done.**

**Except I couldn't find the nameserver settings anywhere.**

### The 5-Hour Hunt

I spent **5 hours** searching through:
- ❌ cPanel → Zone Editor (only shows DNS records)
- ❌ cPanel → Domains section (no nameserver options)
- ❌ cPanel → DNS settings (just record management)
- ❌ InMotion documentation (vague references)
- ❌ Multiple support articles (unhelpful)

**My frustration level:** 📈📈📈

I kept finding the **Zone Editor** which showed:
- A records (points domain to IP)
- CNAME records (aliases)
- MX records (email)
- TXT records (verification)

**But NO nameserver settings!**

### The Breakthrough

After 5 hours, I discovered the critical distinction:

**cPanel manages DNS RECORDS. The REGISTRAR manages NAMESERVERS.**

These are **two completely different systems** in **two different panels**:

| System | Purpose | Location |
|--------|---------|----------|
| **cPanel Zone Editor** | DNS Records (A, CNAME, MX) | Hosting control panel |
| **Domain Registrar** | Nameserver Delegation | Account Management Panel |

**Where I finally found it:**
```
InMotion AMP (Account Management Panel)
  → Domains
    → Domain Management
      → davidtkeane.com
        → Delegation Details ← HERE!
```

**NOT in cPanel. In the registrar's management panel.**

---

## The Lesson: DNS Zone vs Nameserver Delegation

This is **crucial** for anyone working with domains:

### DNS Zone Editor (Hosting - cPanel)
**Purpose:** Manage DNS records
**Controls:** WHERE your domain points
**Records:**
- A record: domain → IP address
- CNAME: subdomain → another domain
- MX: email routing
- TXT: verification codes

**Example:** `cloudsec.davidtkeane.com` → `52.45.83.103` (AWS EC2)

### Nameserver Delegation (Registrar - AMP)
**Purpose:** Control WHO manages DNS
**Controls:** WHICH DNS system is authoritative
**Settings:**
- Primary nameserver
- Secondary nameserver

**Example:**
```
Old: ns.inmotionhosting.com (InMotion controls DNS)
New: abby.ns.cloudflare.com (Cloudflare controls DNS)
```

**Key insight:** Changing nameservers transfers DNS control from one provider (InMotion) to another (Cloudflare).

---

## The Solution: Complete Cloudflare Deployment

Once I found the nameserver settings, the rest took about **1 hour** to configure properly.

### Phase 1: DNS Migration ✅

**Steps:**
1. Added davidtkeane.com to Cloudflare
2. Cloudflare scanned existing DNS records (33 records found)
3. Added critical subdomains:
   - `cloudsec.davidtkeane.com` → `52.45.83.103` (AWS - NCI project)
   - `openclaw.davidtkeane.com` → `161.97.89.246` (Contabo Alpha)
4. Changed nameservers at InMotion AMP:
   - Primary: `abby.ns.cloudflare.com`
   - Secondary: `owen.ns.cloudflare.com`
5. Waited for propagation

**Expected:** 24-48 hours
**Actual:** ~30 minutes! 🚀

### Phase 2: SSL/TLS Configuration ✅

Configured enterprise-grade encryption:

**Encryption Mode:** Full (strict)
- Validates origin server certificates
- End-to-end encryption (visitor → Cloudflare → origin)
- Rejects self-signed certificates

**TLS Settings:**
- ✅ **TLS 1.3** enabled (latest protocol, faster handshakes)
- ✅ **Minimum TLS 1.2** (blocks outdated TLS 1.0/1.1)
- ✅ **Always Use HTTPS** (auto HTTP → HTTPS redirect)
- ✅ **Automatic HTTPS Rewrites** (fixes mixed content)
- ✅ **Opportunistic Encryption** (HTTP/2 performance boost)

**Free SSL Certificates:**
- Universal SSL issued for `*.davidtkeane.com`
- Backup certificate included
- Expires: May 15, 2026
- Auto-renewal: Enabled

**Result:** A+ SSL configuration (when tested with SSL Labs)

### Phase 3: Security Features ✅

Enabled comprehensive protection:

**Automatic Security:**
- Cloudflare's new "always protected" mode
- No manual Low/Medium/High selection needed
- Automatic threat detection and mitigation

**Bot Fight Mode:**
- JavaScript challenge detection
- Blocks automated bad bots
- Allows good bots (search engines, etc.)

**DDoS Protection (3 layers - always active):**
1. **HTTP DDoS Protection** - Application-layer attacks
2. **Network DDoS Protection** - ACK floods, SYN floods, UDP attacks
3. **SSL/TLS DDoS Protection** - Encryption-based attacks

**Additional Features:**
- Browser Integrity Check (evaluates HTTP headers)
- Challenge Passage (30-minute timeout)
- Rate limiting (available)
- IP access rules (configurable)

### Phase 4: Speed Optimizations ✅

Maximized performance with:

**Protocol Optimizations:**
- ✅ **HTTP/2** (multiplexing, header compression)
- ✅ **HTTP/3** (QUIC protocol, 0-RTT)
- ✅ **HTTP/2 to Origin** (faster origin connections)

**Content Optimizations:**
- ✅ **Speed Brain** (Beta - intelligent prefetching)
- ✅ **Rocket Loader** (JavaScript optimization)
- ✅ **Early Hints** (103 responses for preloading)
- ✅ **Cloudflare Fonts** (optimized font delivery)

**Result:** Global CDN caching with optimized delivery

---

## What Was Accomplished

### Infrastructure Protected

**All domains now behind Cloudflare edge network:**

```
BEFORE (Feb 13):
  Visitor → InMotion → Website (IP exposed: 213.165.242.8)
  - No DDoS protection
  - Single SSL certificate
  - No WAF
  - No CDN

AFTER (Feb 14):
  Visitor → Cloudflare Edge (Global Network)
           ↓
     [DDoS Protection + WAF + SSL/TLS + Bot Filter]
           ↓
     Cloudflare Proxy (Hides IPs)
           ↓
     Origin Servers (Protected):
     - InMotion (213.165.242.8) - Hidden
     - AWS EC2 (52.45.83.103) - Hidden
     - Contabo Alpha (161.97.89.246) - Hidden
```

**Real origin IPs now HIDDEN from attackers!** 🔒

### Security Layers

**Defense in Depth:**
1. **Edge Layer:** Cloudflare's global network (DDoS mitigation)
2. **Application Layer:** WAF (Web Application Firewall)
3. **Transport Layer:** TLS 1.3 encryption
4. **Network Layer:** Bot filtering and challenges
5. **Origin Layer:** Protected infrastructure (hidden IPs)

### Performance Gains

**Global CDN Benefits:**
- Static content cached at 330+ edge locations worldwide
- Faster loading for international visitors
- Reduced origin server load
- HTTP/3 (QUIC) for modern browsers
- Brotli compression for smaller transfers

### Cost

**Total monthly cost:** $0

**What you get for free:**
- Unlimited DDoS mitigation
- Universal SSL certificates
- Global CDN (50GB transfer/day)
- Web Application Firewall (basic rules)
- Bot Fight Mode
- DNS management (fast, secure)
- Analytics and monitoring

**Enterprise equivalent cost:** $200-500/month

---

## Real-World Value for NCI Cloud Security Project

This deployment is **perfect** for my NCI MSc Cloud Architecture & Security assignment:

### Demonstrates Professional Skills

**1. Defense in Depth**
- Multiple security layers (Cloudflare → Firewall → Infrastructure)
- Each layer provides different protection
- Redundancy if one layer fails

**2. SSL/TLS Hardening**
- TLS 1.3 (latest standard)
- Strong cipher suites
- Proper certificate validation

**3. DDoS Mitigation**
- Automatic detection
- Multi-layer protection
- No configuration needed

**4. Performance Optimization**
- CDN deployment
- HTTP/3 implementation
- Compression and minification

**5. Real-world Problem Solving**
- 6 hours of troubleshooting
- Nameserver delegation confusion
- Documentation of lessons learned

### Report Content Gold

**Perfect for assignment sections:**

**Challenges Section:**
> "Distinguishing between DNS zone management and nameserver delegation was critical. A 5-hour troubleshooting session revealed that cPanel Zone Editor manages DNS records while the registrar's Account Management Panel handles nameserver delegation - two separate systems often confused in practice."

**Findings & Risk Ratings:**
- BEFORE: Origin IP exposed (High risk)
- AFTER: Origin IP hidden via proxy (Risk mitigated)
- DDoS protection: Critical mitigation
- SSL/TLS: A+ configuration

**Tools & Methodologies:**
- Cloudflare (CDN/WAF/DDoS)
- DNS delegation strategy
- Multi-layer security approach

---

## Lessons Learned

### 1. DNS Architecture is Two Systems

**Never confuse these:**
- **DNS Records** (hosting) = WHERE domains point
- **Nameservers** (registrar) = WHO controls DNS

**They live in different panels!**

### 2. Documentation Matters

If InMotion's documentation had clearly stated:
> "To change nameservers, go to AMP → Domains → Delegation Details (NOT cPanel)"

I would have saved **5 hours** of frustration.

**Lesson:** When you solve a hard problem, document it clearly for others.

### 3. Free Doesn't Mean Inferior

Cloudflare's **free tier** provides:
- Enterprise-grade DDoS protection
- Global CDN with 330+ edge locations
- Unlimited SSL certificates
- Web Application Firewall
- Bot protection

**Many companies pay thousands for equivalent protection.**

### 4. Persistence Pays Off

**6 hours of work resulted in:**
- Protected infrastructure
- Valuable learning experience
- Professional-grade deployment
- Real-world problem-solving skills
- Content for NCI assignment

**Every hour of struggle was worth it.**

---

## The Final Architecture

### Protected Domains

| Domain | Purpose | Origin IP (Hidden) | Cloudflare Status |
|--------|---------|-------------------|-------------------|
| davidtkeane.com | Main site | 213.165.242.8 | ✅ Proxied |
| cloudsec.davidtkeane.com | NCI Project | 52.45.83.103 | ✅ Proxied |
| openclaw.davidtkeane.com | Trinity Alpha | 161.97.89.246 | ✅ Proxied |

### Security Features Active

- ✅ Automatic security (always protected)
- ✅ Bot Fight Mode (JS detection)
- ✅ DDoS protection (3 layers)
- ✅ WAF (Web Application Firewall)
- ✅ SSL/TLS 1.3 encryption
- ✅ Browser integrity checks
- ✅ Challenge system (30-min timeout)

### Performance Features Active

- ✅ HTTP/2 (multiplexing)
- ✅ HTTP/3 (QUIC)
- ✅ Global CDN (330+ locations)
- ✅ Speed Brain (prefetching)
- ✅ Rocket Loader (JS optimization)
- ✅ Brotli compression
- ✅ Early Hints (103 responses)

---

## Key Takeaways

### For Students & Developers

1. **Understand the difference** between DNS records and nameserver delegation
2. **Document your problems** - your 5-hour struggle might save someone 5 hours
3. **Free tools can be enterprise-grade** - don't dismiss them
4. **Real-world experience is messy** - embrace the struggle
5. **Persistence matters** - 6 hours of work = professional infrastructure

### For Cloud Security Projects

**Cloudflare demonstrates:**
- Defense in Depth (multiple security layers)
- Zero Trust principles (hide origin IPs)
- Performance + Security balance
- Cost-effective enterprise solutions
- Real-world deployment challenges

### For Infrastructure Engineers

**Production lessons:**
- Always separate concerns (DNS vs nameservers)
- Document your configuration changes
- Test before full deployment
- Understand propagation delays
- Plan for rollback scenarios

---

## What's Next?

### Trinity Node Deployment

Now that Cloudflare is protecting my infrastructure, I can deploy:

**Alpha (Ranger-SOC):** Contabo VPS 20
- ELK Stack (security monitoring)
- Centralized logging
- Threat detection

**Bravo (Ranger-Ops):** OVH VPS-2
- WordPress production
- OpenClaw AI gateway
- Public-facing services

**Charlie (Ranger-Lab):** Contabo VPS 10
- Security testing sandbox
- NCI lab environment
- Disposable experiments

**All protected by Cloudflare edge network!** 🛡️

### Future Enhancements

- [ ] Enable HSTS (after testing)
- [ ] Configure custom WAF rules
- [ ] Set up page rules for caching
- [ ] Deploy Workers (serverless functions)
- [ ] Configure rate limiting for wp-login
- [ ] Add Argo Smart Routing (if needed)

---

## Resources

### Official Documentation
- [Cloudflare DNS Documentation](https://developers.cloudflare.com/dns/)
- [SSL/TLS Encryption Modes](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
- [DDoS Protection](https://developers.cloudflare.com/ddos-protection/)
- [Speed Optimizations](https://developers.cloudflare.com/speed/)

### My Documentation
- `CLOUDFLARE-SETUP-GUIDE.md` - Complete setup guide
- `TODO_Cloud_Security_Project.md` - NCI project tracker
- `RANGER-TRINITY-NETWORK-INVENTORY.md` - Infrastructure inventory

### Tools Used
- Cloudflare Dashboard
- InMotion AMP (Account Management Panel)
- DNS propagation checker: [dnschecker.org](https://dnschecker.org/)
- SSL testing: [SSL Labs](https://www.ssllabs.com/ssltest/)

---

## Conclusion

**Time invested:** 6 hours (5 troubleshooting + 1 configuration)
**Value gained:** Priceless enterprise security
**Cost:** $0/month
**Lessons learned:** Invaluable

**Would I do it again?** Absolutely.

The 5-hour struggle with nameserver settings taught me more about DNS architecture than any tutorial could. The frustration turned into understanding, and the understanding turned into professional-grade infrastructure protecting my entire domain and Trinity Node architecture.

**For NCI students:** This is exactly the kind of real-world experience that makes your assignment stand out. Don't just follow tutorials - struggle, document, learn, and deploy real infrastructure.

**For developers:** Cloudflare's free tier is incredible. Use it.

**For security professionals:** This demonstrates defense in depth, zero trust principles, and cost-effective enterprise solutions.

---

**Final status:** Enterprise-grade security protecting davidtkeane.com and all subdomains for **$0/month**.

**Rangers lead the way!** 🎖️

---

*This deployment was completed as part of my NCI MSc in Cyber Security - Cloud Architecture and Security module. All infrastructure is production-grade and actively protecting my Trinity Node architecture, personal domain, and academic projects.*

*Special thanks to AIRanger (Claude Sonnet 4.5) for technical guidance and documentation support.*

**Cloudflare Account ID:** `ec37c39b5bb37d0a61c50ecdd7d35683`
**Deployment Date:** February 14, 2026
**Status:** ✅ Production - 100% Complete
