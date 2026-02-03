---
title: "RangerPlex Security Audit - How We Found and Fixed Critical Credential Exposure in a Public GitHub Repo"
date: 2026-02-01 01:00:00 +0000
categories: [Security, Development]
tags: [security-audit, git, credentials, api-keys, github, gitignore, gitleaks, bfg-repo-cleaner, pre-commit-hooks, cybersecurity, masters-thesis, rangerplex, lessons-learned]
pin: false
math: false
mermaid: false
---

## Overview

This is the story of how I accidentally committed credentials, API keys, real server IPs, and network topology maps to a **public** GitHub repository -- and how my AI assistant and I found them, fixed them, and built automated tooling so it never happens again. If you have ever pushed code to GitHub without thinking twice about what is in your config files, this post is for you.

This is not a theoretical exercise. These were real credentials. Real API keys. Real server IPs. On a public repo. For weeks.

Gladly, I am a nobody. Nobody had cloned the repo yet. But the lesson hit hard.

---

## Who Am I and Why Should You Care?

My name is David Keane. I am a 51-year-old Applied Psychology graduate from Dublin, Ireland, currently doing my Masters in Cybersecurity at the University of Galway (via NCI Dublin). I am dyslexic, ADHD, and autistic -- diagnosed at 39 -- and I have spent the last 14 years turning those diagnoses into superpowers.

I am building **RangerPlex**, an open-source cybersecurity platform that integrates penetration testing, blockchain networking, digital forensics, and malware analysis into a single tool. It is my Master's thesis project, and it is the most ambitious thing I have ever built.

I am also the kind of person who learns by doing. Which means I make mistakes. Spectacular ones. And then I write blog posts about them so you do not have to make the same ones.

Let me tell you about the day I nearly handed my Gmail password to the entire internet.

---

## The Setup: How We Got Here

RangerPlex is a big project. Over a thousand files across multiple modules. It has gone through dozens of iterations, late-night coding sessions, and "I will clean this up later" moments that stretched into weeks.

The repo structure looked something like this:

```
rangerplex-ai/
  rangerblock/
    core/           # Blockchain P2P networking
    lib/            # Shared libraries
    docs/           # Documentation
    homework/       # University assignment integrations
    malware-lab/    # Educational malware testing
  win95-retro/      # A retro Windows 95 themed web app
  config/           # Configuration files
  scripts/          # Utility scripts
```

I had been pushing updates regularly. New features, bug fixes, documentation. Standard development workflow. What I had not been doing was auditing what was actually in those commits.

That changed on a random Tuesday when I was doing a routine code review with my AI assistant (we call him Ranger -- long story, different blog post). We were running what I call the **Triple Audit Process**: a review pass, a sync check, and a security scan, all in parallel.

The security scan lit up like a Christmas tree.

---

## The Discovery: What We Found

### Finding 1: Gmail App Password in Plain Text

The first thing that jumped out was a file called `email-config.json` sitting in the config directory. Let me show you what was in it:

```json
{
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "email_address": "david.keane@gmail.com",
  "app_password": "abcd-efgh-ijkl-mnop",
  "recipient_default": "david.keane@gmail.com"
}
```

That `app_password` field? That was a real Gmail App Password. Not a placeholder. Not an example. The actual 16-character app-specific password that Google generates when you enable 2FA and need SMTP access.

For those who do not know: a Gmail App Password lets anyone send email as you, read your email via IMAP, and generally have a grand old time pretending to be you. It bypasses 2FA entirely -- that is the whole point of it.

And it had been sitting in a public GitHub repo for weeks.

**My reaction**: A string of words that would make a drill sergeant blush, followed by a very quiet "oh no."

### Finding 2: Google Gemini API Key in a Compiled JavaScript Bundle

This one was sneaky. I had built a retro Windows 95 themed web application as a fun side project within RangerPlex. It used Google's Gemini AI API for some chat functionality. During development, I had hardcoded the API key directly in the source code -- "just for testing," I told myself.

The problem? When you build a JavaScript application with a bundler like Webpack or Vite, it compiles all your source code into minified bundle files. And those bundle files faithfully include every hardcoded string in your source code. Including API keys.

```javascript
// Somewhere in a 200KB minified bundle file:
// ...t="AIzaSyB-FAKE-KEY-EXAMPLE-1234567890"...
```

The key was buried in a minified `.js` file inside the `dist/` folder. You would not see it scrolling through the code. You would not notice it in a code review unless you specifically searched for it. But anyone who ran `grep -r "AIzaSy" .` would find it instantly.

And yes, `AIzaSy` is the well-known prefix for Google API keys. Every automated scanner on the internet knows to look for that string.

**How much damage could this do?** Gemini API calls cost money. Someone could rack up thousands in charges on my Google Cloud account. They could also use the key to access any other Google Cloud services enabled on that project.

### Finding 3: Real Server IPs Scattered Everywhere

This one was a slow-burn discovery. As we dug deeper into the codebase, we found real IP addresses scattered across multiple files:

- **AWS EC2 instance IPs** in deployment scripts
- **Google Cloud VM IPs** in configuration files
- **Local network IPs** (192.168.x.x) in P2P networking test files
- **Docker bridge IPs** in container configuration

Here is an example of what we found in a machine registry file:

```json
{
  "machines": {
    "m3-pro": {
      "hostname": "Rangers-MacBook-Pro",
      "ip": "192.168.1.42",
      "role": "primary-node"
    },
    "m4-max": {
      "hostname": "Rangers-MacBook-Pro-M4",
      "ip": "192.168.1.43",
      "role": "compute-node"
    },
    "msi-vector": {
      "hostname": "MSI-VECTOR-16",
      "ip": "192.168.1.44",
      "role": "gpu-node"
    },
    "aws-prod": {
      "hostname": "rangerplex-prod",
      "ip": "54.XXX.XXX.XXX",
      "role": "production"
    }
  }
}
```

That is a complete network topology map. Every machine on my home network, their roles, their IPs, and my cloud server addresses. Handed to anyone who cared to look.

**Why this matters:** Even "just" LAN IPs are dangerous in context. Combined with the public IPs, an attacker could map my entire infrastructure. The cloud IPs are directly attackable. And the machine roles tell them exactly where to focus.

### Finding 4: The Full Picture

When we tallied everything up, here is what was exposed:

| Category | What Was Exposed | Risk Level |
|----------|-----------------|------------|
| Gmail App Password | Full SMTP access to personal email | **CRITICAL** |
| Gemini API Key | Google Cloud API access, billing | **HIGH** |
| AWS Server IP | Direct attack surface | **HIGH** |
| Google Cloud IP | Direct attack surface | **HIGH** |
| LAN Topology | Complete home network map | **MEDIUM** |
| Machine Registry | Hardware inventory + roles | **MEDIUM** |
| Docker Config | Container networking details | **LOW** |

I sat back in my chair and just stared at the screen for a good five minutes.

---

## The "Gladly I Am a Nobody" Moment

Here is the thing that saved me: nobody cares about my repo.

I checked the GitHub traffic stats. Zero clones. A handful of views, mostly from me checking the README on my phone. No forks. No stars from strangers.

If I were a company, or a popular open-source project, or anyone with more than three followers on GitHub, this could have been catastrophic. Automated bots scan GitHub for exposed credentials constantly. There are entire databases of leaked API keys scraped from public repos.

But I am a 51-year-old Masters student in Dublin with a repo that has about as much traffic as a country road in Connemara at 3 AM. So the damage was: none. The lesson was: enormous.

**Do not rely on being a nobody.** Fix your security properly. Because one day you might not be a nobody, and by then the habits need to already be in place.

---

## The Fix: Step by Step

Right. Enough wallowing. Time to fix things. Here is exactly what we did, in order, with the actual commands.

### Step 1: Stop the Bleeding -- Revoke Everything

Before touching a single file in the repo, we revoked every exposed credential:

**Gmail App Password:**
1. Go to [myaccount.google.com](https://myaccount.google.com)
2. Security > 2-Step Verification > App passwords
3. Revoke the compromised app password
4. Generate a new one (and this time, do NOT put it in a file that gets committed)

**Gemini API Key:**
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. APIs & Services > Credentials
3. Delete the compromised API key
4. Create a new one with proper restrictions (HTTP referrer restrictions, API restrictions)

**Why revoke first?** Because even after you remove the credentials from your repo, they are still in the git history. Anyone who has already cloned the repo (or cached it) still has them. The credentials themselves are compromised the moment they hit a public repo. You must assume they have been seen.

This is the single most important step and the one most people skip. They delete the file, push a new commit, and think they are safe. They are not.

### Step 2: Remove Files from Git Tracking

Here is where most people learn a painful lesson about `.gitignore`. Adding a file to `.gitignore` does **NOT** remove it from git tracking if it has already been committed. It only prevents future changes from being tracked.

Let me say that again because it is important:

> **.gitignore only prevents FUTURE commits. It does NOT remove already-tracked files.**

To actually stop tracking a file that has already been committed, you need `git rm --cached`:

```bash
# Remove the email config from git tracking (keeps the local file)
git rm --cached config/email-config.json

# Remove compiled bundles that contain the API key
git rm --cached -r win95-retro/dist/

# Remove machine registry
git rm --cached config/machine-registry.json
```

The `--cached` flag is critical here. Without it, `git rm` deletes the file from your filesystem too. With `--cached`, it only removes it from git's tracking -- the file stays on your local machine.

After removing them from tracking, update your `.gitignore`:

```gitignore
# Credentials and secrets -- NEVER commit these
config/email-config.json
config/machine-registry.json
*.env
.env.*
credentials.json
**/secrets/

# Build output that may contain embedded secrets
**/dist/
**/build/
**/*.bundle.js
**/*.min.js

# IDE and OS files
.DS_Store
.vscode/settings.json
*.swp
```

Then commit the removal:

```bash
git add .gitignore
git commit -m "security: remove tracked credentials and update .gitignore"
git push origin main
```

### Step 3: Redact IPs with DNS Hostnames and Environment Variables

For the IP addresses scattered across the codebase, we took a two-pronged approach:

**For configuration files -- use environment variables:**

Before (dangerous):
```json
{
  "aws_host": "54.123.45.67",
  "gcloud_host": "35.234.56.78"
}
```

After (safe):
```json
{
  "aws_host": "${RANGERPLEX_AWS_HOST}",
  "gcloud_host": "${RANGERPLEX_GCLOUD_HOST}"
}
```

With a `.env` file (NOT committed to git):
```bash
# .env -- DO NOT COMMIT THIS FILE
RANGERPLEX_AWS_HOST=54.123.45.67
RANGERPLEX_GCLOUD_HOST=35.234.56.78
RANGERPLEX_SMTP_PASS=your-app-password-here
RANGERPLEX_GEMINI_KEY=your-api-key-here
```

**For P2P networking code -- use DNS hostnames:**

Before:
```javascript
const BOOTSTRAP_NODES = [
  "192.168.1.42:5555",
  "192.168.1.43:5555",
  "54.123.45.67:5555"
];
```

After:
```javascript
const BOOTSTRAP_NODES = [
  process.env.RANGER_NODE_PRIMARY || "localhost:5555",
  process.env.RANGER_NODE_COMPUTE || "localhost:5556",
  process.env.RANGER_NODE_CLOUD || "localhost:5557"
];
```

**For documentation and examples -- use RFC 5737 reserved IPs:**

If you need example IPs in documentation, use the IPs that are officially reserved for documentation purposes:

```
192.0.2.0/24     (TEST-NET-1)
198.51.100.0/24  (TEST-NET-2)
203.0.113.0/24   (TEST-NET-3)
```

These will never route to real machines. They exist specifically for examples and documentation.

### Step 4: Add Content Security Policy Headers

Since one of our exposed keys was in a web application, we also added proper CSP headers to prevent accidental data leakage:

```javascript
// In your Express.js server or static file server config
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; " +
    "script-src 'self'; " +
    "connect-src 'self' https://generativelanguage.googleapis.com; " +
    "style-src 'self' 'unsafe-inline';"
  );
  next();
});
```

This ensures that even if a key were accidentally included in client-side code, the browser would restrict which domains the application can communicate with.

### Step 5: The Nuclear Option -- Purging Git History

Here is the uncomfortable truth: even after Steps 2-4, the credentials are still in your git history. Anyone can run:

```bash
git log --all --full-history -- config/email-config.json
git show <commit-hash>:config/email-config.json
```

And there is your password, right there in the commit history. Forever. Unless you rewrite history.

**Enter BFG Repo-Cleaner.**

[BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) is the tool specifically designed for this job. It is faster and simpler than `git filter-branch` and it will not accidentally destroy your repo (well, less likely to anyway).

Here is how to use it:

```bash
# First, make a fresh clone (mirror clone for full history)
git clone --mirror git@github.com:yourusername/rangerplex-ai.git

# Download BFG (requires Java)
# On macOS with Homebrew:
~/brew-helper.sh install bfg

# Create a file listing the strings to remove
cat > passwords.txt << 'EOF'
abcd-efgh-ijkl-mnop
AIzaSyB-YOUR-ACTUAL-KEY-HERE
54.123.45.67
35.234.56.78
EOF

# Run BFG to replace those strings with ***REMOVED***
bfg --replace-text passwords.txt rangerplex-ai.git

# Clean up the repo
cd rangerplex-ai.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Push the rewritten history
git push --force
```

**WARNING**: `git push --force` rewrites history for everyone. If anyone has cloned your repo, their clone will be out of sync. For a personal project with no collaborators, this is fine. For a team project, coordinate with your team first.

**ALSO WARNING**: This is a destructive operation. Make a backup before running it. I mean it. Do not skip this step. I learned this the hard way on a different project years ago and I still get a cold sweat thinking about it.

```bash
# BACKUP FIRST. I am not joking.
cp -r rangerplex-ai.git rangerplex-ai.git.backup
```

---

## Building the Ranger Security Scanner: A Pre-Commit Hook

After cleaning up the mess, I decided that relying on "I will remember not to commit secrets" was about as reliable as Irish weather forecasts. We needed automation.

So we built a pre-commit hook that scans every commit for potential secrets before they ever reach the repository.

### What Is a Pre-Commit Hook?

Git hooks are scripts that run automatically at certain points in the git workflow. A **pre-commit hook** runs before every commit. If the script exits with a non-zero code, the commit is blocked.

They live in `.git/hooks/pre-commit` in your repository.

### The Ranger Security Scanner

Here is the scanner we built. It checks for common credential patterns, IP addresses, and known secret formats:

```bash
#!/bin/bash
# .git/hooks/pre-commit
# Ranger Security Scanner v1.0
# Scans staged files for potential credential exposure

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo ""
echo -e "${BOLD}=====================================${NC}"
echo -e "${BOLD}  RANGER SECURITY SCANNER v1.0${NC}"
echo -e "${BOLD}=====================================${NC}"
echo ""

ISSUES_FOUND=0
WARNINGS_FOUND=0

# Get list of staged files (excluding deleted files)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}No staged files to scan.${NC}"
    exit 0
fi

echo -e "Scanning $(echo "$STAGED_FILES" | wc -l | tr -d ' ') staged files..."
echo ""

# Function to check for pattern in staged files
check_pattern() {
    local pattern="$1"
    local description="$2"
    local severity="$3"  # CRITICAL, HIGH, MEDIUM

    for file in $STAGED_FILES; do
        # Skip binary files
        if file "$file" | grep -q "binary"; then
            continue
        fi

        # Search staged content (not working directory)
        local matches=$(git show ":$file" 2>/dev/null | grep -nE "$pattern" 2>/dev/null)

        if [ ! -z "$matches" ]; then
            if [ "$severity" = "CRITICAL" ] || [ "$severity" = "HIGH" ]; then
                echo -e "${RED}[$severity] $description${NC}"
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            else
                echo -e "${YELLOW}[$severity] $description${NC}"
                WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
            fi
            echo -e "  File: ${BOLD}$file${NC}"
            echo "$matches" | head -3 | while read line; do
                echo "  $line"
            done
            echo ""
        fi
    done
}

# ============================================
# CRITICAL: Known credential patterns
# ============================================

# Google API Keys (always start with AIzaSy)
check_pattern 'AIzaSy[0-9A-Za-z_-]{33}' \
    "Google API Key detected" "CRITICAL"

# AWS Access Keys
check_pattern 'AKIA[0-9A-Z]{16}' \
    "AWS Access Key ID detected" "CRITICAL"

# AWS Secret Keys
check_pattern '[0-9a-zA-Z/+]{40}' \
    "Possible AWS Secret Access Key" "MEDIUM"

# Generic API keys and tokens
check_pattern '(api_key|apikey|api-key|secret_key|secret-key|access_token)\s*[:=]\s*["\x27][^\s"'\'']{8,}' \
    "API key or secret assignment detected" "HIGH"

# Gmail App Passwords (4 groups of 4 lowercase letters)
check_pattern '[a-z]{4}-[a-z]{4}-[a-z]{4}-[a-z]{4}' \
    "Possible Gmail App Password pattern" "HIGH"

# Private keys
check_pattern 'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY' \
    "Private key detected" "CRITICAL"

# Generic passwords in config
check_pattern '(password|passwd|pwd)\s*[:=]\s*["\x27][^\s"'\'']{4,}' \
    "Password assignment detected" "CRITICAL"

# Connection strings with credentials
check_pattern '(mysql|postgres|mongodb|redis)://[^:]+:[^@]+@' \
    "Database connection string with credentials" "CRITICAL"

# JWT tokens
check_pattern 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}' \
    "JWT token detected" "HIGH"

# Slack tokens
check_pattern 'xox[baprs]-[0-9A-Za-z-]+' \
    "Slack token detected" "CRITICAL"

# GitHub tokens
check_pattern 'gh[pousr]_[A-Za-z0-9_]{36,}' \
    "GitHub token detected" "CRITICAL"

# ============================================
# HIGH: IP Addresses (non-reserved)
# ============================================

# Public IPv4 addresses (excluding common safe ranges)
check_pattern '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
    "IP address detected (verify it is not a real server)" "MEDIUM"

# ============================================
# MEDIUM: Other sensitive patterns
# ============================================

# Email addresses (might indicate personal info exposure)
check_pattern '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
    "Email address detected" "MEDIUM"

# ============================================
# RESULTS
# ============================================

echo -e "${BOLD}=====================================${NC}"
echo -e "${BOLD}  SCAN RESULTS${NC}"
echo -e "${BOLD}=====================================${NC}"

if [ $ISSUES_FOUND -gt 0 ]; then
    echo ""
    echo -e "${RED}BLOCKED: $ISSUES_FOUND critical/high issue(s) found.${NC}"
    echo -e "${RED}Commit has been prevented.${NC}"
    echo ""
    echo -e "To fix:"
    echo -e "  1. Remove or redact the flagged content"
    echo -e "  2. Use environment variables or .env files instead"
    echo -e "  3. Run: git add <fixed-files>"
    echo -e "  4. Try committing again"
    echo ""
    echo -e "To bypass (NOT RECOMMENDED):"
    echo -e "  git commit --no-verify"
    echo ""
    exit 1
elif [ $WARNINGS_FOUND -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}WARNING: $WARNINGS_FOUND potential issue(s) found.${NC}"
    echo -e "${GREEN}Commit allowed, but please review the warnings above.${NC}"
    echo ""
    exit 0
else
    echo ""
    echo -e "${GREEN}ALL CLEAR: No security issues detected.${NC}"
    echo ""
    exit 0
fi
```

### Installing the Hook

```bash
# Copy the script to your hooks directory
cp ranger-security-scanner.sh .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit

# Test it
echo 'password = "supersecret123"' > test-secret.txt
git add test-secret.txt
git commit -m "test"
# Should be BLOCKED by the scanner

# Clean up
git reset HEAD test-secret.txt
rm test-secret.txt
```

### Making It Portable Across Clones

The `.git/hooks/` directory is not committed to the repository (it is inside `.git/`, which is not tracked). To share hooks with your team or across clones, use one of these approaches:

**Option A: Custom hooks directory in the repo**

```bash
# Create a hooks directory in your project
mkdir -p .githooks

# Move your hook there
cp .git/hooks/pre-commit .githooks/pre-commit

# Tell git to use it
git config core.hooksPath .githooks

# Commit the hooks directory
git add .githooks/
git commit -m "feat: add Ranger Security Scanner pre-commit hook"
```

**Option B: Use a hooks framework like pre-commit**

```bash
# Install pre-commit framework
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
EOF

# Install the hooks
pre-commit install
```

---

## The Triple Audit Process

Let me explain the workflow that caught these issues. We call it the **Triple Audit** because it runs three checks in parallel:

### 1. Code Review Pass

A manual (or AI-assisted) review of recent changes. This is where you look at diffs, read through new files, and ask "does anything here look like it should not be public?"

```bash
# Review all changes since last audit
git log --oneline --since="1 week ago"
git diff HEAD~10..HEAD --stat

# Look at the actual content of changed files
git diff HEAD~10..HEAD -- '*.json' '*.js' '*.env*' '*.config*'
```

### 2. Sync Check

Verify that your local `.gitignore` matches what is actually being tracked. This catches the "I added it to .gitignore but forgot to untrack it" problem:

```bash
# Find tracked files that SHOULD be ignored
git ls-files -i --exclude-standard

# Find files that match common secret patterns but are tracked
git ls-files | grep -iE '(secret|password|credential|\.env|config\.json)'
```

### 3. Automated Security Scan

Run tools that scan for known credential patterns:

```bash
# Using gitleaks (install: brew install gitleaks or ~/brew-helper.sh install gitleaks)
gitleaks detect --source . --verbose

# Scan specific commits
gitleaks detect --source . --log-opts="HEAD~10..HEAD" --verbose

# Generate a report
gitleaks detect --source . --report-format json --report-path gitleaks-report.json
```

**Run all three in parallel.** Do not skip any of them. The code review catches context-specific issues that automated tools miss. The sync check catches configuration problems. The automated scan catches patterns that human eyes overlook.

---

## Using Gitleaks: The Industry Standard

[Gitleaks](https://github.com/gitleaks/gitleaks) is the go-to tool for detecting secrets in git repositories. Here is how to set it up and use it effectively:

### Installation

```bash
# macOS (using David's brew helper)
~/brew-helper.sh install gitleaks

# Or with Go
go install github.com/zricethezav/gitleaks/v8@latest

# Or download binary from GitHub releases
# https://github.com/gitleaks/gitleaks/releases
```

### Basic Usage

```bash
# Scan entire repo history
gitleaks detect --source /path/to/repo --verbose

# Scan only staged changes (great for CI/CD)
gitleaks protect --source /path/to/repo --staged --verbose

# Scan specific commit range
gitleaks detect --source /path/to/repo --log-opts="abc123..def456"

# Output as JSON for processing
gitleaks detect --source /path/to/repo --report-format json --report-path results.json
```

### Custom Rules

You can extend gitleaks with custom rules for project-specific patterns. Create a `.gitleaks.toml` file:

```toml
# .gitleaks.toml
title = "RangerPlex Custom Rules"

# Custom rule for RangerBlock wallet keys
[[rules]]
id = "rangerblock-wallet-key"
description = "RangerBlock Phantom Wallet Key"
regex = '''ranger_wallet_[a-f0-9]{64}'''
tags = ["key", "rangerblock"]

# Custom rule for internal hostnames
[[rules]]
id = "internal-hostname"
description = "Internal network hostname"
regex = '''Rangers-MacBook-Pro(-M4)?\.local'''
tags = ["network", "internal"]

# Allow list for false positives
[allowlist]
description = "Global allow list"
paths = [
    '''test/.*''',
    '''docs/examples/.*''',
]
regexes = [
    '''192\.0\.2\.\d+''',     # TEST-NET-1 (documentation IPs)
    '''198\.51\.100\.\d+''',  # TEST-NET-2
    '''203\.0\.113\.\d+''',   # TEST-NET-3
]
```

### Integrating Gitleaks into CI/CD

Add this to your GitHub Actions workflow:

```yaml
# .github/workflows/security-scan.yml
name: Security Scan
on: [push, pull_request]

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This runs on every push and pull request. If secrets are detected, the pipeline fails and the PR cannot be merged.

---

## My Mistakes and What I Should Have Done

Right. Time for the honest bit. Here is where I went wrong and what I should have done from the start. I am writing this partly for you and partly so I can read it again the next time I am tempted to take shortcuts.

### Mistake 1: "I Will Clean This Up Later"

**What I did:** Hardcoded credentials during development with the intention of moving them to environment variables "later."

**Why it happened:** It was 2 AM. The feature was nearly working. I just needed to test the email sending. The `.env` file approach would take an extra 10 minutes to set up properly. "I will fix it tomorrow."

Tomorrow turned into next week. Next week turned into "oh look, I pushed it to GitHub three weeks ago."

**What I should have done:** Set up the `.env` file structure on day one of the project. Before writing a single line of feature code. It takes 10 minutes. Ten. Minutes.

```bash
# Day one of any project:
touch .env .env.example
echo ".env" >> .gitignore
echo "# Copy this to .env and fill in your values" > .env.example
echo "API_KEY=your-key-here" >> .env.example
echo "SMTP_PASSWORD=your-password-here" >> .env.example
```

### Mistake 2: Not Auditing Build Output

**What I did:** Added `dist/` to the repo because "it makes deployment easier."

**Why it happened:** I wanted to be able to clone the repo and immediately have a working build without running the build step. Lazy deployment.

**What I should have done:** Never commit build artifacts. Use CI/CD to build, or at minimum, use GitHub Releases for distributing built files. The `dist/` folder should always be in `.gitignore`.

```gitignore
# Build output -- NEVER commit these
dist/
build/
out/
*.bundle.js
*.min.js
```

If you need easy deployment, use GitHub Actions to build and deploy automatically. Or use GitHub Releases to attach build artifacts to tagged versions.

### Mistake 3: Treating .gitignore as Set-and-Forget

**What I did:** Created a basic `.gitignore` at the start of the project and never updated it as the project grew.

**Why it happened:** I set up the initial `.gitignore` with standard patterns (node_modules, .DS_Store, etc.) and then forgot about it. As I added new config files and tools, I never thought to update the ignore patterns.

**What I should have done:** Review `.gitignore` every time you add a new category of file to your project. Adding email functionality? Update `.gitignore`. Adding API integrations? Update `.gitignore`. Adding deployment configs? You guessed it.

### Mistake 4: No Pre-Commit Checks

**What I did:** Relied entirely on my own memory and attention to avoid committing secrets.

**Why it happened:** I am human. Humans forget things. Especially humans with ADHD who are hyperfocused on getting a feature working at 2 AM.

**What I should have done:** Install a pre-commit hook on day one. Automated checks do not get tired. They do not get distracted. They do not think "I will fix it later." They just check. Every. Single. Time.

### Mistake 5: Not Understanding Compiled Output

**What I did:** Assumed that because the API key was in my source code, it would only be in my source code files.

**Why it happened:** I genuinely did not think about the fact that bundlers include everything from source into the compiled output. The key was in `src/api.js`. I did not think about `dist/bundle.js`.

**What I should have done:** Understood the build pipeline. If a secret is in your source code, it is in your build output. Full stop. Never hardcode secrets in source files that get compiled into client-side bundles. Use a server-side proxy instead:

```javascript
// BAD: API key in client-side code
const response = await fetch(
  `https://api.google.com/v1/endpoint?key=${API_KEY}`
);

// GOOD: Call your own server, which has the key
const response = await fetch('/api/proxy/google-endpoint');

// Your server-side code (not shipped to client):
app.get('/api/proxy/google-endpoint', (req, res) => {
  const data = await fetch(
    `https://api.google.com/v1/endpoint?key=${process.env.GOOGLE_API_KEY}`
  );
  res.json(await data.json());
});
```

### Mistake 6: Not Running Gitleaks From the Start

**What I did:** Discovered gitleaks after the damage was done.

**Why it happened:** I did not know it existed. I was focused on building features, not on operational security.

**What I should have done:** Five minutes of research at the start of any project that touches credentials, APIs, or infrastructure. That is all it takes. Install gitleaks. Set up the pre-commit hook. Move on with your life.

---

## The Complete Remediation Checklist

If you are reading this because you just found credentials in your own public repo, here is the full checklist. Print it out. Tape it to your monitor. Follow every step.

### Immediate Actions (Do These RIGHT NOW)

- [ ] **Revoke all exposed credentials** (passwords, API keys, tokens)
- [ ] **Generate new credentials** with proper restrictions
- [ ] **Check for unauthorized access** (API usage logs, email sent, etc.)
- [ ] **Enable alerts** on all exposed services (unusual login attempts, API usage spikes)

### Repository Cleanup

- [ ] `git rm --cached` all sensitive files
- [ ] Update `.gitignore` with comprehensive patterns
- [ ] Replace hardcoded values with environment variables
- [ ] Create `.env.example` with placeholder values
- [ ] Run `git ls-files -i --exclude-standard` to verify nothing slips through
- [ ] Run gitleaks to scan current state

### History Purge

- [ ] Back up your repository (seriously, do it)
- [ ] Use BFG Repo-Cleaner to purge secrets from history
- [ ] Run `git reflog expire` and `git gc` to clean up
- [ ] Force push the cleaned history
- [ ] Verify with gitleaks on full history

### Prevention

- [ ] Install pre-commit hook (Ranger Security Scanner or gitleaks)
- [ ] Set up CI/CD security scanning (GitHub Actions)
- [ ] Create `.gitleaks.toml` with project-specific rules
- [ ] Document credential management in project README
- [ ] Schedule regular security audits (weekly or per-sprint)

---

## The Psychology of Security Mistakes

Here is where my Applied Psychology background kicks in. There is a reason developers keep making these mistakes, and it is not because we are stupid. It is because of how human cognition works under pressure.

### Cognitive Load Theory

When you are deep in a coding session, your working memory is maxed out. You are holding the feature logic, the API structure, the data flow, and a dozen other things in your head simultaneously. Adding "check for secrets before committing" to that cognitive load is genuinely difficult.

**Solution:** Remove it from cognitive load entirely. Automate it. Pre-commit hooks do not require working memory. They just run.

### Present Bias

Humans systematically overvalue immediate rewards (getting the feature working NOW) and undervalue future costs (security breach LATER). This is not a character flaw -- it is how our brains are wired.

**Solution:** Make the secure path the easy path. If setting up `.env` files is part of your project template, it costs zero extra effort. If the pre-commit hook blocks bad commits automatically, you never have to think about it.

### The Dunning-Kruger Effect in Security

Early in a project, you do not know what you do not know about security. You think "I am careful, I will not commit secrets." This is not arrogance -- it is a genuine lack of experience with how these incidents actually happen.

**Solution:** Learn from others' mistakes (like mine, right now, in this blog post). And set up automated protections regardless of how careful you think you are.

### Normalcy Bias

"It won't happen to me. I am a small project. Nobody is looking at my repo." This is normalcy bias -- the tendency to believe that because something bad has not happened yet, it will not happen in the future.

**Solution:** Assume the worst. Automated bots do not care how small your project is. They scan every public repo on GitHub. Every single one.

---

## Summary of Tools Mentioned

| Tool | Purpose | Install |
|------|---------|---------|
| **gitleaks** | Scan repos for secrets | `brew install gitleaks` |
| **BFG Repo-Cleaner** | Purge secrets from git history | `brew install bfg` |
| **pre-commit** | Framework for git pre-commit hooks | `pip install pre-commit` |
| **Ranger Security Scanner** | Custom pre-commit hook (above) | Copy to `.git/hooks/pre-commit` |
| **GitHub Actions** | CI/CD security scanning | Add workflow YAML |
| **git rm --cached** | Remove files from tracking (built-in) | Part of git |

---

## The Real Takeaway

Here is what I want you to walk away with:

1. **Everyone makes this mistake.** Major companies, experienced developers, security professionals. If you have committed a secret to git, you are in very large company. The difference is what you do about it.

2. **Automation is your friend.** Your brain is for creative problem-solving, not for remembering to check every commit for secrets. Let the machines handle the repetitive security checks.

3. **Revoke first, clean later.** The moment you discover an exposed credential, revoke it. Do not waste time cleaning the repo first. Revoke. Then clean.

4. **Git history is forever** (until you rewrite it). Deleting a file does not remove it from history. You need BFG or git filter-branch to actually purge it.

5. **.gitignore is not retroactive.** It only prevents future tracking. Already-tracked files need `git rm --cached`.

6. **Build output contains your source secrets.** If it is hardcoded in source, it is in your compiled bundles. Use environment variables and server-side proxies.

7. **Being a nobody is not a security strategy.** Set up proper security from day one, because you might not always be a nobody.

I am still learning. Every day. That is the whole point. One foot in front of the other.

If this post saves even one person from the same cold-sweat moment I had when I saw my Gmail app password sitting in a public repo, it was worth writing.

---

## Resources

- [Gitleaks GitHub Repository](https://github.com/gitleaks/gitleaks)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [GitHub - Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [RFC 5737 - IPv4 Address Blocks Reserved for Documentation](https://www.rfc-editor.org/rfc/rfc5737)
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [pre-commit Framework](https://pre-commit.com/)

---

## About the Author

David Keane is a Masters student in Cybersecurity, Applied Psychology graduate, and the creator of RangerPlex. He is dyslexic, ADHD, and autistic, and he believes those are features, not bugs. He climbs mountains, builds open-source security tools, and writes about his mistakes so other people do not have to repeat them.

You can find him on GitHub at [davidtkeane](https://github.com/davidtkeane) or read more posts on this blog.

*Rangers lead the way.*
