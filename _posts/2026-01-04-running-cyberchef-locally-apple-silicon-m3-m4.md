---
title: "Running CyberChef Locally on Apple Silicon (M3/M4 Max) Kali Linux"
date: 2026-01-04 02:00:00 +0000
categories: [Security, Tools]
tags: [cyberchef, kali, apple-silicon, m3, m4, arm64, nodejs, nvm, encryption, data-analysis]
pin: false
math: false
mermaid: false
---

## Overview

CyberChef is a powerful web-based tool for encryption, encoding, compression, and data analysis - often called "The Cyber Swiss Army Knife." Developed by GCHQ, it provides 300+ operations that run entirely in your browser, making it invaluable for cybersecurity professionals, CTF players, and data analysts.

In this guide, you'll learn:
- How to run CyberChef locally on Apple Silicon (M3/M4 Max)
- Solving Node.js version compatibility issues
- Setting up the development environment on Kali Linux ARM64
- Docker alternatives for ARM64 architecture
- Common use cases and operations

**What is CyberChef?** A client-side web application for encryption, encoding, compression, and data manipulation. All processing happens in your browser - no data leaves your machine.

---

## Prerequisites

**Hardware:**
- MacBook Pro with M3/M4/M3 Max/M4 Max chip
- 4GB+ RAM allocated to VM

**Software:**
- Kali Linux ARM64 (or any Linux distribution)
- Node.js v16.x (we'll install this)
- npm package manager
- Git

**Knowledge:**
- Basic command line usage
- Understanding of encoding/encryption concepts (helpful but not required)

---

## The Problem: Node.js Version Compatibility

CyberChef was built with Node.js v16 and has strict version requirements. If you try running it with newer Node versions (v18, v20, v22+), you'll encounter errors:

```
SyntaxError: Unexpected identifier 'assert'
    at Module._compile (internal/modules/cjs/loader.js:895:18)
```

**The issue:** Modern Node.js versions have breaking changes that are incompatible with CyberChef's build system (Grunt).

**The solution:** Use NVM (Node Version Manager) to install and switch to Node.js v16.

---

## Step 1: Install Prerequisites

First, clone the CyberChef repository:

```bash
cd ~/Documents/Apps/
git clone https://github.com/gchq/CyberChef.git
cd CyberChef
```

**Expected output:**
```
Cloning into 'CyberChef'...
remote: Enumerating objects: 45678, done.
remote: Total 45678 (delta 0), reused 0 (delta 0), pack-reused 45678
Receiving objects: 100% (45678/45678), 25.67 MiB | 10.23 MiB/s, done.
```

---

## Step 2: Install NVM (Node Version Manager)

### Why NVM?

Your system might have Node.js v18, v20, or v22+ installed by default. NVM allows you to install and switch between multiple Node.js versions without conflicts.

### Install NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

**Expected output:**
```
=> Downloading nvm from git to '/home/kali/.nvm'
=> Cloning into '/home/kali/.nvm'...
=> Compiling...
=> nvm is already installed in /home/kali/.nvm, trying to update
=> Close and reopen your terminal to start using nvm
```

### Activate NVM

For **zsh** (Kali default):

```bash
cat >> ~/.zshrc << 'EOF'

# NVM for Node.js version management
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

source ~/.zshrc
```

For **bash**:

```bash
cat >> ~/.bashrc << 'EOF'

# NVM for Node.js version management
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

source ~/.bashrc
```

### Verify NVM Installation

```bash
nvm --version
```

**Expected output:**
```
0.39.0
```

---

## Step 3: Install Node.js v16

### Install and Activate Node v16

```bash
nvm install 16
nvm use 16
```

**Expected output:**
```
Downloading and installing node v16.20.2...
Now using node v16.20.2 (npm v8.19.4)
```

### Verify Node Version

```bash
node --version
npm --version
```

**Expected output:**
```
v16.20.2
8.19.4
```

### Set Node v16 as Default (Optional)

```bash
nvm alias default 16
```

This ensures Node v16 is used by default when opening new terminals.

---

## Step 4: Install CyberChef Dependencies

Navigate to the CyberChef directory and install dependencies:

```bash
cd ~/Documents/Apps/CyberChef
npm install
```

**Expected output:**
```
added 1234 packages, and audited 1235 packages in 45s

123 packages are looking for funding
  run `npm fund` for details

15 vulnerabilities (3 low, 5 moderate, 7 high)

Some issues need review, and may require choosing
a different dependency.
```

⚠️ **Note:** The security warnings are expected. CyberChef uses older dependencies, but since it runs **client-side only** in your browser, these pose minimal risk for local development.

---

## Step 5: Start the Development Server

### Run CyberChef

```bash
npx grunt dev
```

**Alternative:**
```bash
npm start  # Runs the same command
```

**Expected output:**
```
Running "webpack-dev-server:start" (webpack-dev-server) task
ℹ ｢wds｣: Project is running at http://localhost:8080/
ℹ ｢wds｣: webpack output is served from /
ℹ ｢wds｣: Content not from webpack is served from /home/kali/Documents/Apps/CyberChef/build/dev
ℹ ｢wdm｣: Compiled successfully.
```

### Access CyberChef

Open your browser and navigate to:

**http://localhost:8080**

You should see the CyberChef interface with:
- **Input pane** (top left)
- **Operations list** (middle)
- **Recipe area** (middle/top right)
- **Output pane** (bottom right)

**Success indicators:**
- Interface loads without errors
- You can drag operations to the recipe area
- Auto-bake is enabled (output updates in real-time)

---

## Step 6: Test CyberChef Operations

### Test 1: Base64 Encoding

1. In **Input** pane, type: `Hello CyberChef!`
2. Search operations for: `To Base64`
3. Drag **To Base64** to recipe area
4. **Output** should show: `SGVsbG8gQ3liZXJDaGVmIQ==`

### Test 2: Magic Detection

CyberChef can auto-detect encoding:

1. In **Input**, paste: `SGVsbG8gV29ybGQh`
2. Search for: `Magic`
3. Drag **Magic** operation to recipe
4. Output shows detected encoding and decoded result: `Hello World!`

### Test 3: SHA-256 Hash

1. Input: `password123`
2. Operation: `SHA256`
3. Output: `ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f`

---

## Alternative: Docker Setup (ARM64)

### Option 1: Pre-built Image (May Have Issues)

The official Docker image is built for AMD64 and may fail on ARM64:

```bash
docker run -it -p 8080:80 ghcr.io/gchq/cyberchef:latest
```

**Potential error:**
```
exec /docker-entrypoint.sh: exec format error
```

**Why?** Pre-built image is for x86_64 architecture, not ARM64.

---

### Option 2: Build for ARM64 (Recommended)

Build a native ARM64 Docker image:

```bash
cd ~/Documents/Apps/CyberChef
docker build --platform linux/arm64 --tag cyberchef-arm --ulimit nofile=10000 .
```

**Expected output:**
```
[+] Building 234.5s (15/15) FINISHED
 => [internal] load build definition
 => [internal] load metadata
 => [stage-1 1/3] FROM docker.io/library/nginx:1.21-alpine
 => CACHED [stage-1 2/3] COPY --from=build /CyberChef/build/prod /usr/share/nginx/html
 => naming to docker.io/library/cyberchef-arm
```

### Run the ARM64 Image

```bash
docker run -it -p 8080:80 cyberchef-arm
```

Access at: **http://localhost:8080**

---

## Alternative: Production Build

For a static production build (no hot-reload):

```bash
cd ~/Documents/Apps/CyberChef
npm run build
```

This creates a production build in `build/prod/`.

### Serve the Production Build

```bash
cd build/prod
python3 -m http.server 8080
```

Access at: **http://localhost:8080**

**Benefits:**
- Optimized and minified code
- No Node.js server required (just static files)
- Can be deployed to any web server

---

## Troubleshooting

### Issue 1: SyntaxError with Node.js

**Problem:**

```
SyntaxError: Unexpected identifier 'assert'
```

**Cause:** Using Node.js v18, v20, or v22+ instead of v16.

**Solution:**

```bash
nvm use 16
node --version  # Verify it shows v16.x.x
npm install
npx grunt dev
```

If Node v16 isn't installed:

```bash
nvm install 16
nvm use 16
nvm alias default 16
```

---

### Issue 2: Port 8080 Already in Use

**Problem:**

```
Error: listen EADDRINUSE: address already in use :::8080
```

**Cause:** Another process is using port 8080.

**Solution:**

Find and kill the process:

```bash
lsof -i :8080
```

**Output:**
```
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
node    12345 kali   21u  IPv6 123456      0t0  TCP *:8080 (LISTEN)
```

Kill the process:

```bash
kill -9 12345  # Replace with actual PID
```

Or use a different port:

```bash
npx grunt dev --port 8081
```

---

### Issue 3: Cannot Find Module Errors

**Problem:**

```
Error: Cannot find module 'webpack'
```

**Cause:** Dependencies not installed or corrupted.

**Solution:**

Reinstall dependencies:

```bash
cd ~/Documents/Apps/CyberChef
rm -rf node_modules package-lock.json
npm install
```

---

### Issue 4: Docker "io_setup() failed" on ARM64

**Problem:**

```
io_setup() failed: Function not implemented
```

**Cause:** Pre-built Docker image is for AMD64, not ARM64.

**Solution:**

Use npm development server (recommended):

```bash
npx grunt dev
```

Or build Docker image for ARM64:

```bash
docker build --platform linux/arm64 --tag cyberchef-arm .
docker run -it -p 8080:80 cyberchef-arm
```

---

### Issue 5: npm audit Vulnerabilities

**Problem:**

```
15 vulnerabilities (3 low, 5 moderate, 7 high)
```

**Cause:** CyberChef uses older dependencies with known issues.

**Is this a problem?**

No, for local development:
- All code runs **client-side** in your browser
- No server-side execution
- No data leaves your machine
- Vulnerabilities are in build tools, not runtime

**Solution (if concerned):**

Use the official online version: https://gchq.github.io/CyberChef

---

## CyberChef Features & Use Cases

### 300+ Operations

CyberChef includes operations in these categories:

**Encoding/Decoding:**
- Base64, Base32, Hex, URL, HTML entities
- ASCII, Unicode, UTF-8/16

**Encryption/Decryption:**
- AES (ECB, CBC, CTR, GCM, OFB, CFB)
- DES, Triple DES
- Blowfish, RSA, RC4
- Rabbit, ChaCha

**Hashing:**
- MD5, SHA-1, SHA-2 (224/256/384/512)
- SHA-3, BLAKE2b/s, RIPEMD
- HMAC, bcrypt, scrypt

**Compression:**
- gzip, bzip2, LZMA, ZIP
- Deflate, Zlib

**Data Formats:**
- JSON beautify/minify/parse
- XML beautify/minify
- YAML, TOML, CSV
- Protobuf decode
- JWT decode/verify

**Network:**
- Parse IP addresses
- IPv4/IPv6 conversion
- DNS over HTTPS
- Parse URIs
- Extract URLs/emails

**Analysis:**
- Entropy calculation
- File type detection
- Regex extraction
- Chi-squared test
- Detect file type from magic bytes

---

## Common Use Cases

### 1. Decode Base64 Encoded Text

**Scenario:** You found a Base64 string in a CTF challenge.

**Steps:**
1. Input: `SGVsbG8gQ3liZXJDaGVmIQ==`
2. Operation: `From Base64`
3. Output: `Hello CyberChef!`

---

### 2. Analyze Unknown Encoded Data

**Scenario:** You have encoded data but don't know the encoding.

**Steps:**
1. Input: `48656c6c6f`
2. Operation: `Magic` (auto-detects encoding)
3. Output shows: "From Hex" → `Hello`

**Magic** is incredibly useful for CTF challenges!

---

### 3. Decrypt AES-Encrypted Data

**Scenario:** You have AES-encrypted ciphertext and the key.

**Steps:**
1. Input: `<ciphertext in hex or base64>`
2. Operation: `AES Decrypt`
3. Configure:
   - Key: `<your AES key>`
   - IV: `<initialization vector>`
   - Mode: CBC/ECB/CTR
   - Input format: Hex or Base64
   - Output format: Raw or UTF-8

---

### 4. Hash Password with Salt

**Scenario:** Generate a secure password hash.

**Steps:**
1. Input: `MySecurePassword123`
2. Add operations:
   - `To Hex` (convert password to hex)
   - `Append` (add salt)
   - `SHA256` (hash result)
3. Output: Salted password hash

---

### 5. Decode JWT Token

**Scenario:** Analyze a JSON Web Token.

**Steps:**
1. Input: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0...`
2. Operation: `JWT Decode`
3. Output: JSON with header, payload, and signature

---

### 6. Extract All URLs from Text

**Scenario:** Extract URLs from a large text file.

**Steps:**
1. Input: `<text with URLs>`
2. Operation: `Extract URLs`
3. Output: List of all URLs found

---

### 7. Convert Between Number Bases

**Scenario:** Convert hex to decimal.

**Steps:**
1. Input: `0xFF` or `FF`
2. Operation: `From Hex` → `To Decimal`
3. Output: `255`

---

### 8. Create Multi-Step Recipes

**Example: Decode → Decompress → Parse**

1. Input: Base64-encoded gzipped JSON
2. Recipe:
   - `From Base64`
   - `Gunzip`
   - `JSON Beautify`
3. Output: Pretty-printed JSON

**Save recipes** for reuse using the save/load buttons!

---

## Key Takeaways

1. **Node.js v16 is required** - Use NVM to manage Node versions
2. **Everything runs client-side** - No data leaves your browser
3. **ARM64 Docker needs building** - Pre-built images are AMD64 only
4. **Magic operation is powerful** - Auto-detects encoding/encryption
5. **Recipes can be chained** - Combine operations for complex transformations
6. **Save recipes for reuse** - Create custom operation sequences

---

## Quick Reference

### Installation Commands

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.zshrc

# Install Node.js v16
nvm install 16
nvm use 16
nvm alias default 16

# Clone CyberChef
git clone https://github.com/gchq/CyberChef.git
cd CyberChef

# Install dependencies
npm install

# Start dev server
npx grunt dev
```

### Running CyberChef

```bash
# Development server (with hot-reload)
cd ~/Documents/Apps/CyberChef
npx grunt dev
# Access: http://localhost:8080

# Production build
npm run build
cd build/prod
python3 -m http.server 8080
```

### Docker (ARM64)

```bash
# Build for ARM64
docker build --platform linux/arm64 --tag cyberchef-arm .

# Run container
docker run -it -p 8080:80 cyberchef-arm
```

### Verify Setup

```bash
# Check Node version
node --version  # Should be v16.x.x

# Check NVM
nvm list  # Should show v16.x.x active

# Test CyberChef
curl http://localhost:8080  # Should return HTML
```

---

## Offline Usage

CyberChef runs entirely in the browser, so you can:

1. **Build production version:**
   ```bash
   npm run build
   ```

2. **Copy `build/prod/` folder** to USB drive or another machine

3. **Open `index.html`** directly in browser (no server needed)

Perfect for **air-gapped environments** or offline CTF competitions!

---

## Security Considerations

### Safe for Sensitive Data

✅ **All processing is client-side** - No data is sent to external servers
✅ **No analytics or tracking** - Completely private
✅ **Open source** - Code can be audited
✅ **Offline capable** - Works without internet connection

### Not a Security Tool

⚠️ **Do not use for production encryption** - CyberChef is for analysis, not secure crypto
⚠️ **Not cryptographically secure** - Use proper crypto libraries for real applications
⚠️ **Educational/analysis only** - Great for learning and CTFs, not production security

---

## Resources

- **Live Demo:** [https://gchq.github.io/CyberChef](https://gchq.github.io/CyberChef)
- **GitHub:** [https://github.com/gchq/CyberChef](https://github.com/gchq/CyberChef)
- **Wiki:** [https://github.com/gchq/CyberChef/wiki](https://github.com/gchq/CyberChef/wiki)
- **Contributing Guide:** [https://github.com/gchq/CyberChef/wiki/Contributing](https://github.com/gchq/CyberChef/wiki/Contributing)
- **Recipe Collection:** [https://github.com/mattnotmax/cyberchef-recipes](https://github.com/mattnotmax/cyberchef-recipes)

---

## Support This Content

If this guide helped you set up CyberChef on your M3/M4 Mac, consider supporting more tutorials like this!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

Your support helps create more in-depth guides and tutorials!

---

**Setup Time:** ~15 minutes
**Difficulty:** Beginner
**Tested On:** MacBook Pro M4 Max, Kali Linux ARM64 2025.1
**Node.js Version:** v16.20.2
**CyberChef Version:** Latest (from main branch)
