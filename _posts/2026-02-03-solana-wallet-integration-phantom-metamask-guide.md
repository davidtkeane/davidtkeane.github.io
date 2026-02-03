---
title: "How to Add Solana Wallet Integration to Any Website - Phantom + MetaMask Guide"
date: 2026-02-03 12:00:00 +0000
categories: [Web Development, Crypto]
tags: [solana, phantom-wallet, metamask, wallet-adapter, spl-token, solana-pay, javascript, web3, hellcoin, forgiveme-life, crypto, blockchain, react, nextjs]
pin: false
math: false
mermaid: false
---

## Overview

This is my personal field manual for connecting Solana wallets to a website. I'm writing this because I need to integrate Phantom and MetaMask into [forgiveme.life](https://forgiveme.life/) so people can tip HellCoin for their sins, and I want to understand every single line of code - not just copy-paste from Stack Overflow and pray.

If AI disappears tomorrow and I need to do this again from scratch, this post is my survival guide. One foot in front of the other.

I cover three approaches here: raw JavaScript for learning, MetaMask's new Solana support, and the proper production-ready Solana Wallet Adapter. Then I go into sending SPL tokens (like HellCoin), Solana Pay for QR code payments, security, and testing on devnet before touching real money.

**My starting position**: I have MetaMask working. I need to find my Phantom keys. I have HellCoin registered on the Solana token list (PR #15662). I am a beginner at crypto integration. I am Irish. I apologise for nothing.

---

## Why Support Multiple Wallets?

Here's the thing. When I first started thinking about adding wallet support to forgiveme.life, my brain went straight to "just add Phantom, job done." But that's like building a shop and only accepting one brand of credit card. You're telling every customer with a different wallet to go away.

The reality:

- **Phantom** is the main Solana wallet. It's purpose-built for Solana. Most Solana users have it.
- **MetaMask** added Solana support in 2025. That's huge because MetaMask has over 30 million users who already have it installed. They don't need to install anything new.
- **Solflare**, **Backpack**, **Glow**, and about 20 other wallets exist too.

If I only support Phantom, I'm ignoring millions of MetaMask users. If I only support MetaMask, I'm ignoring the core Solana community. The smart move is to support all of them.

The good news: the **Solana Wallet Adapter** library handles this automatically. One "Connect Wallet" button, and it detects whatever wallets the user has installed and lets them choose. That's the production answer.

But before we get to the proper way, let's understand what's actually happening under the hood. Because if you don't understand the plumbing, you can't fix it when it breaks at 3am and you're on your fourth coffee.

---

## How Wallet Connection Actually Works (The Mental Model)

Before any code, let me explain what's really going on. This took me a while to grasp, so I'm going to explain it the way I wish someone had explained it to me.

### The Browser Extension Injection Pattern

When you install Phantom (or MetaMask, or any browser wallet), the extension **injects a JavaScript object into every webpage you visit**. It's like the wallet sneaks into the room and leaves its business card on the table.

- **Phantom** injects `window.solana` (and also `window.phantom.solana`)
- **MetaMask** injects `window.ethereum`

These objects are APIs. They're how your website talks to the wallet. Your code says "hey, can I connect?" and the wallet extension says "let me ask the user" and pops up its approval window.

**The key insight**: Your website never touches the user's private keys. Ever. The wallet extension handles all the cryptographic signing. Your site just asks the wallet to sign things, and the wallet shows the user what they're approving. This is the entire security model.

Think of it like a notary. Your website prepares the document (the transaction). The wallet (the notary) shows it to the user, the user says "yes, stamp it," and the wallet signs it. The notary never gives you their stamp to take home.

### What is a Public Key?

When someone "connects their wallet" to your site, what you actually receive is their **public key**. This is:

- Their wallet address (like `7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU`)
- Completely safe to share (it's public, like an email address)
- How you identify them on the blockchain
- Where you send tokens TO
- NOT their private key (that stays in the wallet, always)

A public key is like your home address. People need it to send you post. Giving someone your address doesn't give them your house keys.

---

## Approach 1: Direct Phantom Connection (Learning Mode)

This is the "take the engine apart and look at every piece" approach. You won't use this in production, but understanding it means you'll actually know what the Wallet Adapter is doing for you later.

### Step 1: Detect if Phantom is Installed

```javascript
// First, we check if Phantom has injected its object into the browser.
// When Phantom is installed, it adds 'solana' to the window object.
// If the user doesn't have Phantom, window.solana will be undefined.

function isPhantomInstalled() {
  // Check the newer phantom namespace first (Phantom v22.0+)
  // Phantom moved to window.phantom.solana for cleaner namespacing
  const phantomProvider = window?.phantom?.solana;

  // If we found it, check if it's actually Phantom
  // (other wallets might also inject window.solana)
  if (phantomProvider?.isPhantom) {
    return true;
  }

  // Fallback: check the legacy window.solana location
  // Older versions of Phantom put themselves here directly
  if (window?.solana?.isPhantom) {
    return true;
  }

  // No Phantom found. The user needs to install it.
  return false;
}

// Usage:
if (isPhantomInstalled()) {
  console.log("Phantom is ready to go!");
} else {
  // Redirect them to install Phantom
  // window.open("https://phantom.app/", "_blank");
  console.log("Phantom not found. Please install it from https://phantom.app/");
}
```

**Why the `?.` (optional chaining)?** Because if `window.phantom` doesn't exist, trying to access `window.phantom.solana` would throw an error and crash your script. The `?.` says "if the thing before me is null or undefined, just return undefined instead of crashing." Defensive coding. Like checking your ropes before a climb.

### Step 2: Connect to the Wallet

```javascript
// This is the actual connection. When you call connect(), Phantom
// pops up a window asking the user "Do you want to connect to this site?"
// The user clicks Approve, and we get back their public key.

async function connectPhantom() {
  try {
    // Get the Phantom provider object
    // This is the API that lets us talk to the wallet
    const provider = window.phantom?.solana || window.solana;

    if (!provider?.isPhantom) {
      throw new Error("Phantom wallet not found! Install it from phantom.app");
    }

    // connect() is async because it needs to wait for:
    // 1. The popup to appear
    // 2. The user to click Approve or Reject
    // 3. The wallet to generate a response
    //
    // If the user rejects, this will throw an error (caught below).
    const response = await provider.connect();

    // response.publicKey is a PublicKey object (from @solana/web3.js)
    // We call .toString() to get the human-readable Base58 address string
    // Base58 is like Base64 but without confusing characters (no 0/O, no l/I)
    const walletAddress = response.publicKey.toString();

    console.log("Connected! Wallet address:", walletAddress);
    // Example output: "Connected! Wallet address: 7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU"

    return walletAddress;

  } catch (error) {
    // This catches both "user rejected" and actual errors
    // Error code 4001 means the user clicked "Reject" in the popup
    if (error.code === 4001) {
      console.log("User rejected the connection. Fair enough.");
    } else {
      console.error("Connection failed:", error.message);
    }
    return null;
  }
}
```

**Why `async/await`?** Because connecting to a wallet involves waiting for user interaction. The `await` keyword pauses execution until the promise resolves (user approves) or rejects (user declines). Without `async/await`, you'd need nested `.then()` callbacks, which get messy fast.

### Step 3: Disconnect

```javascript
// Always give users a way to disconnect. It's good practice
// and some users are (rightly) cautious about keeping wallets connected.

async function disconnectPhantom() {
  const provider = window.phantom?.solana || window.solana;

  if (provider) {
    try {
      // disconnect() tells Phantom to forget this site's connection
      // Next time they visit, they'll need to approve again
      await provider.disconnect();
      console.log("Disconnected from Phantom.");
    } catch (error) {
      console.error("Error disconnecting:", error.message);
    }
  }
}
```

### Step 4: Listen for Account Changes

```javascript
// Users might switch accounts inside Phantom while your site is open.
// You need to listen for this and update your UI accordingly.

function setupPhantomListeners() {
  const provider = window.phantom?.solana || window.solana;

  if (!provider) return;

  // 'connect' fires when the wallet successfully connects
  provider.on("connect", (publicKey) => {
    console.log("Wallet connected:", publicKey.toString());
    // Update your UI here - show the wallet address, enable features, etc.
  });

  // 'disconnect' fires when the user disconnects
  provider.on("disconnect", () => {
    console.log("Wallet disconnected.");
    // Update your UI - hide wallet features, show connect button, etc.
  });

  // 'accountChanged' fires when the user switches to a different account
  // inside Phantom. The new publicKey is passed as an argument.
  // If publicKey is null, it means they disconnected.
  provider.on("accountChanged", (publicKey) => {
    if (publicKey) {
      console.log("Switched to account:", publicKey.toString());
      // Refresh balances, update displayed address, etc.
    } else {
      console.log("Account disconnected (switched to unlinked account).");
      // Handle disconnect
    }
  });
}
```

### Complete HTML Example (Phantom Only)

Here's a full, working HTML file. Save it, open it in a browser with Phantom installed, and it works. No build tools, no npm, no React. Just HTML and JavaScript.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Phantom Wallet Test</title>
  <style>
    /* Basic styling so it doesn't look like 1997 */
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      max-width: 600px;
      margin: 50px auto;
      padding: 20px;
      background: #1a1a2e;
      color: #eee;
    }
    button {
      background: #ab9ff2; /* Phantom's purple */
      color: #1a1a2e;
      border: none;
      padding: 12px 24px;
      border-radius: 8px;
      font-size: 16px;
      cursor: pointer;
      margin: 10px 5px;
    }
    button:hover { background: #8b7fd4; }
    button:disabled { background: #555; cursor: not-allowed; }
    #status {
      padding: 15px;
      margin: 20px 0;
      border-radius: 8px;
      background: #16213e;
      word-break: break-all; /* Wallet addresses are long */
    }
  </style>
</head>
<body>

  <h1>Phantom Wallet Test</h1>
  <p>A simple test page to connect Phantom. No frameworks. No nonsense.</p>

  <div id="status">Status: Not connected</div>

  <button id="connectBtn" onclick="handleConnect()">Connect Phantom</button>
  <button id="disconnectBtn" onclick="handleDisconnect()" disabled>Disconnect</button>

  <script>
    // Get references to our UI elements
    const statusDiv = document.getElementById("status");
    const connectBtn = document.getElementById("connectBtn");
    const disconnectBtn = document.getElementById("disconnectBtn");

    // Helper function to update the status display
    function updateStatus(message) {
      statusDiv.textContent = message;
    }

    // Get the Phantom provider (or null if not installed)
    function getProvider() {
      if ("phantom" in window) {
        const provider = window.phantom?.solana;
        if (provider?.isPhantom) return provider;
      }
      // Also check legacy location
      if (window.solana?.isPhantom) return window.solana;
      return null;
    }

    // Connect button handler
    async function handleConnect() {
      const provider = getProvider();

      if (!provider) {
        updateStatus("Phantom not installed! Get it at phantom.app");
        // Optionally open the install page:
        // window.open("https://phantom.app/", "_blank");
        return;
      }

      try {
        // This triggers the Phantom popup
        const response = await provider.connect();
        const address = response.publicKey.toString();

        updateStatus("Connected: " + address);
        connectBtn.disabled = true;
        disconnectBtn.disabled = false;

      } catch (err) {
        if (err.code === 4001) {
          updateStatus("Connection rejected by user.");
        } else {
          updateStatus("Error: " + err.message);
        }
      }
    }

    // Disconnect button handler
    async function handleDisconnect() {
      const provider = getProvider();
      if (provider) {
        await provider.disconnect();
        updateStatus("Disconnected.");
        connectBtn.disabled = false;
        disconnectBtn.disabled = true;
      }
    }

    // On page load, check if already connected
    // (Phantom remembers approved sites between page loads)
    window.addEventListener("load", async () => {
      const provider = getProvider();
      if (provider?.isConnected) {
        const address = provider.publicKey.toString();
        updateStatus("Already connected: " + address);
        connectBtn.disabled = true;
        disconnectBtn.disabled = false;
      }
    });
  </script>

</body>
</html>
```

**Save this as `phantom-test.html`**, open it in Chrome/Brave with Phantom installed, and you've got wallet connection working. That's it. No npm. No build step. Just a file.

---

## Approach 2: Direct MetaMask Solana Connection

Here's what blew my mind: **MetaMask now supports Solana natively** as of 2025. The wallet that was built entirely for Ethereum and EVM chains went and added Solana support. This is massive because MetaMask has an enormous user base.

### How MetaMask's Solana Support Differs from Phantom

This is important to understand:

| Feature | Phantom | MetaMask (Solana) |
|---------|---------|-------------------|
| **Injected Object** | `window.solana` / `window.phantom.solana` | `window.ethereum` (same as EVM) |
| **Built For** | Solana-native | Originally Ethereum, Solana added 2025 |
| **Detection** | `isPhantom` flag | Need to check for Solana chain support |
| **User Base** | ~10M users | ~30M+ users |
| **Solana Features** | Full (SPL tokens, NFTs, staking) | Growing (basic transfers, SPL tokens) |

### Detecting MetaMask with Solana Support

```javascript
// MetaMask injects window.ethereum for ALL chains it supports.
// To check if it supports Solana specifically, we need to look deeper.

async function isMetaMaskSolanaAvailable() {
  // Step 1: Is MetaMask installed at all?
  if (typeof window.ethereum === "undefined") {
    console.log("MetaMask not installed.");
    return false;
  }

  // Step 2: Is it actually MetaMask? (Other wallets also inject window.ethereum)
  if (!window.ethereum.isMetaMask) {
    console.log("window.ethereum exists but it's not MetaMask.");
    return false;
  }

  // Step 3: Check if this version of MetaMask supports Solana
  // MetaMask exposes supported chains/namespaces
  // The Solana namespace is 'solana'
  try {
    // MetaMask's multichain API uses wallet_getCapabilities or
    // checks the provider's supported methods
    // The simplest check: see if MetaMask advertises Solana support
    const isSolanaSupported = window.ethereum._metamask?.isSolanaSupported?.()
      || true; // Newer MetaMask versions support it by default

    return isSolanaSupported;
  } catch (e) {
    console.log("Could not determine Solana support:", e.message);
    return false;
  }
}
```

### Connecting to MetaMask for Solana

MetaMask handles multi-chain through its unified `window.ethereum` provider. When connecting for Solana operations, you specify the Solana chain:

```javascript
// MetaMask uses the same eth_requestAccounts pattern for initial connection,
// but for Solana-specific operations, you interact with the Solana-specific
// methods that MetaMask now exposes.

async function connectMetaMaskSolana() {
  try {
    if (!window.ethereum?.isMetaMask) {
      throw new Error("MetaMask not found!");
    }

    // Request connection - this pops up the MetaMask approval window
    // This is the same call used for Ethereum connections
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts"
    });

    // For Solana-specific operations in MetaMask, you may need to
    // use MetaMask's Solana snap or the built-in Solana provider
    // depending on the MetaMask version.
    //
    // MetaMask's Solana integration gives you a Solana address
    // alongside your Ethereum address.

    console.log("MetaMask connected. Ethereum address:", accounts[0]);

    // To get the Solana address specifically, MetaMask's newer API
    // provides this through the wallet's Solana account
    // The exact API may vary as MetaMask's Solana support matures

    return accounts[0];

  } catch (error) {
    if (error.code === 4001) {
      console.log("User rejected MetaMask connection.");
    } else {
      console.error("MetaMask connection error:", error.message);
    }
    return null;
  }
}
```

### Detecting Which Wallet the User Has

In practice, a user might have Phantom, MetaMask, both, or neither. Here's how to detect what's available:

```javascript
// Survey the battlefield - what wallets does this user have?
function detectAvailableWallets() {
  const wallets = [];

  // Check for Phantom
  if (window.phantom?.solana?.isPhantom || window.solana?.isPhantom) {
    wallets.push({
      name: "Phantom",
      provider: window.phantom?.solana || window.solana,
      type: "solana-native"
    });
  }

  // Check for MetaMask
  if (window.ethereum?.isMetaMask) {
    wallets.push({
      name: "MetaMask",
      provider: window.ethereum,
      type: "multi-chain"
    });
  }

  // Check for Solflare
  if (window.solflare?.isSolflare) {
    wallets.push({
      name: "Solflare",
      provider: window.solflare,
      type: "solana-native"
    });
  }

  // Check for Backpack
  if (window.backpack) {
    wallets.push({
      name: "Backpack",
      provider: window.backpack,
      type: "multi-chain"
    });
  }

  console.log("Available wallets:", wallets.map(w => w.name).join(", "));
  return wallets;
}

// Usage:
// const wallets = detectAvailableWallets();
// if (wallets.length === 0) {
//   showInstallWalletMessage();
// } else if (wallets.length === 1) {
//   connectToWallet(wallets[0]); // Only one option, use it
// } else {
//   showWalletPicker(wallets); // Let user choose
// }
```

**This is exactly what the Solana Wallet Adapter does for you automatically.** Which brings us to...

---

## Approach 3: Solana Wallet Adapter (The Proper Way)

Right. Enough playing with raw JavaScript. In production, you use the **Solana Wallet Adapter**. It's maintained by the Solana team, supports 20+ wallets out of the box, and gives you a professional "Connect Wallet" button that handles everything.

This is the difference between building a radio from spare parts vs buying one that works. The spare parts version teaches you how radio works. The bought one actually receives signals reliably.

### For React / Next.js Applications

Most modern Solana dApps use React. Here's the full setup.

#### Step 1: Install the packages

```bash
# These are the four packages you need:

# @solana/wallet-adapter-react
# - React context providers and hooks for wallet state management
# - Gives you useWallet(), useConnection() hooks

# @solana/wallet-adapter-react-ui
# - Pre-built UI components (the connect button, wallet modal, etc.)
# - Styled and accessible out of the box

# @solana/wallet-adapter-wallets
# - Adapters for specific wallets (Phantom, Solflare, etc.)
# - Each adapter knows how to talk to its wallet's API

# @solana/web3.js
# - Solana's core JavaScript SDK
# - Handles connections, transactions, accounts, etc.

npm install @solana/wallet-adapter-react \
            @solana/wallet-adapter-react-ui \
            @solana/wallet-adapter-wallets \
            @solana/web3.js
```

#### Step 2: Set up the providers (the wrapper)

In React, "providers" wrap your app and make data available to all child components. Think of it like setting up the command tent - everything inside the tent has access to the radios, maps, and supplies.

```jsx
// File: src/components/WalletProvider.jsx
// This wraps your entire app and provides wallet functionality everywhere

import { useMemo } from "react";
import {
  ConnectionProvider,
  WalletProvider
} from "@solana/wallet-adapter-react";
import { WalletModalProvider } from "@solana/wallet-adapter-react-ui";
import {
  PhantomWalletAdapter,
  SolflareWalletAdapter,
} from "@solana/wallet-adapter-wallets";
import { clusterApiUrl } from "@solana/web3.js";

// IMPORTANT: Import the wallet adapter CSS
// Without this, the connect button and modal look broken
import "@solana/wallet-adapter-react-ui/styles.css";

export default function AppWalletProvider({ children }) {
  // Choose your network:
  // "devnet"  = test network (free fake SOL, use this for development!)
  // "testnet" = another test network
  // "mainnet-beta" = REAL network (real money!)
  //
  // ALWAYS start with devnet. Switch to mainnet-beta only when
  // everything is tested and working. I cannot stress this enough.
  const network = "devnet"; // Change to "mainnet-beta" for production

  // clusterApiUrl() converts the network name to the actual RPC URL
  // devnet = "https://api.devnet.solana.com"
  // mainnet-beta = "https://api.mainnet-beta.solana.com"
  const endpoint = useMemo(() => clusterApiUrl(network), [network]);

  // List the wallets you want to support
  // Each adapter handles communication with its specific wallet
  // useMemo ensures we don't recreate these objects on every render
  const wallets = useMemo(
    () => [
      new PhantomWalletAdapter(),
      new SolflareWalletAdapter(),
      // Add more wallets here as needed:
      // new BackpackWalletAdapter(),
      // new GlowWalletAdapter(),
      // new LedgerWalletAdapter(), // Hardware wallet!
    ],
    [network] // Recreate if network changes
  );

  return (
    // ConnectionProvider: Gives all children access to the Solana RPC connection
    // This is how your app talks to the Solana blockchain
    <ConnectionProvider endpoint={endpoint}>
      {/* WalletProvider: Manages wallet state (connected/disconnected, public key, etc.)
          autoConnect: if true, auto-reconnects if user previously approved this site */}
      <WalletProvider wallets={wallets} autoConnect>
        {/* WalletModalProvider: Provides the modal UI for wallet selection
            When user clicks Connect, this shows the list of available wallets */}
        <WalletModalProvider>
          {children}
        </WalletModalProvider>
      </WalletProvider>
    </ConnectionProvider>
  );
}
```

#### Step 3: Use the WalletMultiButton

```jsx
// File: src/components/ConnectButton.jsx
// This is the magic button that handles EVERYTHING

import { WalletMultiButton } from "@solana/wallet-adapter-react-ui";
import { useWallet } from "@solana/wallet-adapter-react";

export default function ConnectButton() {
  // useWallet() gives you the current wallet state
  // This hook works because we're inside the WalletProvider (from Step 2)
  const { publicKey, connected, disconnect } = useWallet();

  return (
    <div>
      {/* WalletMultiButton does EVERYTHING:
          - Shows "Select Wallet" when not connected
          - Opens a modal with all supported wallets
          - Shows the wallet address when connected
          - Provides a dropdown to disconnect or switch wallets
          - Handles all the error states
          - Looks professional out of the box

          That's it. One component. All wallets. Done. */}
      <WalletMultiButton />

      {/* Show wallet info if connected */}
      {connected && (
        <div style={{ marginTop: "20px" }}>
          <p>Connected wallet: {publicKey.toString()}</p>
          <p>
            Shortened: {publicKey.toString().slice(0, 4)}...
            {publicKey.toString().slice(-4)}
          </p>
        </div>
      )}
    </div>
  );
}
```

#### Step 4: Wrap your app

```jsx
// File: src/App.jsx (or _app.jsx in Next.js, or layout.tsx in App Router)

import AppWalletProvider from "./components/WalletProvider";
import ConnectButton from "./components/ConnectButton";

function App() {
  return (
    <AppWalletProvider>
      <div>
        <h1>My Solana App</h1>
        <ConnectButton />
        {/* All your other components go here */}
        {/* They can all use useWallet() to check if user is connected */}
      </div>
    </AppWalletProvider>
  );
}

export default App;
```

That's the React approach. Four files, and you have professional multi-wallet support.

### For Plain HTML / Vanilla JavaScript (No React)

Not everything needs to be a React app. ForgivMe.Life is plain HTML and JavaScript. Here's how to use the wallet adapter concepts without React.

The approach: use a CDN-loaded version of `@solana/web3.js` and handle wallet detection yourself, but with a nicer UI than the raw approach.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Solana Wallet Connection - No Frameworks</title>

  <!-- Load Solana web3.js from CDN - no npm needed -->
  <!-- This gives us the solanaWeb3 global object -->
  <script src="https://unpkg.com/@solana/web3.js@latest/lib/index.iife.min.js"></script>

  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
      max-width: 700px;
      margin: 40px auto;
      padding: 20px;
      background: #0f0f23;
      color: #e0e0e0;
    }
    .wallet-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
    .wallet-btn {
      padding: 12px 24px;
      border: none;
      border-radius: 8px;
      font-size: 15px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .phantom-btn { background: #ab9ff2; color: #1a1a2e; }
    .metamask-btn { background: #f6851b; color: white; }
    .disconnect-btn { background: #ff4444; color: white; }
    .wallet-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    #wallet-info {
      margin: 20px 0;
      padding: 20px;
      background: #1a1a3e;
      border-radius: 10px;
      word-break: break-all;
    }
  </style>
</head>
<body>

  <h1>Multi-Wallet Solana Connection</h1>
  <p>Plain HTML. No React. No build tools. Just works.</p>

  <div class="wallet-buttons">
    <button class="wallet-btn phantom-btn" id="phantomBtn" onclick="connectPhantom()">
      Connect Phantom
    </button>
    <button class="wallet-btn metamask-btn" id="metamaskBtn" onclick="connectMetaMask()">
      Connect MetaMask
    </button>
    <button class="wallet-btn disconnect-btn" id="disconnectBtn"
            onclick="disconnectWallet()" style="display:none;">
      Disconnect
    </button>
  </div>

  <div id="wallet-info">
    <strong>Status:</strong> No wallet connected
  </div>

  <script>
    // State management - track which wallet is connected
    let connectedWallet = null; // "phantom" or "metamask" or null
    let connectedAddress = null;

    // --- PHANTOM ---
    async function connectPhantom() {
      const provider = window.phantom?.solana || window.solana;

      if (!provider?.isPhantom) {
        showInfo("Phantom not installed. <a href='https://phantom.app' target='_blank'>Get it here</a>");
        return;
      }

      try {
        const resp = await provider.connect();
        connectedWallet = "phantom";
        connectedAddress = resp.publicKey.toString();
        onWalletConnected("Phantom", connectedAddress);
      } catch (err) {
        showInfo("Phantom connection rejected: " + err.message);
      }
    }

    // --- METAMASK ---
    async function connectMetaMask() {
      if (!window.ethereum?.isMetaMask) {
        showInfo("MetaMask not installed. <a href='https://metamask.io' target='_blank'>Get it here</a>");
        return;
      }

      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts"
        });
        connectedWallet = "metamask";
        connectedAddress = accounts[0];
        onWalletConnected("MetaMask", connectedAddress);
      } catch (err) {
        showInfo("MetaMask connection rejected: " + err.message);
      }
    }

    // --- SHARED HANDLERS ---
    function onWalletConnected(walletName, address) {
      // Shorten the address for display: "7xKX...sAsU"
      const short = address.slice(0, 4) + "..." + address.slice(-4);

      showInfo(`
        <strong>Connected via ${walletName}</strong><br>
        <strong>Address:</strong> ${address}<br>
        <strong>Short:</strong> ${short}<br>
        <small>Network: Devnet (change in code for mainnet)</small>
      `);

      // Update UI
      document.getElementById("phantomBtn").disabled = true;
      document.getElementById("metamaskBtn").disabled = true;
      document.getElementById("disconnectBtn").style.display = "inline-flex";
    }

    async function disconnectWallet() {
      if (connectedWallet === "phantom") {
        const provider = window.phantom?.solana || window.solana;
        if (provider) await provider.disconnect();
      }
      // MetaMask doesn't have a programmatic disconnect
      // (the user disconnects from within MetaMask)

      connectedWallet = null;
      connectedAddress = null;
      showInfo("<strong>Status:</strong> Disconnected");

      document.getElementById("phantomBtn").disabled = false;
      document.getElementById("metamaskBtn").disabled = false;
      document.getElementById("disconnectBtn").style.display = "none";
    }

    function showInfo(html) {
      document.getElementById("wallet-info").innerHTML = html;
    }

    // Check on page load if already connected
    window.addEventListener("load", () => {
      const phantom = window.phantom?.solana || window.solana;
      if (phantom?.isConnected && phantom?.publicKey) {
        connectedWallet = "phantom";
        connectedAddress = phantom.publicKey.toString();
        onWalletConnected("Phantom", connectedAddress);
      }
    });
  </script>

</body>
</html>
```

This is what I'll probably adapt for forgiveme.life. No React needed. Clean, simple, works.

---

## Sending an SPL Token (Like HellCoin)

Right, connecting the wallet is the handshake. Now let's actually send some tokens. This is where it gets interesting and where I needed to understand some Solana-specific concepts that don't exist in traditional web development.

### What is an SPL Token?

SPL stands for **Solana Program Library**. An SPL token is Solana's version of a custom token - like how ERC-20 is Ethereum's token standard. HellCoin is an SPL token. USDC on Solana is an SPL token. Every fungible token on Solana is an SPL token.

Every SPL token has a **mint address** - this is the unique identifier that says "this is HellCoin, not some other token." It's like a serial number for the token type itself.

### Associated Token Accounts (This Confused Me)

Here's the concept that had me staring at the screen for twenty minutes.

On Solana, you don't just "have tokens in your wallet." Your wallet has a main address (your public key), but for each type of token you hold, there's a separate **Associated Token Account (ATA)**.

Think of it like this:
- Your wallet address is your house
- Each token type gets its own room in the house
- The ATA is the address of that specific room

So if your wallet holds SOL, USDC, and HellCoin:
- You have your main wallet address (the house)
- You have an ATA for USDC (room 1)
- You have an ATA for HellCoin (room 2)
- SOL lives in the main address directly (it's the native token, it gets the living room)

**Why does this matter?** When sending tokens, you need to:
1. Find (or create) the sender's ATA for that token
2. Find (or create) the receiver's ATA for that token
3. Transfer tokens between the ATAs

If the receiver has never held that token before, their ATA doesn't exist yet and needs to be created. This creation costs a tiny amount of SOL (called "rent").

### The Code: Sending SPL Tokens

```javascript
// We need these Solana libraries
// In a Node.js project, install with: npm install @solana/web3.js @solana/spl-token
// For browser, use CDN or a bundler

// Import statements (for Node.js / bundled projects)
// import { Connection, PublicKey, Transaction } from "@solana/web3.js";
// import {
//   getAssociatedTokenAddress,
//   createTransferInstruction,
//   getOrCreateAssociatedTokenAccount,
//   createAssociatedTokenAccountInstruction,
//   getAccount,
//   TOKEN_PROGRAM_ID,
//   ASSOCIATED_TOKEN_PROGRAM_ID
// } from "@solana/spl-token";

async function sendSPLToken(recipientAddressString, amount) {
  // ========================================
  // CONFIGURATION - Change these for your token!
  // ========================================

  // The mint address of HellCoin (or whatever SPL token you're sending)
  // This is the token's unique identifier on the Solana blockchain
  // You get this when you create the token with spl-token create-token
  const HELLCOIN_MINT = new solanaWeb3.PublicKey(
    "YOUR_HELLCOIN_MINT_ADDRESS_HERE"
    // Replace with actual mint address, e.g.:
    // "4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R"
  );

  // How many decimal places does your token use?
  // Most SPL tokens use 9 decimals (like SOL itself)
  // So to send 1 HellCoin, you actually send 1 * 10^9 = 1,000,000,000
  const DECIMALS = 9;

  // Network: devnet for testing, mainnet-beta for real
  const NETWORK = "https://api.devnet.solana.com";

  // ========================================
  // STEP 1: Set up the connection and get the wallet
  // ========================================

  // Create a connection to the Solana network
  // This is how we talk to the blockchain
  const connection = new solanaWeb3.Connection(NETWORK, "confirmed");

  // Get the connected wallet (Phantom in this example)
  const provider = window.phantom?.solana || window.solana;
  if (!provider?.isConnected) {
    throw new Error("Wallet not connected! Connect first.");
  }

  // The sender is whoever is currently connected
  const senderPublicKey = provider.publicKey;

  // The recipient is the address we're sending to
  const recipientPublicKey = new solanaWeb3.PublicKey(recipientAddressString);

  // ========================================
  // STEP 2: Find the Associated Token Accounts
  // ========================================

  // Find the sender's ATA for HellCoin
  // getAssociatedTokenAddress() calculates the ATA address deterministically
  // It doesn't create anything - it just calculates what the address WOULD be
  //
  // Parameters:
  //   HELLCOIN_MINT - which token
  //   senderPublicKey - whose wallet
  //
  // The ATA address is derived from: mint + owner + token program + ATA program
  // This means the same wallet always has the same ATA for the same token
  const senderATA = await getAssociatedTokenAddress(
    HELLCOIN_MINT,
    senderPublicKey
  );

  // Find the recipient's ATA for HellCoin
  const recipientATA = await getAssociatedTokenAddress(
    HELLCOIN_MINT,
    recipientPublicKey
  );

  // ========================================
  // STEP 3: Check if recipient's ATA exists
  // ========================================

  // If the recipient has never held HellCoin, their ATA doesn't exist yet
  // We need to create it (and the sender pays the ~0.002 SOL rent)
  let createATAInstruction = null;

  try {
    // Try to fetch the recipient's token account
    // If it exists, this succeeds silently
    await getAccount(connection, recipientATA);
    console.log("Recipient already has a HellCoin account. Good.");
  } catch (error) {
    // Account doesn't exist - we need to create it
    console.log("Creating HellCoin account for recipient...");

    // createAssociatedTokenAccountInstruction builds the instruction
    // to create the ATA. It doesn't execute it yet - that happens
    // when we send the transaction.
    //
    // Parameters:
    //   senderPublicKey - who pays for account creation (rent)
    //   recipientATA - the address of the account to create
    //   recipientPublicKey - the owner of the new account
    //   HELLCOIN_MINT - which token this account is for
    createATAInstruction = createAssociatedTokenAccountInstruction(
      senderPublicKey,    // payer
      recipientATA,       // new account address
      recipientPublicKey, // new account owner
      HELLCOIN_MINT       // token mint
    );
  }

  // ========================================
  // STEP 4: Build the transfer instruction
  // ========================================

  // Convert human-readable amount to token amount with decimals
  // Example: sending 10 HellCoin with 9 decimals = 10,000,000,000
  const tokenAmount = amount * Math.pow(10, DECIMALS);

  // Create the transfer instruction
  // This tells the token program: move X tokens from sender's ATA to recipient's ATA
  const transferInstruction = createTransferInstruction(
    senderATA,        // from: sender's HellCoin account
    recipientATA,     // to: recipient's HellCoin account
    senderPublicKey,  // authority: who authorises the transfer (the sender)
    tokenAmount       // how many tokens (in smallest unit)
  );

  // ========================================
  // STEP 5: Build and send the transaction
  // ========================================

  // A Transaction is a bundle of instructions that execute together
  // Either all succeed or all fail (atomic)
  const transaction = new solanaWeb3.Transaction();

  // If we need to create the recipient's ATA, add that instruction first
  // Order matters! Create the account BEFORE trying to send tokens to it
  if (createATAInstruction) {
    transaction.add(createATAInstruction);
  }

  // Add the transfer instruction
  transaction.add(transferInstruction);

  // Get a recent blockhash - this is Solana's way of preventing
  // replay attacks and setting a transaction expiry
  // Transactions expire after ~60 seconds if not confirmed
  const { blockhash } = await connection.getLatestBlockhash();
  transaction.recentBlockhash = blockhash;

  // Set the fee payer (the sender pays transaction fees)
  transaction.feePayer = senderPublicKey;

  // ========================================
  // STEP 6: Sign and send via the wallet
  // ========================================

  // This is where Phantom pops up and shows the user what they're signing
  // The user sees: "Transfer X HellCoin to [address]"
  // They click Approve, Phantom signs it with their private key
  // The private key NEVER leaves Phantom
  const signedTransaction = await provider.signTransaction(transaction);

  // Send the signed transaction to the Solana network
  // The network validators process it and add it to the blockchain
  const signature = await connection.sendRawTransaction(
    signedTransaction.serialize()
  );

  // Wait for confirmation
  // "confirmed" means at least one validator has confirmed it
  // "finalized" means it's permanent (takes longer, ~30 seconds)
  await connection.confirmTransaction(signature, "confirmed");

  console.log("Transfer complete!");
  console.log("Transaction signature:", signature);
  console.log(
    "View on Solscan:",
    `https://solscan.io/tx/${signature}?cluster=devnet`
  );

  return signature;
}

// Usage:
// sendSPLToken("RecipientWalletAddressHere", 10)
//   .then(sig => console.log("Sent! Signature:", sig))
//   .catch(err => console.error("Failed:", err));
```

**Every step explained because future David needs to know what he's building, not just that it works.**

---

## Solana Pay Integration

Solana Pay is brilliant for accepting payments. Instead of the user manually connecting their wallet and approving a transaction, you generate a **payment URL or QR code** that opens their wallet app with everything pre-filled.

It's like the difference between giving someone your bank details and asking them to type it all in, versus handing them a pre-filled payment slip. Less friction, fewer mistakes.

### Install Solana Pay

```bash
# The official Solana Pay library
npm install @solana/pay

# You'll also need these (you probably already have them)
npm install @solana/web3.js

# For QR code generation
npm install qrcode
```

### Creating a Payment Request

```javascript
// Solana Pay creates special URLs that wallets understand
// Format: solana:<recipient>?amount=<amount>&spl-token=<mint>&reference=<ref>

import { createQR, encodeURL, TransferRequestURL } from "@solana/pay";
import { PublicKey } from "@solana/web3.js";
import BigNumber from "bignumber.js";

function createPaymentRequest() {
  // ========================================
  // PAYMENT CONFIGURATION
  // ========================================

  // Who receives the payment (your wallet address)
  const recipient = new PublicKey("YOUR_WALLET_ADDRESS_HERE");

  // How much to charge
  // Using BigNumber for precise decimal handling
  // (floating point math is the enemy of money)
  const amount = new BigNumber(10); // 10 HellCoin

  // The SPL token mint address (omit for native SOL payments)
  const splToken = new PublicKey("YOUR_HELLCOIN_MINT_ADDRESS");

  // A unique reference for this payment
  // This is how you track whether a specific payment was made
  // Generate a new keypair and use its public key as the reference
  // (it's just a unique identifier, the private key is discarded)
  const reference = new PublicKey(
    Keypair.generate().publicKey
  );

  // Human-readable label shown in the wallet
  const label = "ForgivMe.Life - Sin Payment";

  // Description shown in the wallet
  const message = "Pay 10 HellCoin for eternal forgiveness";

  // Optional: a link for more info
  const memo = "forgiveness-payment-001";

  // ========================================
  // CREATE THE PAYMENT URL
  // ========================================

  // encodeURL creates the solana: protocol URL
  // This URL contains all the payment details
  const url = encodeURL({
    recipient,    // who gets paid
    amount,       // how much
    splToken,     // which token (omit for SOL)
    reference,    // unique tracking ID
    label,        // display name
    message,      // description
    memo,         // on-chain memo
  });

  console.log("Payment URL:", url.toString());
  // Output: solana:YOUR_ADDRESS?amount=10&spl-token=MINT&reference=REF&label=...

  return { url, reference };
}
```

### Generating a QR Code

```javascript
// Mobile users can scan this QR code with their wallet app
// The wallet reads the solana: URL and pre-fills the payment

function displayQRCode(paymentUrl) {
  // createQR from @solana/pay generates a QR code from the payment URL
  // Options:
  //   width/height: size in pixels
  //   background/color: QR code colors

  const qr = createQR(
    paymentUrl,
    360,    // width in pixels
    "transparent", // background
    "#ffffff"      // QR code color
  );

  // Get the container element and append the QR code
  const container = document.getElementById("qr-container");

  // Clear any existing QR code
  container.innerHTML = "";

  // Append the QR code to the DOM
  qr.append(container);

  console.log("QR code displayed! User can scan with Phantom mobile app.");
}

// Usage:
// const { url, reference } = createPaymentRequest();
// displayQRCode(url);
```

### Verifying the Payment

```javascript
// After showing the QR code or payment link, you need to check
// whether the payment was actually made

import { validateTransfer, findReference } from "@solana/pay";

async function waitForPayment(connection, reference, recipient, amount, splToken) {
  console.log("Waiting for payment...");

  // Poll the blockchain to see if a transaction with our reference exists
  // findReference searches for transactions that include our reference key
  //
  // This is like checking your bank statement for a specific payment reference

  let signatureInfo;

  // Keep checking every 2 seconds until we find the payment
  // In production, you'd add a timeout and error handling
  while (!signatureInfo) {
    try {
      // findReference looks for transactions on-chain that include
      // our unique reference public key
      signatureInfo = await findReference(connection, reference, {
        finality: "confirmed",
      });
      console.log("Payment found! Signature:", signatureInfo.signature);
    } catch (error) {
      // FindReferenceError means no matching transaction found yet
      // Keep waiting
      if (error.name === "FindReferenceError") {
        await new Promise((resolve) => setTimeout(resolve, 2000));
      } else {
        throw error; // Unexpected error
      }
    }
  }

  // ========================================
  // VALIDATE the payment details
  // ========================================

  // Finding a transaction isn't enough - we need to verify:
  // - The right amount was sent
  // - It was sent to the right address
  // - It was the right token
  // Don't skip this! Someone could send 0.001 HellCoin and the
  // findReference would still match.

  try {
    await validateTransfer(
      connection,
      signatureInfo.signature,
      {
        recipient,  // expected recipient
        amount,     // expected amount
        splToken,   // expected token
        reference,  // our reference
      },
      { commitment: "confirmed" }
    );

    console.log("Payment VALIDATED! Correct amount, correct recipient.");
    return true;

  } catch (error) {
    console.error("Payment validation FAILED:", error.message);
    // Someone might have sent wrong amount or wrong token
    return false;
  }
}
```

---

## Security Considerations

Listen, I'm doing a Master's in Cybersecurity. If I write a blog post about crypto integration without a security section, I should hand back my student card. Here's what to keep in mind.

### The Golden Rules

**1. Never store private keys on the server. Ever. EVER.**

```javascript
// WRONG - NEVER DO THIS
const privateKey = "5KdB8sV..."; // You will be robbed
const wallet = Keypair.fromSecretKey(privateKey);

// RIGHT - The wallet extension handles all signing
// Your code NEVER sees the private key
const signedTx = await provider.signTransaction(transaction);
// Phantom signed it internally. You got the result. Key never left the extension.
```

**2. The wallet only signs what the user explicitly approves.**

When you call `provider.signTransaction(tx)`, Phantom/MetaMask pops up a window showing exactly what the transaction does. The user reads it and clicks Approve or Reject. Your website cannot bypass this. This is the security model that makes browser wallets safe.

**3. HTTPS is required.**

Wallet extensions refuse to inject into HTTP pages. This is non-negotiable. If you're developing locally, `localhost` is an exception, but in production, you need SSL.

```
http://mysite.com   --> Wallet will NOT inject (insecure)
https://mysite.com  --> Wallet injects normally (secure)
http://localhost     --> Works for development (special exception)
```

**4. Content Security Policy (CSP) headers.**

If your site uses CSP headers (it should), you need to allow the wallet extensions to communicate:

```html
<!-- In your HTML head or server config -->
<meta http-equiv="Content-Security-Policy"
      content="
        default-src 'self';
        script-src 'self' https://unpkg.com;
        connect-src 'self' https://api.devnet.solana.com https://api.mainnet-beta.solana.com;
      ">
```

**5. Validate everything server-side.**

Never trust the client. If someone claims they paid, verify the transaction on the blockchain from your server. The `validateTransfer` function from Solana Pay does this, but run it on your backend, not in the browser where it can be manipulated.

**6. Watch for phishing patterns.**

Never ask users to enter their seed phrase or private key on your website. Real wallet integration NEVER requires this. If a site asks for your seed phrase, it's a scam. Full stop.

---

## Testing on Devnet First

This section exists because I WILL forget to test on devnet and accidentally send real HellCoin to the void. Future David, read this before deploying ANYTHING.

### What is Devnet?

Solana runs three networks:

| Network | Purpose | SOL Value | URL |
|---------|---------|-----------|-----|
| **Devnet** | Development and testing | Free, fake SOL | api.devnet.solana.com |
| **Testnet** | Validator testing | Free, fake SOL | api.testnet.solana.com |
| **Mainnet-Beta** | The real thing | Real money | api.mainnet-beta.solana.com |

**Devnet is your best friend.** It's an exact copy of Solana's mainnet, but everything is free. Transactions work the same way. Tokens work the same way. But nothing has real value, so mistakes cost nothing.

### Switching Phantom to Devnet

1. Open Phantom
2. Click the gear icon (Settings)
3. Scroll down to "Developer Settings"
4. Click "Change Network"
5. Select "Devnet"
6. Your wallet address stays the same, but you're now on the test network

### Getting Free Test SOL

You need SOL to pay transaction fees (even on devnet). Here's how to get free devnet SOL:

```bash
# Method 1: Solana CLI (if installed)
solana airdrop 2 YOUR_WALLET_ADDRESS --url devnet

# Method 2: Browser - visit the faucet
# https://faucet.solana.com/
# Paste your wallet address, click "Airdrop", get free SOL
```

```javascript
// Method 3: In your code (useful for automated testing)
const connection = new solanaWeb3.Connection(
  "https://api.devnet.solana.com",
  "confirmed"
);

// Request 2 SOL airdrop to your wallet
const airdropSignature = await connection.requestAirdrop(
  yourPublicKey,
  2 * solanaWeb3.LAMPORTS_PER_SOL // 2 SOL in lamports (smallest unit)
);

// Wait for confirmation
await connection.confirmTransaction(airdropSignature);
console.log("Got 2 free devnet SOL!");
```

### Creating a Test SPL Token on Devnet

You can create a test version of HellCoin on devnet for testing:

```bash
# Install Solana CLI tools if you haven't
# sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"

# Switch to devnet
solana config set --url devnet

# Create a new token (this gives you a mint address)
spl-token create-token

# Create a token account for your wallet
spl-token create-account YOUR_TOKEN_MINT_ADDRESS

# Mint some test tokens to yourself
spl-token mint YOUR_TOKEN_MINT_ADDRESS 1000

# Check your balance
spl-token balance YOUR_TOKEN_MINT_ADDRESS
```

### The Devnet Checklist (Before Going to Mainnet)

Before switching a SINGLE line of code from devnet to mainnet-beta, verify:

- [ ] Wallet connection works (connect/disconnect)
- [ ] Token transfers complete successfully
- [ ] Error handling works (reject connection, insufficient balance, etc.)
- [ ] QR code payments work (if using Solana Pay)
- [ ] Payment validation correctly accepts valid payments
- [ ] Payment validation correctly rejects invalid/wrong-amount payments
- [ ] UI shows appropriate loading states
- [ ] UI shows appropriate error messages
- [ ] Works with both Phantom and MetaMask
- [ ] Tested on both desktop and mobile
- [ ] CSP headers don't block anything
- [ ] HTTPS is configured in production

**Only then** change `devnet` to `mainnet-beta` in your connection URL.

---

## David's Battle Plan: ForgivMe.Life Integration

Right, so here's my actual plan for integrating all of this into forgiveme.life. Writing it down so I can't pretend I had a different plan later.

### Current State
- ForgivMe.Life is a plain HTML/CSS/JS website
- Hosted on InMotion Hosting
- HellCoin is registered on Solana token list (PR #15662)
- I have MetaMask working
- Need to locate my Phantom keys (they're somewhere on one of my machines)
- No React, no Next.js - keeping it simple

### The Plan
1. **Phase 1**: Add the vanilla JS wallet connection (Approach 1 & 2 from this post)
2. **Phase 2**: Add a "Pay for your sins" button that sends HellCoin
3. **Phase 3**: Add Solana Pay QR codes for mobile users
4. **Phase 4**: Add a leaderboard of biggest sinners (most HellCoin tipped)

### What I Need to Do First
- Find my Phantom recovery phrase (it's on one of the Macs, I think)
- Create a test HellCoin token on devnet
- Build the integration locally and test thoroughly
- Deploy to forgiveme.life when everything works

One foot in front of the other. Start on devnet. Test everything. Deploy when ready. Come home alive.

---

## Quick Reference: Key Concepts Cheat Sheet

For future David who needs a refresher at 2am:

| Concept | Simple Explanation | Technical Detail |
|---------|-------------------|------------------|
| **Public Key** | Your wallet address, safe to share | Base58-encoded Ed25519 public key |
| **Private Key** | Your wallet password, NEVER share | Secret key for signing transactions |
| **SPL Token** | A custom token on Solana | Solana Program Library token standard |
| **Mint Address** | The ID that makes HellCoin HellCoin | The token's on-chain program address |
| **ATA** | Each token gets its own "room" in your wallet | Associated Token Account, derived from owner + mint |
| **Devnet** | Practice Solana, free fake money | Development network at api.devnet.solana.com |
| **Mainnet** | Real Solana, real money | Production at api.mainnet-beta.solana.com |
| **Lamports** | Smallest SOL unit (like cents to dollars) | 1 SOL = 1,000,000,000 lamports |
| **Blockhash** | Transaction expiry timer | Recent block hash, prevents replay attacks |
| **RPC** | How your code talks to Solana | Remote Procedure Call to validator nodes |

---

## Resources and Sources

These are the docs and guides I used while writing this. Bookmark them.

- [Phantom Integration Docs](https://docs.phantom.com/solana/integrating-phantom) - Official Phantom developer docs. Start here for Phantom-specific features.
- [MetaMask Solana Support](https://metamask.io/news/solana-on-metamask-sol-wallet) - MetaMask's announcement and documentation for Solana integration.
- [Solana Wallet Adapter (Official Cookbook)](https://solana.com/developers/cookbook/wallets/connect-wallet-react) - The official guide to the Wallet Adapter in React.
- [Connect Wallet in 5 Minutes (2025 Edition)](https://medium.com/@palmartin99/connect-any-website-to-solana-wallet-in-5-minutes-2025-edition-for-complete-beginners-fdd205f33f8e) - Great beginner-friendly walkthrough.
- [Solana Pay Docs](https://docs.solanapay.com/core/overview) - Official Solana Pay documentation.
- [@solana/pay on npm](https://www.npmjs.com/package/@solana/pay) - The npm package page with usage examples.
- [Plain JS Phantom Connection](https://javascriptpage.com/javascript-connect-solana-wallet-using-phantom) - Vanilla JavaScript Phantom examples without React.
- [SPL Token Program](https://spl.solana.com/token) - Official docs for the SPL Token program (creating, minting, transferring tokens).
- [NetworkChuck - Creating a Solana Token](https://blog.networkchuck.com/posts/create-a-solana-token/) - NetworkChuck's guide to creating your own Solana token. This is how I made HellCoin.

---

## Final Thoughts

Writing this took me way longer than actually connecting a wallet to a website. But that's the point. I could have asked Claude to generate the code, pasted it in, and called it done. It would have worked. But when it breaks (and it will break), I need to know WHY each piece exists and what it does.

This whole blog exists so that I'm not dependent on AI. The irony of writing that sentence while an AI helps me organise my thoughts is not lost on me. But the knowledge in my head? That's mine. The understanding of what an ATA is, why we check for `window.solana`, what a blockhash does? Future David has that now.

Applied Psychology taught me something about learning: you don't truly understand something until you can teach it. So that's what these posts are. Me teaching myself. Out loud. On the internet. With terrible military metaphors and too many cups of coffee.

Next up: actually implementing this on forgiveme.life. That'll be another post. With screenshots of everything going wrong. Because that's how we learn.

One foot in front of the other. Rangers lead the way.

---

*This post was written as part of my learning journal while pursuing a Masters in Cybersecurity at NCI Dublin. I have dyslexia, ADHD, and autism - and I'm writing technical guides anyway. If I can do this, so can you.*
