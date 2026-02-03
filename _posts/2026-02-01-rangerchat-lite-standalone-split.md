---
title: "How We Split RangerChat Lite from a 12GB Monorepo into a Standalone GitHub Repository"
date: 2026-02-01 02:00:00 +0000
categories: [Development, Open-Source]
tags: [electron, react, typescript, monorepo, git, github, rangerchat, blockchain, p2p, windows, macos, linux, npm, developer-experience]
pin: false
math: false
mermaid: false
---

## Overview

This is the story of how I extracted RangerChat Lite -- a peer-to-peer encrypted Electron desktop chat app -- from a massive monorepo into its own standalone GitHub repository. What started as a "this should take an hour" task turned into a full weekend of dependency hunting, path rewriting, Windows debugging, and security hardening. Along the way I learned more about monorepo architecture, cross-platform packaging, and developer experience than any textbook could teach me.

The result? Going from a painful sparse checkout of a 12GB repo to a simple `git clone` + `npm install` + `npm run dev`. Three commands. Done.

---

## What Is RangerChat Lite?

Before we get into the surgery, let me explain the patient.

**RangerChat Lite** is a desktop chat application I built as part of the RangerPlex project -- my Master's thesis platform that integrates penetration testing, blockchain technology, digital forensics, and malware analysis into one working system.

| Property | Value |
|----------|-------|
| **Framework** | Electron (React + TypeScript) |
| **Purpose** | P2P encrypted chat client with blockchain features |
| **Backend** | Node.js with WebSocket relay servers |
| **Blockchain** | RangerBlock -- custom blockchain for identity and message integrity |
| **Version** | 2.0.0 (post-split) |
| **Repo** | [github.com/davidtkeane/ranger-chat-lite](https://github.com/davidtkeane/ranger-chat-lite) |

RangerChat Lite lets you send encrypted messages over a peer-to-peer network, with blockchain-backed identity verification. It has voice chat, video chat, file transfers, a wallet system, and a blockchain ledger -- all running from a lightweight Electron window.

The key word there is **Lite**. It's supposed to be the easy-to-install version. Supposed to be.

---

## The Problem: Living Inside a Monorepo

RangerChat Lite lived inside my main project, **rangerplex-ai**, at the path `apps/ranger-chat-lite/`. That monorepo is... substantial. We're talking about a 12GB beast containing:

- The full RangerBlock blockchain implementation (1000+ files)
- Penetration testing tools and OSINT modules
- Digital forensics utilities
- Malware analysis lab (educational, before anyone panics)
- Multiple applications, libraries, and experiments
- Years of development history

When I told someone "just install RangerChat Lite," the conversation went something like this:

> **Me:** Clone the repo and run the install script!
>
> **Them:** OK... it says 12GB. Is that right?
>
> **Me:** Yeah, but you only need one folder. Use sparse checkout.
>
> **Them:** What's sparse checkout?
>
> **Me:** It's a git feature that lets you clone only specific directories. Here, run these commands...
>
> **Them:** That didn't work. I'm on Windows.
>
> **Me:** Right, OK, try this instead...

You see the problem. I was asking regular users to perform advanced git operations just to install a chat app. The Windows install script was breaking. People were cloning 12GB of data to use maybe 200MB of it. It was a disaster for developer experience.

### The Sparse Checkout Pain

For those who haven't had the pleasure, here's what the old installation process looked like:

```bash
# Step 1: Initialize a partial clone (already confusing)
git clone --filter=blob:none --sparse https://github.com/davidtkeane/rangerplex-ai.git

# Step 2: Navigate into it
cd rangerplex-ai

# Step 3: Set up sparse checkout for just the app
git sparse-checkout set apps/ranger-chat-lite

# Step 4: But wait, the app needs files from rangerblock/lib too...
git sparse-checkout add rangerblock/lib

# Step 5: NOW install dependencies
cd apps/ranger-chat-lite
npm install

# Step 6: Hope everything works
npm run dev
```

Six steps, and step 4 was the killer. RangerChat Lite depended on 27 CommonJS files from `rangerblock/lib/` -- three directories up from where the app lived. If you forgot to add that sparse checkout path, the app would crash on startup with cryptic "module not found" errors.

On Windows, it was even worse. The install script had issues with Python detection, Node.js version mismatches, and npm errors that got swallowed silently. Users would run the script, see "Installation complete!", and then the app would fail to start.

I knew I had to fix this. The app needed its own home.

---

## The Plan

The plan was straightforward on paper:

1. Copy the app out of the monorepo into its own directory
2. Bundle any dependencies it needed from the parent repo
3. Fix all the path references
4. Simplify the install scripts
5. Push to a new standalone GitHub repository
6. Test on macOS, Windows, and Linux

Simple, right? Here's what actually happened.

---

## Step 1: Identifying Dependencies

The first real task was figuring out exactly what RangerChat Lite needed from the monorepo. The app's Electron main process (`electron/main.ts`) was the key file -- it's where all the backend logic gets wired up.

I searched through the TypeScript for any path references going up to the parent directories:

```bash
grep -r "rangerblock" electron/main.ts
```

What I found were three critical `require()` calls that reached up into the monorepo:

```typescript
// OLD paths - reaching up 3 directories into the monorepo
const blockchainChat = require('../../../rangerblock/lib/blockchain-chat.cjs');
const relayBridge = require('../../../rangerblock/lib/relay-server-bridge.cjs');
const identityManager = require('../../../rangerblock/lib/identity_manager.cjs');
```

Those three dots going up, up, up -- `../../../` -- that's the smell of a monorepo dependency. The app was reaching three levels up to grab files from `rangerblock/lib/`.

But those three files weren't the whole story. Each of them had their own `require()` calls to other files in the same directory. The blockchain chat module needed the crypto utilities. The relay bridge needed the WebSocket server. The identity manager needed the wallet and ledger services.

I traced the full dependency tree and ended up with **27 CommonJS files** that needed to come along:

```
admin-check.cjs          identity-service.cjs      setup_new_user.cjs
auth-server.cjs          identity_manager.cjs      SimpleBlockchain.cjs
blockchain-chat.cjs      ledger-service.cjs        storage-utils.cjs
blockchain-ping.cjs      registration-service.cjs  sync-manager.cjs
consent-service.cjs      relay-server-bridge.cjs   update-check.cjs
crypto-utils.cjs         relay-server.cjs          video-chat.cjs
file-transfer-service.cjs  secure-identity.cjs     voice-chat.cjs
hardware-id.cjs          secure-wallet.cjs         wallet-ledger-integration.cjs
hardwareDetection.cjs
idcp_compress.cjs
idcp_decompress.cjs
```

27 files. That's a significant chunk of the blockchain library, but it makes sense -- RangerChat Lite is essentially a blockchain application with a chat interface on top.

---

## Step 2: Bundling the Dependencies

I created a `lib/rangerblock/` directory inside the standalone app and copied all 27 files into it:

```bash
mkdir -p lib/rangerblock
cp ../rangerblock/lib/*.cjs lib/rangerblock/
```

The directory structure went from this:

```
rangerplex-ai/                    # 12GB monorepo
  rangerblock/
    lib/
      blockchain-chat.cjs         # Dependencies lived HERE
      relay-server-bridge.cjs
      identity_manager.cjs
      ... (24 more files)
  apps/
    ranger-chat-lite/             # App lived HERE
      electron/
        main.ts
      src/
        App.tsx
      package.json
```

To this:

```
ranger-chat-lite/                 # Standalone repo (~200MB)
  lib/
    rangerblock/
      blockchain-chat.cjs         # Dependencies now live WITH the app
      relay-server-bridge.cjs
      identity_manager.cjs
      ... (24 more files)
  electron/
    main.ts
  src/
    App.tsx
  package.json
```

Everything the app needs is now inside its own repository. No more reaching up three directories. No more sparse checkout.

---

## Step 3: Rewriting Path References

This was the critical part. Three `require()` calls in `electron/main.ts` needed to be updated:

```typescript
// OLD: Reaching up into the monorepo
const blockchainChat = require('../../../rangerblock/lib/blockchain-chat.cjs');
const relayBridge = require('../../../rangerblock/lib/relay-server-bridge.cjs');
const identityManager = require('../../../rangerblock/lib/identity_manager.cjs');

// NEW: Looking into the bundled lib directory
const blockchainChat = require('../lib/rangerblock/blockchain-chat.cjs');
const relayBridge = require('../lib/rangerblock/relay-server-bridge.cjs');
const identityManager = require('../lib/rangerblock/identity_manager.cjs');
```

Three lines changed. From `../../../rangerblock/lib/` to `../lib/rangerblock/`. That's it.

But here's what I learned: those 27 `.cjs` files also reference each other using relative paths like `./crypto-utils.cjs` and `./storage-utils.cjs`. Because I kept them all in the same directory together (`lib/rangerblock/`), those internal references didn't need to change at all. The files still sit next to each other, so `./crypto-utils.cjs` still resolves correctly.

This was a lucky design decision from when I originally wrote the blockchain library -- keeping everything flat in one directory with relative imports. If I'd used absolute paths or complex nested structures, this extraction would have been much harder.

### Verification

After updating the paths, I verified every single file was byte-identical to the originals:

```bash
# Compare each file
for f in lib/rangerblock/*.cjs; do
  original="../rangerplex-ai/rangerblock/lib/$(basename $f)"
  if diff "$f" "$original" > /dev/null 2>&1; then
    echo "OK: $(basename $f)"
  else
    echo "DIFFERENT: $(basename $f)"
  fi
done
```

All 27 files: **identical**. No accidental modifications. No encoding issues. No line-ending problems.

I also ran the TypeScript compiler to make sure the path changes didn't break anything:

```bash
npx tsc --noEmit
```

Clean compile. Zero errors. That was a good moment.

---

## Step 4: Simplifying the Install Scripts

The old install scripts were trying to do too much. They had to handle sparse checkout, verify the monorepo structure, check that the rangerblock library was accessible, and deal with cross-platform path differences. All of that complexity vanished with the standalone repo.

### The New Install Experience

Here's what installation looks like now:

```bash
# macOS/Linux
git clone https://github.com/davidtkeane/ranger-chat-lite.git
cd ranger-chat-lite
npm install
npm run dev
```

```powershell
# Windows
git clone https://github.com/davidtkeane/ranger-chat-lite.git
cd ranger-chat-lite
npm install
npm run dev
```

Four commands. Same on every platform. No sparse checkout. No path setup. No confusion.

I also kept the install scripts (`install-mac.sh` and `install-win.bat`) for users who want a guided experience with dependency checking, but they're now just convenience wrappers around those four commands, not complex monorepo navigation tools.

---

## Step 5: Fixing Windows-Specific Issues

Windows. My old nemesis. During the split, I took the opportunity to fix several Windows-specific problems that had been plaguing users.

### Python Check

The old install script checked for Python (needed by some npm native modules) but didn't handle the case where Python wasn't installed. It would just fail silently. The new script explicitly checks and gives a helpful message:

```batch
where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Python not found. Some native modules may not compile.
    echo [INFO] Download Python from https://www.python.org/downloads/
    echo [INFO] Make sure to check "Add Python to PATH" during installation.
)
```

### Node.js Version

I added a recommendation for Node.js v22 LTS. Older versions were causing subtle issues with the WebSocket library and some of the crypto functions:

```batch
node -v
echo [INFO] Recommended: Node.js v22 LTS or later
echo [INFO] Download from https://nodejs.org/
```

### npm Error Visibility

This was the sneakiest bug. The old install script was redirecting npm's stderr to null:

```batch
REM OLD - errors silently swallowed
npm install 2>nul
```

So when npm failed, users saw... nothing. They thought it worked. Then the app crashed. I removed the error suppression:

```batch
REM NEW - errors visible
npm install
if %ERRORLEVEL% neq 0 (
    echo [ERROR] npm install failed. Please check the errors above.
    pause
    exit /b 1
)
```

Always show your errors, folks. Silent failures are the worst kind of bug.

---

## Step 6: Security Hardening

Since I was already doing surgery on the app, I took the opportunity to address some security issues that had been on my to-do list. This is where my cybersecurity Master's training kicked in.

### Content Security Policy

I added proper CSP headers to the Electron window. Before the split, the app had no Content Security Policy at all -- any script could run, any resource could load. That's fine for development, but not for a production app that handles encrypted messages.

```typescript
// Added to electron/main.ts
session.defaultSession.webRequest.onHeadersReceived((details, callback) => {
  callback({
    responseHeaders: {
      ...details.responseHeaders,
      'Content-Security-Policy': [
        "default-src 'self'; " +
        "script-src 'self'; " +
        "style-src 'self' 'unsafe-inline'; " +
        "connect-src 'self' wss://*.rangerplex.com https://*.rangerplex.com; " +
        "img-src 'self' data:; " +
        "font-src 'self'"
      ]
    }
  });
});
```

This locks down what the app can do: only load scripts from itself, only connect to RangerPlex servers, no inline scripts, no external resources.

### Replacing Hardcoded IPs with DNS Hostnames

This one made me cringe when I found it. The old code had hardcoded IP addresses for the relay servers:

```typescript
// OLD - hardcoded IPs (bad practice)
const RELAY_SERVER = 'ws://123.45.67.89:8080';
```

I replaced all of them with DNS hostnames:

```typescript
// NEW - proper DNS hostnames
const RELAY_SERVER = process.env.RANGER_RELAY_URL || 'wss://relay.rangerplex.com';
```

This is better for several reasons:
- IPs can change; DNS names are stable
- DNS allows load balancing and failover
- `wss://` instead of `ws://` means encrypted WebSocket connections
- The environment variable lets users point to their own relay if they want

### Environment Variables for Relay Configuration

I added environment variable support so users can configure their own relay servers without modifying the source code:

```bash
# Use a custom relay server
RANGER_RELAY_URL=wss://my-relay.example.com npm run dev

# Use a custom port
RANGER_RELAY_PORT=9090 npm run dev
```

This is important for privacy-conscious users who want to run their own infrastructure.

### Path Traversal Protection

I added validation to the IPC (Inter-Process Communication) handlers. Electron apps use IPC to communicate between the renderer process (the UI) and the main process (Node.js backend). If an IPC handler accepts file paths without validation, a malicious renderer could potentially read or write files outside the app's directory.

```typescript
// Validate file paths in IPC handlers
function isPathSafe(requestedPath: string): boolean {
  const resolved = path.resolve(requestedPath);
  const appDir = path.resolve(app.getPath('userData'));
  return resolved.startsWith(appDir);
}
```

Any file operation that comes through IPC now gets checked against the app's data directory. If someone tries to read `/etc/passwd` through an IPC call, it gets rejected.

---

## Step 7: Version Bump and Final Testing

With everything in place, I bumped the version to **2.0.0**. This felt right -- it's not just a patch or a minor update. The app has a fundamentally different installation model, improved security, and a new home. That deserves a major version bump.

```json
{
  "name": "ranger-chat-lite",
  "version": "2.0.0",
  "description": "Lightweight chat client for the RangerPlex blockchain network"
}
```

### Testing Checklist

Here's what I verified before pushing:

- [x] All 27 `.cjs` files byte-identical to originals
- [x] TypeScript compiles with zero errors (`npx tsc --noEmit`)
- [x] App starts successfully on macOS (`npm run dev`)
- [x] App connects to relay server
- [x] Blockchain identity creation works
- [x] Message sending and receiving works
- [x] File transfer works
- [x] Install script runs cleanly on a fresh clone
- [x] CSP headers applied correctly (checked in DevTools)
- [x] No hardcoded IPs remaining (`grep -r "\\b[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\." --include="*.ts" --include="*.cjs"`)
- [x] Path traversal protection active on all IPC file handlers

---

## What I Learned: Monorepo vs Standalone Tradeoffs

This whole experience taught me a lot about the monorepo vs standalone debate. Here's my honest take.

### When a Monorepo Makes Sense

- **During active development** of tightly coupled components. When I was building RangerBlock and RangerChat Lite simultaneously, having them in one repo meant I could change a blockchain function and immediately test it in the chat app.
- **For internal projects** where your team controls the entire stack. Nobody outside the team needs to install individual pieces.
- **When you have shared build tooling** (like Turborepo, Nx, or Lerna) that makes the multi-package workflow smooth.

### When Standalone Makes Sense

- **When external users need to install your app.** Full stop. If someone outside your team needs to use it, make it easy.
- **When the monorepo has grown massive.** 12GB is not reasonable to clone for a 200MB app.
- **When you want independent versioning and release cycles.** RangerChat Lite v2.0.0 doesn't need to care about what version the forensics tools are at.

### The Hybrid Approach

What I ended up with is actually a hybrid. The monorepo still exists as the development home for everything. But user-facing applications get extracted into their own repos for distribution. The 27 `.cjs` files in `lib/rangerblock/` are essentially a vendored copy of the blockchain library.

This means I have two places to update when the library changes. That's the tradeoff. But for the improved user experience, it's absolutely worth it.

---

## My Mistakes (And What I Should Have Done)

I always try to be honest about my mistakes in these posts. Here's what I got wrong.

### Mistake 1: Not Planning for External Users from Day One

When I started building RangerChat Lite, I knew it would be a standalone app eventually. But I built it deep inside the monorepo anyway because it was "easier for development." That short-term convenience cost me a weekend of extraction work.

**What I should have done:** Set up the app with bundled dependencies from the start, even inside the monorepo. Use a build step to copy the needed files rather than using `../../../` path references.

### Mistake 2: Suppressing npm Errors on Windows

Redirecting stderr to null in the Windows install script seemed harmless. "It'll just hide some warnings," I thought. What it actually did was hide real errors that prevented the app from working. Multiple users probably gave up silently because of this.

**What I should have done:** Always show errors. Add explicit error checking after every command. Make failures loud and obvious.

### Mistake 3: Hardcoded IP Addresses

I hardcoded relay server IPs during early development because "I'll fix it later." Months later, those IPs were still there, scattered across multiple files.

**What I should have done:** Use environment variables and DNS hostnames from the very first commit. It takes the same amount of effort and saves massive headaches later.

### Mistake 4: No Content Security Policy

Shipping an Electron app without CSP is like leaving your front door open. I knew better -- I'm literally studying cybersecurity -- but I skipped it because "it's just a chat app." A chat app that handles encrypted messages and private keys.

**What I should have done:** Add CSP from day one. It's a few lines of code and it significantly reduces the attack surface.

---

## The Final Result

Here's what the standalone repository looks like:

```
ranger-chat-lite/
  electron/
    main.ts              # Electron main process
    preload.ts           # Secure bridge between main and renderer
  src/
    App.tsx              # React application root
    components/          # UI components
    styles/              # CSS modules
  lib/
    rangerblock/         # Bundled blockchain library (27 files)
      blockchain-chat.cjs
      relay-server-bridge.cjs
      identity_manager.cjs
      crypto-utils.cjs
      ... (23 more)
  install-mac.sh         # macOS install helper
  install-win.bat        # Windows install helper
  package.json           # v2.0.0
  tsconfig.json
  vite.config.ts
  README.md
```

Clean. Self-contained. Everything you need, nothing you don't.

### Before and After

| Aspect | Before (Monorepo) | After (Standalone) |
|--------|-------------------|-------------------|
| **Clone size** | ~12GB | ~200MB |
| **Install steps** | 6+ (with sparse checkout) | 3 (clone, install, run) |
| **Git knowledge needed** | Advanced (sparse checkout) | Basic (git clone) |
| **Windows support** | Broken (silent errors) | Working (visible errors, guides) |
| **Security** | No CSP, hardcoded IPs | CSP headers, DNS hostnames, path protection |
| **Version** | 1.9.x | 2.0.0 |

---

## Commands Reference

For anyone who wants to try it out, here's the complete installation:

### macOS / Linux

```bash
# Clone
git clone https://github.com/davidtkeane/ranger-chat-lite.git
cd ranger-chat-lite

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build
```

### Windows (PowerShell)

```powershell
# Clone
git clone https://github.com/davidtkeane/ranger-chat-lite.git
cd ranger-chat-lite

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for Windows
npm run build:win
```

### Using the Install Scripts (Optional)

```bash
# macOS
chmod +x install-mac.sh
./install-mac.sh

# Windows (run as Administrator if needed)
install-win.bat
```

### Environment Variables

```bash
# Custom relay server
RANGER_RELAY_URL=wss://your-relay.example.com npm run dev

# Custom relay port
RANGER_RELAY_PORT=9090 npm run dev
```

---

## Conclusion

Splitting RangerChat Lite out of the monorepo was one of those tasks that felt annoying at first but turned out to be genuinely valuable. Not just for users -- though the improved install experience is the biggest win -- but for my own understanding of software architecture.

Here's what I'll take away from this:

1. **Build for distribution from day one.** Even if you're the only user right now, structure your code as if someone else needs to install it tomorrow.
2. **Show your errors.** Silent failures are worse than crashes. At least a crash tells you something went wrong.
3. **Security is not optional.** CSP headers, input validation, encrypted connections -- these aren't nice-to-haves. They're baseline requirements.
4. **Monorepos are for developers. Standalone repos are for users.** Use both. Extract user-facing apps into their own homes.
5. **Test the install experience on a clean machine.** What works on your development setup might not work anywhere else.

The standalone repo is live at [github.com/davidtkeane/ranger-chat-lite](https://github.com/davidtkeane/ranger-chat-lite). Three commands to a working P2P encrypted chat client. That's the way it should be.

One foot in front of the other. Sometimes that foot involves untangling a monorepo, but you get there in the end.

---

## Links

- **RangerChat Lite (Standalone)**: [github.com/davidtkeane/ranger-chat-lite](https://github.com/davidtkeane/ranger-chat-lite)
- **RangerPlex AI (Monorepo)**: [github.com/davidtkeane/rangerplex-ai](https://github.com/davidtkeane/rangerplex-ai)
- **Previous Post**: [Do Indie Developers Really Need Code Signing?](/posts/indie-developer-code-signing-guide/)

---

*Written by David Keane. Dublin, Ireland. February 2026.*
*Disabilities are superpowers. One foot in front of the other.*
