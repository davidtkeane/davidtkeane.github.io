---
title: "Git Security Mistakes Every Developer Makes (And How to Fix Them)"
date: 2026-02-01 03:00:00 +0000
categories: [Security, Development]
tags: [git, security, api-keys, credentials, gitignore, gitleaks, bfg-repo-cleaner, pre-commit-hooks, github, cybersecurity, secrets, devops, tutorial]
pin: false
math: false
mermaid: false
---

## Overview

This is a comprehensive guide to the 7 most common git security mistakes that developers make -- including several I have personally made with real credentials on a public repository. For each mistake, I cover how it happens, how to detect it, how to fix it, and how to make sure it never happens again.

If you have ever typed `git push` without thinking about what was in your files, this post might save your career. Or at least save you from the cold sweat I experienced when I found my own Gmail password sitting in a public GitHub repo.

---

## Who Am I?

My name is David Keane. I am a 51-year-old Applied Psychology graduate from Dublin, Ireland, currently pursuing my Masters in Cybersecurity at the University of Galway (via NCI Dublin). I am dyslexic, ADHD, and autistic -- diagnosed at 39 -- and I have spent 14 years turning those diagnoses into superpowers.

I build things. I break things. I learn from the wreckage. And then I write it all down so you can skip the wreckage part.

I am not writing this post from some ivory tower. I am writing it because I found my own Gmail password, my Google API key, real server IP addresses, and network topology information sitting in a public GitHub repository. My repository. For weeks.

Nobody cloned it. Nobody exploited it. I got lucky. You might not.

Let us make sure you never have to find out.

---

## The 7 Deadly Sins of Git Security

Here is what we are covering:

1. Committing `.env` files with API keys
2. Hardcoding passwords and tokens in source code
3. Embedding API keys in compiled or bundled JavaScript
4. Committing private key files (`.pem`, `.key`)
5. Exposing real IP addresses and network topology
6. Thinking `.gitignore` protects already-tracked files (it does not)
7. Not scanning git history for old secrets

Each one is a landmine. I have stepped on at least four of them personally. Let us walk through them one at a time.

---

## Mistake 1: Committing .env Files with API Keys

### How It Happens

You are building an app. You need API keys for OpenAI, Google, Stripe, whatever. You create a `.env` file because every tutorial tells you to:

```bash
# .env
OPENAI_API_KEY=sk-proj-abc123def456ghi789
GOOGLE_API_KEY=AIzaSyD-abcdefghijklmnop
GMAIL_PASSWORD=MyActualPassword123
DATABASE_URL=postgres://admin:secretpass@db.example.com:5432/myapp
```

You are in the flow. The code works. You are buzzing. You type:

```bash
git add .
git commit -m "initial commit"
git push origin main
```

And just like that, every secret in that `.env` file is now on the internet. Forever. Even if you delete it in the next commit, it is in your git history. Anyone who clones the repo can find it.

### How I Know This

Because I did exactly this. My RangerPlex project had a `.env` file with my actual Gmail app password and Google API key. It sat in a public repo for weeks before I caught it during a security audit. The moment I saw it, my stomach dropped. I could feel the blood drain from my face.

If you have ever been at altitude and felt that sudden wave of "something is very wrong" -- it is the same feeling. Except instead of your body failing, it is your digital security.

### How to Detect It

**Manual check:**

```bash
# Search for .env files in your repo
find . -name ".env" -not -path "./.git/*"
find . -name ".env.*" -not -path "./.git/*"
find . -name "*.env" -not -path "./.git/*"
```

**Using gitleaks (recommended):**

```bash
# Install gitleaks
brew install gitleaks

# Scan your repo
gitleaks detect --source . --verbose
```

**Check if .env is tracked by git:**

```bash
git ls-files | grep -i env
```

If that command returns anything, you have a problem.

### How to Fix It

**Step 1: Remove the file from git tracking (but keep it locally):**

```bash
git rm --cached .env
```

This is critical. `git rm --cached` removes the file from git's tracking without deleting it from your filesystem. More on this distinction later -- it is one of the most misunderstood commands in git.

**Step 2: Add it to .gitignore:**

```bash
echo ".env" >> .gitignore
echo ".env.*" >> .gitignore
echo "*.env" >> .gitignore
```

**Step 3: Commit the changes:**

```bash
git add .gitignore
git commit -m "Remove .env from tracking and add to .gitignore"
git push
```

**Step 4: Rotate ALL credentials in that file immediately.**

This is not optional. The moment a secret touches a public git repo, consider it compromised. Generate new API keys. Change passwords. Revoke tokens. Do it now.

**Step 5: Purge from git history.**

Even after `git rm --cached`, the old commits still contain the file. We will cover how to purge history with BFG Repo-Cleaner later in this post.

### How to Prevent It

Create your `.gitignore` BEFORE your first commit. Always. No exceptions.

Here is a starter `.gitignore` for any project:

```gitignore
# Environment files
.env
.env.*
*.env
.env.local
.env.development
.env.production

# API keys and secrets
secrets.json
credentials.json
config.local.json

# Private keys
*.pem
*.key
*.p12
*.pfx
id_rsa
id_ed25519
```

---

## Mistake 2: Hardcoding Passwords and Tokens in Source Code

### How It Happens

It is 2 AM. You are debugging a connection issue. You hardcode a password just to test:

```python
# config.py
DATABASE_PASSWORD = "SuperSecret123!"
API_TOKEN = "ghp_abc123def456ghi789jkl012mno345pqr678"
SMTP_PASSWORD = "MyGmailAppPassword"
```

"I will fix it later," you tell yourself. You will not fix it later. Two weeks from now you will `git push` and that password goes live.

Or maybe you are writing a script and you think "nobody will ever see this":

```javascript
// api.js
const OPENAI_KEY = "sk-proj-abc123def456ghi789";
const client = new OpenAI({ apiKey: OPENAI_KEY });
```

I have seen this in production codebases at actual companies. I have done it myself. We all have.

### How to Detect It

**Manual grep for common patterns:**

```bash
# Search for hardcoded secrets (these are regex patterns)
grep -rn "password\s*=" --include="*.py" --include="*.js" --include="*.ts" .
grep -rn "api_key\s*=" --include="*.py" .
grep -rn "apiKey\s*=" --include="*.js" --include="*.ts" .
grep -rn "token\s*=" --include="*.py" --include="*.js" .
grep -rn "secret\s*=" --include="*.py" --include="*.js" .
```

**Using gitleaks:**

```bash
gitleaks detect --source . --verbose --report-format json --report-path gitleaks-report.json
```

Gitleaks knows the patterns for hundreds of different API key formats. It will catch things your eyes will miss.

### How to Fix It

Replace hardcoded values with environment variable references:

**Python:**

```python
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD")
API_TOKEN = os.getenv("API_TOKEN")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD")
```

**JavaScript/Node.js:**

```javascript
require('dotenv').config();

const OPENAI_KEY = process.env.OPENAI_API_KEY;
const client = new OpenAI({ apiKey: OPENAI_KEY });
```

**Install dotenv if you have not:**

```bash
# Python
pip install python-dotenv

# Node.js
npm install dotenv
```

### How to Prevent It

Make it a rule: **never type an actual secret into a source file**. Not even for testing. Not even for "just a minute." Use environment variables from the start, even if it takes an extra 30 seconds to set up.

If you are testing locally, create a `.env.example` file with placeholder values that IS committed to the repo:

```bash
# .env.example (this file IS committed - shows required variables)
OPENAI_API_KEY=your-key-here
DATABASE_URL=your-database-url-here
SMTP_PASSWORD=your-email-password-here
```

Then copy it:

```bash
cp .env.example .env
# Now edit .env with your real values
```

---

## Mistake 3: Embedding API Keys in Compiled or Bundled JavaScript

### How It Happens

This one is sneaky. You might have your API key properly stored in an environment variable in your source code. But when you build your frontend JavaScript with webpack, Vite, or any bundler, those environment variables get **inlined** into the output bundle.

```javascript
// Your source code (looks fine)
const apiKey = process.env.REACT_APP_API_KEY;

// After webpack builds it (NOT fine)
const apiKey = "sk-proj-abc123def456ghi789";
```

If that built JavaScript file is in your git repo -- which it often is if you commit your `dist/` or `build/` folder -- your API key is now in plaintext in your repository. And unlike a `.env` file that is obviously sensitive, a minified JavaScript bundle can hide secrets in 200,000 characters of unreadable code.

### How to Detect It

```bash
# Search built/bundled files for common API key patterns
grep -rn "sk-proj-" ./dist/ ./build/ ./.next/ 2>/dev/null
grep -rn "AIzaSy" ./dist/ ./build/ ./.next/ 2>/dev/null
grep -rn "ghp_" ./dist/ ./build/ ./.next/ 2>/dev/null
grep -rn "AKIA" ./dist/ ./build/ ./.next/ 2>/dev/null
```

Or use gitleaks -- it scans everything, including bundled files.

### How to Fix It

**Option 1: Do not commit build artifacts.**

Add your build folders to `.gitignore`:

```gitignore
dist/
build/
.next/
out/
```

**Option 2: Use a backend proxy for sensitive API calls.**

Never put secret API keys in frontend code. Instead, create a simple backend endpoint that holds the key and proxies requests:

```javascript
// Backend (Express.js) - the key stays here
app.post('/api/chat', async (req, res) => {
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: req.body.messages,
  });
  res.json(response);
});

// Frontend - no key needed
const response = await fetch('/api/chat', {
  method: 'POST',
  body: JSON.stringify({ messages }),
});
```

**Option 3: Use public/restricted API keys for frontend.**

Some services (like Google Maps) offer keys that can be restricted by domain. These are designed to be in frontend code. But most API keys (OpenAI, AWS, Stripe secret keys) must NEVER be in frontend code.

### How to Prevent It

Ask yourself: "If someone views the page source in their browser, can they see this key?" If the answer is yes, move it to the backend.

---

## Mistake 4: Committing Private Key Files

### How It Happens

You generate an SSH key or SSL certificate for your server:

```bash
ssh-keygen -t ed25519 -f ./deploy_key
openssl genrsa -out server.key 2048
```

Those files end up in your project directory. You `git add .` and they go straight into the repo.

Or maybe you download a `.pem` file from AWS, a `.p12` certificate for code signing, or a service account JSON from Google Cloud. They all end up in your project folder because that is where you are working.

```
my-project/
  src/
  deploy_key          # SSH private key
  deploy_key.pub      # SSH public key (this one is fine)
  server.key          # SSL private key
  service-account.json # Google Cloud credentials
  certificate.p12     # Code signing certificate
```

### How to Detect It

```bash
# Find private key files in your repo
git ls-files | grep -E "\.(pem|key|p12|pfx|jks|keystore)$"
git ls-files | grep -E "(id_rsa|id_ed25519|id_dsa|deploy_key)$"
git ls-files | grep -E "(credentials\.json|service.account\.json)"
```

**Check file contents for key headers:**

```bash
grep -rn "BEGIN.*PRIVATE KEY" --include="*.pem" --include="*.key" .
grep -rn "BEGIN RSA PRIVATE KEY" .
grep -rn "BEGIN OPENSSH PRIVATE KEY" .
```

### How to Fix It

```bash
# Remove from tracking (keep local copy)
git rm --cached deploy_key server.key service-account.json
git rm --cached "*.pem" "*.key" "*.p12" 2>/dev/null

# Add to .gitignore
echo "*.pem" >> .gitignore
echo "*.key" >> .gitignore
echo "*.p12" >> .gitignore
echo "*.pfx" >> .gitignore
echo "deploy_key" >> .gitignore
echo "service-account.json" >> .gitignore
echo "credentials.json" >> .gitignore

# Commit
git add .gitignore
git commit -m "Remove private keys from tracking"
```

Then rotate every key that was exposed. Generate new SSH keys. Get new certificates. Revoke the old ones.

### How to Prevent It

Store keys outside your project directory entirely:

```bash
# Good: Keys in ~/.ssh/ (never in project)
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key_projectname

# Good: Reference by path, not by including in project
export SSL_KEY_PATH="$HOME/.ssl/server.key"
```

---

## Mistake 5: Exposing Real IP Addresses and Network Topology

### How It Happens

This is the one people forget about entirely. You are writing configuration files, deployment scripts, or documentation. You use real IP addresses:

```yaml
# docker-compose.yml
services:
  app:
    environment:
      - DATABASE_HOST=192.168.1.42
      - REDIS_HOST=10.0.0.15
      - API_SERVER=203.0.113.55

# nginx.conf
upstream backend {
    server 172.16.0.10:3000;
    server 172.16.0.11:3000;
}
```

```markdown
<!-- README.md -->
## Deployment
SSH into the production server:
ssh admin@203.0.113.55
```

```javascript
// config.js
const SERVERS = {
  primary: "203.0.113.55",
  backup: "198.51.100.22",
  database: "192.168.1.42"
};
```

Now anyone who reads your repo knows your server IPs, your internal network layout, which ports are open, and where your database lives. You have just given an attacker a map of your infrastructure.

### How I Know This

During my RangerPlex security audit, I found real IP addresses and network topology information in configuration files. As someone studying cybersecurity, finding that in my own code was... humbling. Like a locksmith leaving their own front door wide open.

In mountaineering terms, it is like an experienced climber forgetting to clip into the fixed rope. You know better. But fatigue, focus on the code, and "I will fix it later" conspire against you.

### How to Detect It

```bash
# Search for IP addresses in your codebase
grep -rn -E "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" \
  --include="*.js" --include="*.py" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.conf" \
  --include="*.md" --include="*.env" .
```

Not all IPs are problems -- `127.0.0.1` and `0.0.0.0` are fine. But anything that looks like a real internal or external address needs investigation.

### How to Fix It

Replace real IPs with:
- Environment variables for configuration
- Placeholder IPs from RFC 5737 documentation ranges: `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`
- Hostnames that resolve via DNS or service discovery

```yaml
# Before (BAD)
DATABASE_HOST: 192.168.1.42

# After (GOOD - environment variable)
DATABASE_HOST: ${DB_HOST}

# After (GOOD - in documentation, use RFC 5737 example IPs)
DATABASE_HOST: 192.0.2.1  # Example IP - replace with your actual host
```

### How to Prevent It

Make it a habit: **never type a real IP address into a file that will be committed.** Use environment variables for configuration. Use RFC 5737 example ranges for documentation. Use DNS hostnames for service discovery.

---

## Mistake 6: Thinking .gitignore Protects Already-Tracked Files

### How It Happens

This is the mistake that catches people who think they have already fixed the problem. Here is the scenario:

1. You accidentally commit `.env` with your API keys
2. You realize the mistake
3. You add `.env` to `.gitignore`
4. You commit the `.gitignore` change
5. You feel safe

**You are not safe.**

`.gitignore` only prevents **untracked** files from being added to git. If a file is already tracked (it has been committed at least once), `.gitignore` does absolutely nothing. Git will continue tracking changes to that file regardless of what your `.gitignore` says.

Let me say that again because it is that important: **.gitignore does not protect files that git is already tracking.**

### The Critical Distinction: git rm --cached vs git rm

This is one of the most important things you will learn from this post.

**`git rm filename`**

This removes the file from git tracking AND deletes it from your filesystem. The file is gone from your computer.

```bash
git rm .env
# Result: .env is deleted from your disk AND removed from git
```

**`git rm --cached filename`**

This removes the file from git tracking but KEEPS it on your filesystem. The file stays on your computer but git stops watching it.

```bash
git rm --cached .env
# Result: .env stays on your disk but git ignores it
```

**Almost always, you want `git rm --cached`.** You want to stop tracking the file in git, but you still need the file locally for your application to work.

### The Full Fix Sequence

```bash
# Step 1: Remove from git tracking (keep local copy)
git rm --cached .env

# Step 2: Make sure .gitignore has the file listed
echo ".env" >> .gitignore

# Step 3: Commit both changes
git add .gitignore
git commit -m "Stop tracking .env - remove from git, add to .gitignore"

# Step 4: Push
git push

# Step 5: Verify it worked
git status
# .env should NOT appear in the output

git ls-files | grep .env
# Should return nothing
```

### How to Detect Already-Tracked Files That Should Be Ignored

```bash
# Show files that are tracked by git but ALSO listed in .gitignore
# If this returns anything, you have a problem
git ls-files -i --exclude-standard
```

That command lists files that match your `.gitignore` patterns but are still being tracked. If it returns results, those files need `git rm --cached`.

### The Nuclear Option for Multiple Files

If you have a lot of files to clean up:

```bash
# Remove ALL tracked files that should be ignored
git rm -r --cached .
git add .
git commit -m "Remove all files that should be gitignored"
```

**Warning**: This removes all files from the index and re-adds them, which effectively drops everything matched by `.gitignore`. Test this on a branch first.

---

## Mistake 7: Not Scanning Git History for Old Secrets

### How It Happens

Here is the thing about git that makes security people lose sleep: **git remembers everything.**

Even if you have:
- Removed the file from tracking
- Added it to `.gitignore`
- Deleted it from the repo
- Committed the deletion

The file is still in your git history. Every version of every file that was ever committed is stored in the `.git` directory. Anyone who clones your repo has access to the complete history.

```bash
# An attacker can see ALL past versions of every file
git log --all --full-history -- ".env"
git show <old-commit-hash>:.env
```

That command will show them the `.env` file from any historical commit, complete with all your API keys and passwords.

### How to Detect Secrets in History

**Using gitleaks to scan full history:**

```bash
# Scan the entire git history (not just current files)
gitleaks detect --source . --verbose --log-opts="--all"
```

This is the command that really matters. Scanning only current files gives you a false sense of security. You need to scan the entire history.

**Manual check for specific files:**

```bash
# Check if a sensitive file ever existed in history
git log --all --full-history -- "*.env"
git log --all --full-history -- "*.pem"
git log --all --full-history -- "*.key"
git log --all --full-history -- "credentials.json"
git log --all --full-history -- "secrets.json"
```

### How to Fix It: BFG Repo-Cleaner

This is where BFG Repo-Cleaner comes in. BFG is a tool specifically designed to remove files, passwords, and other sensitive data from git history. It is faster and simpler than `git filter-branch`.

**Install BFG:**

```bash
brew install bfg
```

**Step-by-step BFG tutorial:**

```bash
# Step 1: Clone a MIRROR of your repo (not a normal clone)
git clone --mirror https://github.com/yourusername/your-repo.git your-repo.git

# Step 2: Remove a specific file from ALL history
bfg --delete-files .env your-repo.git

# Or remove multiple file patterns
bfg --delete-files "*.pem" your-repo.git
bfg --delete-files credentials.json your-repo.git

# Or replace specific text (like API keys) with ***REMOVED***
bfg --replace-text passwords.txt your-repo.git
# Where passwords.txt contains one secret per line

# Step 3: Clean up the repo
cd your-repo.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Step 4: Push the cleaned history
git push
```

**Important notes about BFG:**

- BFG does not modify your latest commit (HEAD). Make sure you have already removed secrets from the current version before running BFG
- After pushing, anyone who has cloned your repo still has the old history. They need to re-clone
- This rewrites git history, which means force-pushing. Coordinate with your team
- **Always test on a mirror clone first, never directly on your working repo**

### The passwords.txt File for BFG

If you want to replace specific strings in history (rather than deleting entire files), create a text file with one secret per line:

```
sk-proj-abc123def456ghi789
AIzaSyD-abcdefghijklmnop
MyActualGmailPassword
ghp_abc123def456ghi789
AKIA1234567890ABCDEF
```

Then run:

```bash
bfg --replace-text passwords.txt your-repo.git
```

BFG will replace every occurrence of those strings with `***REMOVED***` throughout your entire git history.

---

## Tool Recommendations: Your Security Arsenal

Here is the toolkit I use and recommend. Think of these as your climbing gear for code security -- you would not go up a mountain without a harness, and you should not push code without these tools.

### 1. Gitleaks -- The Scanner

**What it does:** Scans your codebase and git history for secrets, API keys, passwords, and tokens. Knows patterns for hundreds of different services.

```bash
# Install
brew install gitleaks

# Scan current files
gitleaks detect --source . --verbose

# Scan full git history
gitleaks detect --source . --verbose --log-opts="--all"

# Generate a JSON report
gitleaks detect --source . --report-format json --report-path gitleaks-report.json

# Scan before committing (use in CI/CD)
gitleaks protect --source . --verbose
```

### 2. BFG Repo-Cleaner -- The Purifier

**What it does:** Removes files and text from your entire git history. Much faster than `git filter-branch`.

```bash
# Install
brew install bfg

# Delete a file from all history
bfg --delete-files sensitive-file.json repo.git

# Replace text strings throughout history
bfg --replace-text passwords.txt repo.git

# Delete files larger than a threshold
bfg --strip-blobs-bigger-than 10M repo.git
```

### 3. Pre-commit Hooks -- The Gatekeeper

**What they do:** Run checks automatically before every commit. If a check fails, the commit is blocked. This is your last line of defense before secrets hit the repo.

We are going to build a custom one in the next section.

### 4. GitHub Secret Scanning

**What it does:** GitHub automatically scans public repositories for known secret patterns and alerts you. It is free for public repos and available for private repos on GitHub Advanced Security.

**How to enable:**

1. Go to your repo on GitHub
2. Settings > Code security and analysis
3. Enable "Secret scanning"

GitHub will alert you if it detects API keys from major providers (AWS, Google, Stripe, OpenAI, etc.) in your code. Some providers will even automatically revoke detected keys.

### 5. truffleHog -- The Deep Scanner

**What it does:** Another excellent secret scanner that uses both regex patterns and entropy analysis (high-entropy strings are likely secrets).

```bash
# Install
brew install trufflehog

# Scan a repo
trufflehog git https://github.com/yourusername/your-repo.git
```

---

## Building the Ranger Security Scanner: A Custom Pre-Commit Hook

Now let us build something useful. I call this the Ranger Security Scanner -- a pre-commit hook that checks for the most common security mistakes before they reach your repo.

### What It Checks

- API key patterns (Google, OpenAI, AWS, GitHub, Slack, Stripe, and more)
- Hardcoded password assignments
- Private key files (`.pem`, `.key`, `.p12`, etc.)
- Exposed IP addresses (excluding localhost and example ranges)
- `.env` files being committed
- Large files that might be databases or binaries
- Database files (`.sqlite`, `.db`)

### The Script

Create this file at `.git/hooks/pre-commit` in your repo:

```bash
#!/bin/bash
#
# Ranger Security Scanner - Pre-Commit Hook
# Author: David Keane (IrishRanger)
# Purpose: Catch security mistakes before they hit the repo
#
# "Come home alive - summit is secondary"
# In code terms: "Ship secure code - speed is secondary"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

BLOCKED=0
WARNINGS=0

echo ""
echo -e "${CYAN}${BOLD}=====================================${NC}"
echo -e "${CYAN}${BOLD}  RANGER SECURITY SCANNER v1.0${NC}"
echo -e "${CYAN}${BOLD}  Pre-Commit Security Check${NC}"
echo -e "${CYAN}${BOLD}=====================================${NC}"
echo ""

# Get list of staged files (only files being committed)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}No staged files to check.${NC}"
    exit 0
fi

# ============================================
# CHECK 1: .env files
# ============================================
echo -e "${BOLD}[1/7] Checking for .env files...${NC}"

ENV_FILES=$(echo "$STAGED_FILES" | grep -E '\.env($|\.)' || true)
if [ -n "$ENV_FILES" ]; then
    echo -e "${RED}  BLOCKED: .env file(s) detected in commit:${NC}"
    echo "$ENV_FILES" | while read -r f; do
        echo -e "${RED}    - $f${NC}"
    done
    echo -e "${YELLOW}  Fix: git rm --cached <file> && echo '<file>' >> .gitignore${NC}"
    BLOCKED=1
else
    echo -e "${GREEN}  Clear.${NC}"
fi

# ============================================
# CHECK 2: Private key files
# ============================================
echo -e "${BOLD}[2/7] Checking for private key files...${NC}"

KEY_FILES=$(echo "$STAGED_FILES" | grep -E '\.(pem|key|p12|pfx|jks|keystore)$' || true)
NAMED_KEYS=$(echo "$STAGED_FILES" | grep -E '(id_rsa|id_ed25519|id_dsa|deploy_key)' || true)

FOUND_KEYS="${KEY_FILES}${NAMED_KEYS}"
if [ -n "$FOUND_KEYS" ]; then
    echo -e "${RED}  BLOCKED: Private key file(s) detected:${NC}"
    echo "$FOUND_KEYS" | sort -u | while read -r f; do
        [ -n "$f" ] && echo -e "${RED}    - $f${NC}"
    done
    echo -e "${YELLOW}  Fix: git rm --cached <file> && add to .gitignore${NC}"
    BLOCKED=1
else
    echo -e "${GREEN}  Clear.${NC}"
fi

# ============================================
# CHECK 3: API key patterns in file contents
# ============================================
echo -e "${BOLD}[3/7] Scanning for API key patterns...${NC}"

API_PATTERNS=(
    'sk-proj-[a-zA-Z0-9_-]{20,}'          # OpenAI API keys
    'sk-[a-zA-Z0-9]{20,}'                  # OpenAI legacy keys
    'AIzaSy[a-zA-Z0-9_-]{33}'              # Google API keys
    'AKIA[A-Z0-9]{16}'                     # AWS Access Key IDs
    'ghp_[a-zA-Z0-9]{36}'                  # GitHub personal access tokens
    'gho_[a-zA-Z0-9]{36}'                  # GitHub OAuth tokens
    'github_pat_[a-zA-Z0-9_]{22,}'         # GitHub fine-grained PATs
    'xoxb-[0-9]{10,}-[a-zA-Z0-9-]+'       # Slack bot tokens
    'xoxp-[0-9]{10,}-[a-zA-Z0-9-]+'       # Slack user tokens
    'sk_live_[a-zA-Z0-9]{24,}'             # Stripe live secret keys
    'rk_live_[a-zA-Z0-9]{24,}'             # Stripe restricted keys
    'SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}' # SendGrid API keys
    'ya29\.[a-zA-Z0-9_-]{50,}'             # Google OAuth tokens
)

API_FOUND=0
for pattern in "${API_PATTERNS[@]}"; do
    MATCHES=$(echo "$STAGED_FILES" | while read -r f; do
        [ -f "$f" ] && grep -lE "$pattern" "$f" 2>/dev/null || true
    done)
    if [ -n "$MATCHES" ]; then
        echo -e "${RED}  BLOCKED: Potential API key found matching pattern:${NC}"
        echo -e "${RED}    Pattern: $pattern${NC}"
        echo "$MATCHES" | sort -u | while read -r f; do
            [ -n "$f" ] && echo -e "${RED}    File: $f${NC}"
        done
        API_FOUND=1
    fi
done

if [ "$API_FOUND" -eq 1 ]; then
    echo -e "${YELLOW}  Fix: Move secrets to .env and reference with environment variables${NC}"
    BLOCKED=1
else
    echo -e "${GREEN}  Clear.${NC}"
fi

# ============================================
# CHECK 4: Hardcoded passwords
# ============================================
echo -e "${BOLD}[4/7] Checking for hardcoded passwords...${NC}"

PW_PATTERNS=(
    'password\s*=\s*["\x27][^"\x27]{3,}'
    'PASSWORD\s*=\s*["\x27][^"\x27]{3,}'
    'passwd\s*=\s*["\x27][^"\x27]{3,}'
    'secret\s*=\s*["\x27][^"\x27]{3,}'
    'SECRET\s*=\s*["\x27][^"\x27]{3,}'
)

PW_FOUND=0
for pattern in "${PW_PATTERNS[@]}"; do
    MATCHES=$(echo "$STAGED_FILES" | while read -r f; do
        [ -f "$f" ] && grep -lE "$pattern" "$f" 2>/dev/null || true
    done)
    if [ -n "$MATCHES" ]; then
        echo -e "${YELLOW}  WARNING: Possible hardcoded password in:${NC}"
        echo "$MATCHES" | sort -u | while read -r f; do
            [ -n "$f" ] && echo -e "${YELLOW}    - $f${NC}"
        done
        PW_FOUND=1
    fi
done

if [ "$PW_FOUND" -eq 1 ]; then
    echo -e "${YELLOW}  Review these files and ensure no real passwords are committed.${NC}"
    WARNINGS=1
else
    echo -e "${GREEN}  Clear.${NC}"
fi

# ============================================
# CHECK 5: Private key content in files
# ============================================
echo -e "${BOLD}[5/7] Checking for private key content...${NC}"

KEY_CONTENT_FOUND=0
while IFS= read -r f; do
    [ -f "$f" ] || continue
    if grep -qE "BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY" "$f" 2>/dev/null; then
        echo -e "${RED}  BLOCKED: Private key content found in: $f${NC}"
        KEY_CONTENT_FOUND=1
    fi
done <<< "$STAGED_FILES"

if [ "$KEY_CONTENT_FOUND" -eq 1 ]; then
    echo -e "${YELLOW}  Fix: Remove private key content and store keys outside the repo${NC}"
    BLOCKED=1
else
    echo -e "${GREEN}  Clear.${NC}"
fi

# ============================================
# CHECK 6: IP addresses
# ============================================
echo -e "${BOLD}[6/7] Checking for exposed IP addresses...${NC}"

IP_FOUND=0
while IFS= read -r f; do
    [ -f "$f" ] || continue
    # Skip binary files
    file --mime-type "$f" 2>/dev/null | grep -q "text/" || continue
    # Find IPs, excluding localhost, example ranges, and 0.0.0.0
    IPS=$(grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "$f" 2>/dev/null | \
        grep -vE "^(127\.|0\.0\.0\.0|192\.0\.2\.|198\.51\.100\.|203\.0\.113\.|255\.)" | \
        sort -u)
    if [ -n "$IPS" ]; then
        echo -e "${YELLOW}  WARNING: IP address(es) found in $f:${NC}"
        echo "$IPS" | while read -r ip; do
            echo -e "${YELLOW}    $ip${NC}"
        done
        IP_FOUND=1
    fi
done <<< "$STAGED_FILES"

if [ "$IP_FOUND" -eq 1 ]; then
    echo -e "${YELLOW}  Review: Are these real IPs? Replace with env vars or RFC 5737 example ranges.${NC}"
    WARNINGS=1
else
    echo -e "${GREEN}  Clear.${NC}"
fi

# ============================================
# CHECK 7: Large files and databases
# ============================================
echo -e "${BOLD}[7/7] Checking for large files and databases...${NC}"

DB_FILES=$(echo "$STAGED_FILES" | grep -E '\.(sqlite|sqlite3|db|mdb|accdb)$' || true)
if [ -n "$DB_FILES" ]; then
    echo -e "${YELLOW}  WARNING: Database file(s) staged for commit:${NC}"
    echo "$DB_FILES" | while read -r f; do
        echo -e "${YELLOW}    - $f${NC}"
    done
    WARNINGS=1
fi

LARGE_FILES=""
while IFS= read -r f; do
    [ -f "$f" ] || continue
    SIZE=$(wc -c < "$f" 2>/dev/null | tr -d ' ')
    if [ "$SIZE" -gt 5242880 ]; then  # 5MB
        LARGE_SIZE=$(echo "scale=1; $SIZE / 1048576" | bc 2>/dev/null || echo "large")
        LARGE_FILES="${LARGE_FILES}    - $f (${LARGE_SIZE}MB)\n"
    fi
done <<< "$STAGED_FILES"

if [ -n "$LARGE_FILES" ]; then
    echo -e "${YELLOW}  WARNING: Large file(s) staged (>5MB):${NC}"
    echo -e "${YELLOW}${LARGE_FILES}${NC}"
    echo -e "${YELLOW}  Consider using Git LFS for large files.${NC}"
    WARNINGS=1
fi

if [ -z "$DB_FILES" ] && [ -z "$LARGE_FILES" ]; then
    echo -e "${GREEN}  Clear.${NC}"
fi

# ============================================
# RESULTS
# ============================================
echo ""
echo -e "${CYAN}${BOLD}=====================================${NC}"

if [ "$BLOCKED" -eq 1 ]; then
    echo -e "${RED}${BOLD}  COMMIT BLOCKED${NC}"
    echo -e "${RED}  Security issues must be resolved.${NC}"
    echo -e "${RED}  Fix the issues above and try again.${NC}"
    echo -e "${CYAN}${BOLD}=====================================${NC}"
    echo ""
    exit 1
elif [ "$WARNINGS" -eq 1 ]; then
    echo -e "${YELLOW}${BOLD}  COMMIT ALLOWED (with warnings)${NC}"
    echo -e "${YELLOW}  Review the warnings above.${NC}"
    echo -e "${CYAN}${BOLD}=====================================${NC}"
    echo ""
    exit 0
else
    echo -e "${GREEN}${BOLD}  ALL CLEAR - Commit approved${NC}"
    echo -e "${GREEN}  No security issues detected.${NC}"
    echo -e "${CYAN}${BOLD}=====================================${NC}"
    echo ""
    exit 0
fi
```

### Installing the Hook

```bash
# Option 1: Copy directly into your repo's hooks directory
cp ranger-security-scanner.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Option 2: For a global hook (applies to ALL your repos)
mkdir -p ~/.git-hooks
cp ranger-security-scanner.sh ~/.git-hooks/pre-commit
chmod +x ~/.git-hooks/pre-commit
git config --global core.hooksPath ~/.git-hooks
```

### Testing It

```bash
# Create a test file with a fake API key
echo 'OPENAI_KEY="sk-proj-test1234567890abcdefghijklmnopqrst"' > test_secret.txt
git add test_secret.txt
git commit -m "test"
# The hook should BLOCK this commit

# Clean up
git reset HEAD test_secret.txt
rm test_secret.txt
```

---

## David's Story: The Day I Found My Own Gmail Password on GitHub

I want to tell you the full story because I think it matters.

I was building RangerPlex -- my Master's thesis project. It is a cybersecurity platform that integrates penetration testing, blockchain networking, digital forensics, and malware analysis. Over a thousand files. Months of late-night coding sessions. I was proud of it.

One evening, my AI assistant and I decided to do a proper security audit. Not because I thought there was a problem, but because I was studying cybersecurity and figured I should practice what I preach.

We ran gitleaks. The results came back.

My Gmail app password. In plaintext. In a configuration file. In a public repository.

My Google API key. Same story.

Real IP addresses from my home network. Server topology. Internal network layout.

I sat there staring at the screen. I am a cybersecurity student. I literally study this stuff. I know better. And yet there it all was, sitting in public view, because I had gotten comfortable and careless.

The feeling was like being at 5,000 metres on Kilimanjaro when you realise something is wrong with your body but you cannot quite figure out what. That creeping dread. That "oh no" moment that starts in your stomach and works its way up.

Here is what I did:

1. Immediately rotated all compromised credentials (new Gmail app password, new API keys)
2. Ran `git rm --cached` on every sensitive file
3. Updated `.gitignore` comprehensively
4. Used BFG Repo-Cleaner to purge the history
5. Built the pre-commit hook you see above
6. Scanned everything again to make sure it was clean
7. Wrote this blog post so you can learn from my mistake instead of making your own

The good news? Nobody had cloned the repo. The credentials were not exploited. I got lucky.

But luck is not a security strategy. Luck is what kills people on mountains. Preparation, systems, and discipline -- those are what keep you alive.

---

## The Complete Security Audit Checklist

Here is the full checklist I now run on every project. Print it. Pin it next to your monitor. Run through it before every major push.

### Before First Commit

- [ ] Create `.gitignore` with all sensitive file patterns
- [ ] Set up pre-commit hook (Ranger Security Scanner or similar)
- [ ] Create `.env.example` with placeholder values
- [ ] Store actual secrets in `.env` (which is gitignored)
- [ ] Verify: `git ls-files | grep -i env` returns nothing

### Regular Maintenance (Monthly)

- [ ] Run `gitleaks detect --source . --verbose`
- [ ] Run `gitleaks detect --source . --verbose --log-opts="--all"` (history scan)
- [ ] Check for tracked files that should be ignored: `git ls-files -i --exclude-standard`
- [ ] Review `.gitignore` for completeness
- [ ] Verify no IP addresses in committed files
- [ ] Check for large files that should use Git LFS

### After Finding a Secret

- [ ] Rotate the compromised credential immediately
- [ ] `git rm --cached <file>` to stop tracking
- [ ] Add to `.gitignore`
- [ ] Use BFG to purge from history
- [ ] Force push the cleaned history
- [ ] Notify anyone who has cloned the repo
- [ ] Scan again to verify the secret is gone

### Before Open-Sourcing a Private Repo

- [ ] Full gitleaks history scan
- [ ] Manual review of all configuration files
- [ ] Search for IP addresses, hostnames, internal URLs
- [ ] Check for database files, logs, or backups
- [ ] Review all TODO and FIXME comments (sometimes contain credentials)
- [ ] Have someone else review (fresh eyes catch things)

---

## Quick Reference: Commands You Will Use Most

```bash
# ==========================================
# SCANNING
# ==========================================

# Scan current files for secrets
gitleaks detect --source . --verbose

# Scan full git history
gitleaks detect --source . --verbose --log-opts="--all"

# Check what git is tracking
git ls-files

# Find tracked files that match .gitignore
git ls-files -i --exclude-standard

# ==========================================
# REMOVING FILES FROM TRACKING
# ==========================================

# Stop tracking a file (keep it locally)
git rm --cached filename

# Stop tracking a directory (keep it locally)
git rm -r --cached dirname/

# Nuclear: re-apply .gitignore to everything
git rm -r --cached .
git add .
git commit -m "Re-apply .gitignore"

# ==========================================
# PURGING HISTORY WITH BFG
# ==========================================

# Clone a mirror
git clone --mirror https://github.com/user/repo.git repo.git

# Delete a file from history
bfg --delete-files filename repo.git

# Replace text in history
bfg --replace-text secrets.txt repo.git

# Clean up after BFG
cd repo.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push

# ==========================================
# PREVENTION
# ==========================================

# Install pre-commit hook
chmod +x .git/hooks/pre-commit

# Set global hooks directory
git config --global core.hooksPath ~/.git-hooks

# Test your hook
echo 'test_key="sk-proj-fake123"' > test.txt
git add test.txt && git commit -m "test"
# Should be blocked!
git reset HEAD test.txt && rm test.txt
```

---

## Common Excuses (And Why They Are Wrong)

**"My repo is private, so it does not matter."**

Private repos become public. Companies get acquired. Access controls change. Employees leave and take copies. Treat every repo as if it will be public someday.

**"I will clean it up before I make it public."**

You will forget something. Humans always do. That is why we use automated tools. Let the machines catch what your eyes miss.

**"It is just a test key / development password."**

Test keys have a habit of being the same as production keys. Development passwords get reused. And even if they are different, they reveal patterns and naming conventions that help attackers guess your real credentials.

**"Nobody looks at my repos."**

Bots do. Automated scanners crawl GitHub constantly, looking for exposed API keys. Some of these bots will use your AWS key to spin up cryptocurrency mining instances within minutes of it being committed. I have read the incident reports. It is real.

**"I deleted the file, so it is gone."**

No. Git remembers everything. `git log --all -- filename` will find it. BFG or `git filter-repo` are the only ways to truly remove something from history.

---

## Final Thoughts

I am a 51-year-old cybersecurity student with dyslexia, ADHD, and autism. I have climbed Mont Blanc, reached Stella Point on Kilimanjaro, and trekked to Everest Base Camp. I have experienced altitude-induced cognitive impairment that made me forget what gloves were for at 4,400 metres.

And I still managed to commit my Gmail password to a public GitHub repository.

Security mistakes do not happen because you are stupid. They happen because you are human. You get tired. You get focused on the code and forget about the configuration. You tell yourself "I will fix it later" and then you do not.

The solution is not to be smarter. The solution is to build systems that catch your mistakes before they become problems. Pre-commit hooks. Automated scanners. Checklists. Peer review.

In mountaineering, we use fixed ropes, harnesses, and belay systems not because we expect to fall, but because we know that humans make mistakes under pressure. The same principle applies to code security.

Build the safety systems. Use the tools. Run the scans. And when you find something -- because you will -- fix it immediately, rotate the credentials, and move on.

One foot in front of the other. That is how you climb mountains and that is how you build secure software.

Stay safe out there.

---

## Resources

- **Gitleaks**: [https://github.com/gitleaks/gitleaks](https://github.com/gitleaks/gitleaks)
- **BFG Repo-Cleaner**: [https://rtyley.github.io/bfg-repo-cleaner/](https://rtyley.github.io/bfg-repo-cleaner/)
- **GitHub Secret Scanning**: [https://docs.github.com/en/code-security/secret-scanning](https://docs.github.com/en/code-security/secret-scanning)
- **truffleHog**: [https://github.com/trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog)
- **git-filter-repo**: [https://github.com/newren/git-filter-repo](https://github.com/newren/git-filter-repo) (modern alternative to BFG)
- **pre-commit framework**: [https://pre-commit.com/](https://pre-commit.com/)
- **RFC 5737** (Documentation IP ranges): [https://datatracker.ietf.org/doc/html/rfc5737](https://datatracker.ietf.org/doc/html/rfc5737)

---

*Written by David Keane -- Applied Psychologist, cybersecurity student, mountaineer, and the fella who committed his own Gmail password to GitHub. Learn from my mistakes so you do not have to make your own.*

*If this post helped you, share it with a developer who needs it. We have all been there.*
