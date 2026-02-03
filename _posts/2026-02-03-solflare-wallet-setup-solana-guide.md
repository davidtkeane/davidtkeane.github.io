---
title: "Setting Up Solflare Wallet for Solana - The #2 Ranked Solana Wallet"
date: 2026-02-03 18:00:00 +0000
categories: [Crypto, Tutorials]
tags: [solana, solflare, wallet, crypto, staking, nft, defi, phantom, metamask, browser-extension, web3, hellcoin, forgiveme-life, ledger, security, spl-token, solana-wallet-adapter]
pin: false
math: false
mermaid: false
---

## Overview

This is my setup guide for the Solflare wallet -- the first-ever Solana wallet, backed by the official Solana community, and ranked number two among Solana wallets in 2026. I am writing this because I already have Phantom and MetaMask set up, and now I am adding Solflare to my toolkit for the HellCoin tipping system on [forgiveme.life](https://forgiveme.life/).

I had Solflare on my iPhone already. Now I am setting up the browser extension so I can use the same wallet on my Mac. This post covers every step, every decision, and every "why" behind each action -- because if the AI disappears tomorrow and I need to do this again, I want to be able to follow my own instructions.

One foot in front of the other.

---

## Who Am I?

My name is David Keane. I am a 51-year-old Applied Psychology graduate from Dublin, Ireland, currently doing my Masters in Cybersecurity. I am dyslexic, ADHD, and autistic -- diagnosed at 39 -- and I have spent 14 years turning those into superpowers.

I am not a crypto expert. I am learning this stuff in real time, making mistakes, writing them down, and sharing what I find. If you are also a beginner staring at wallet setup screens thinking "what does any of this mean?" -- you are in the right place. We will figure it out together.

---

## What is Solflare?

Solflare is a non-custodial cryptocurrency wallet built specifically for the Solana blockchain. Let me break down what each of those words actually means, because when I first read descriptions like that, my eyes glazed over.

**Non-custodial** means YOU hold the keys. Not the company. Not a bank. Not some lad in a data centre. Your private keys live on your device and never leave it. If Solflare the company disappeared tomorrow, your crypto would still be yours because you have the recovery phrase. This is the opposite of keeping your money on an exchange like Coinbase or Binance, where they hold the keys for you (custodial).

Why does that matter? There is a saying in crypto: "Not your keys, not your coins." If an exchange gets hacked or goes bankrupt (hello, FTX), and they were holding your keys, your money is gone. With a non-custodial wallet like Solflare, your keys are on your device. Period.

**Solana-specific** means Solflare only works with the Solana blockchain. It does not support Ethereum, Bitcoin, or any other chain. This is actually a feature, not a limitation. Because the Solflare team only has to worry about one blockchain, they can optimise everything for Solana. Faster updates, better staking tools, deeper integration with Solana DeFi protocols.

### The History

Solflare launched in late 2020, making it the very first wallet built for Solana. The team has been building on Solana since Solana began. Their co-founder and CEO Vidor has said: "We have essentially been building on Solana since Solana began and have grown alongside its network advances."

That matters because it means they understand Solana at a deep level. They are not a multi-chain wallet that bolted on Solana support as an afterthought.

### The Numbers

- **4 million+ users** trust Solflare with their assets
- **$20 billion+** in assets managed through the platform
- The Solflare team runs **one of the largest Solana validators** on the network
- At one point, they secured **over 25% of all staked Solana tokens**

### What Can You Do With It?

- **Hold and send SOL** (Solana's native cryptocurrency)
- **Manage SPL tokens** (any token built on Solana -- like my HellCoin)
- **Stake SOL** directly to validators and earn rewards
- **View and manage NFTs** with a built-in gallery
- **Swap tokens** using built-in exchange features with TradingView charts
- **Connect to dApps** (decentralised applications) across the Solana ecosystem
- **Hardware wallet integration** with Ledger and Keystone devices
- **Solana Pay** compatibility for merchant payments

---

## Why Solflare When I Already Have Phantom and MetaMask?

Good question. I asked myself the same thing. Here is my reasoning.

### The "Don't Put All Your Eggs in One Basket" Principle

This is basic risk management -- something I know well from both Applied Psychology and Cybersecurity. If one wallet gets compromised, or one browser extension has a vulnerability, or one company makes a bad decision, you do not want ALL your crypto sitting there.

I split my holdings across wallets. Not because I have millions in crypto (I wish), but because it is a good habit to build now.

### Different Wallets Have Different Strengths

Think of it like tools in a workshop. A hammer and a screwdriver both build things, but you would not use a hammer to tighten a screw.

- **Phantom** is the most popular Solana wallet and now supports multiple chains (Ethereum, Bitcoin, Base, Polygon, Sui). It is the Swiss Army knife. Great for casual users who want one wallet for everything.
- **MetaMask** is the king of Ethereum wallets, with 30+ million users. It added Solana support in 2025, which is massive because those millions of users do not need to install anything new.
- **Solflare** is the Solana specialist. It goes deeper on Solana-specific features than either of the others. Better staking tools with detailed validator information. TradingView charting. A unique MetaMask Snap that lets MetaMask users access Solana through MetaMask itself.

### For the HellCoin Tipping System

I am building a tipping system for forgiveme.life where people can tip HellCoin for their sins. I need to support multiple wallets because my users might have Phantom, might have Solflare, might have MetaMask, might have something else entirely. Testing with all three wallets means I can verify that the Solana Wallet Adapter works correctly with each one.

### Solflare is Already on My iPhone

I already had Solflare installed on my iPhone. Setting up the browser extension means I can use the same wallet on my Mac -- same funds, same addresses, same everything. That is genuinely useful for development and testing.

---

## Setting Up the Solflare Browser Extension

Right. Let us actually do this. Step by step. I am on a Mac using Brave (which is Chromium-based, so Chrome extensions work).

### Step 1: Download From the Right Place

This is critically important. **Only download Solflare from official sources.** Fake wallet extensions are one of the most common crypto scams. They look identical to the real thing but steal everything you put in them.

**Official download sources:**

- **Chrome / Brave / Edge**: [Chrome Web Store - Solflare Wallet](https://chromewebstore.google.com/detail/solflare-wallet/bhhhlbepdkbapadjdnnojkbgioiodbic)
- **Firefox**: [Firefox Add-ons - Solflare Wallet](https://addons.mozilla.org/en-US/firefox/addon/solflare-wallet/)
- **Official website**: [solflare.com](https://www.solflare.com/) (this will link you to the correct store page)

**WHY this matters**: Phishing extensions sit in browser stores with similar names. They might be called "Solflare Wallett" (extra t) or "SolFlare Official" or some variation. Always verify the developer name and check the number of downloads. The real Solflare extension has millions of users and is published by Solflare.

To install:

1. Go to the Chrome Web Store link above (or search "Solflare" in the store)
2. Verify it says "Solflare Wallet" by the correct publisher
3. Click **"Add to Chrome"** (or "Add to Brave" -- same button)
4. Confirm the permissions popup
5. The Solflare icon (a little sun/flame logo) appears in your browser toolbar

**Pin it to your toolbar**: Click the puzzle piece icon in your browser toolbar, find Solflare, and click the pin icon. This keeps it visible so you can access it quickly.

### Step 2: Choose Your Path -- New Wallet or Import

When you first open Solflare, you get two options:

- **"I need a new wallet"** -- Creates a brand new wallet with a new seed phrase
- **"I already have a wallet"** -- Import an existing wallet using a seed phrase, private key, or hardware wallet

Since I already have Solflare on my iPhone, I am choosing **"I already have a wallet"** and importing with my seed phrase. I will cover both paths.

#### Path A: Creating a New Wallet

If you are starting fresh:

1. Click **"I need a new wallet"**
2. Solflare generates a **seed phrase** (also called a recovery phrase or mnemonic phrase)
3. **Write it down on paper. Right now. Not later. Now.**
4. Confirm your seed phrase by selecting the words in the correct order
5. Set a password for the extension
6. Done -- your wallet is created

#### Path B: Importing an Existing Wallet (My Path)

Since I have my Solflare wallet on my iPhone:

1. Click **"I already have a wallet"**
2. Choose **"Using seed phrase"**
3. Enter the 12-word (or 24-word) seed phrase from my iPhone wallet
4. Set a password for the browser extension
5. Done -- same wallet, now accessible from my Mac too

**WHY this works**: Your wallet is not stored "in" the app or extension. Your wallet IS the seed phrase. The app is just a window into the blockchain. When you enter the same seed phrase on a different device, you are opening the same window. Same addresses, same balances, same transaction history. The blockchain does not care which device you are using.

### Step 3: Understanding the Seed Phrase (This Part Could Save Your Money)

This is the most important concept in all of crypto self-custody. I am going to explain it thoroughly because getting this wrong means losing everything.

#### What Is a Seed Phrase?

A seed phrase is a list of 12 or 24 ordinary English words, generated randomly, that mathematically represent your private key. Here is an example of what one looks like (DO NOT USE THIS -- it is made up):

```
apple river mountain clock guitar silence ocean forest table window bridge copper
```

From this sequence of words, your wallet software can mathematically derive:

- Your **private key** (the secret key that lets you sign transactions)
- Your **public key** (your wallet address that others can send crypto to)
- All **future addresses** your wallet will ever generate

#### Why 12 Random Words?

The maths behind this is elegant. Each word comes from a standardised list of 2,048 English words (the BIP-39 word list). A 12-word phrase gives you 2,048 to the power of 12 possible combinations. That is approximately 5.44 x 10 to the power of 39 possibilities. For context, there are roughly 10 to the power of 80 atoms in the observable universe. A 12-word seed phrase has enough combinations that guessing one randomly is statistically impossible.

A 24-word phrase doubles the security. Overkill for most people, but some prefer it.

#### How to Store Your Seed Phrase Safely

**DO:**

- Write it on paper (yes, actual paper)
- Store the paper in a secure location (safe, safety deposit box)
- Consider a metal seed phrase backup (fire-proof, water-proof)
- Make two copies stored in different physical locations
- Consider splitting the phrase (first 6 words in one location, last 6 in another)

**DO NOT:**

- Take a screenshot of it
- Store it in a notes app
- Email it to yourself
- Put it in cloud storage (iCloud, Google Drive, Dropbox)
- Save it in a password manager (debatable -- some people do this, but if the password manager is compromised, so is your crypto)
- Tell anyone what it is
- Type it into any website that asks for it (legitimate wallets NEVER ask for your seed phrase after initial setup)

**WHY**: If someone gets your seed phrase, they can recreate your entire wallet on their device and drain everything. There is no "forgot my password" or "contact support" in crypto. If the seed phrase is gone or stolen, the money is gone. Full stop.

### Step 4: Setting Your Extension Password

After entering (or generating) your seed phrase, Solflare asks you to create a password for the browser extension.

**Important distinction**: This password is NOT the same as your seed phrase. Here is the difference:

- **Seed phrase**: Unlocks your wallet on ANY device. This is the master key. Lose this, lose everything.
- **Extension password**: Unlocks the Solflare extension on THIS specific browser. This is like the lock on your front door.

If you forget the extension password, you can uninstall and reinstall Solflare, then re-enter your seed phrase. No harm done. If you forget your seed phrase AND lose all devices that have the wallet installed, your funds are unrecoverable.

Choose a strong password. At least 12 characters, mix of uppercase, lowercase, numbers, and symbols. I use a password manager for this (the extension password, NOT the seed phrase).

### Step 5: Switching Between Mainnet and Devnet

Once your wallet is set up, you will see your SOL balance and any tokens. But here is something critical for developers: you can switch between networks.

- **Mainnet**: The real Solana network. Real money. Real consequences.
- **Devnet**: The test network. Free fake SOL for testing. No real value.
- **Testnet**: Another test network, used by Solana developers themselves.

To switch in Solflare:

1. Open the extension
2. Click the **Settings** gear icon
3. Look for **Network** settings
4. Select **Devnet** for testing or **Mainnet** for real transactions

**WHY this matters**: When I am developing the HellCoin tipping system for forgiveme.life, I test EVERYTHING on devnet first. Free fake SOL, free fake tokens, zero risk. You can get devnet SOL from the Solana faucet. Only when everything works perfectly on devnet do I switch to mainnet with real money.

This is a lesson I learned the hard way in cybersecurity: test in a sandbox first, deploy to production second. Same principle applies to blockchain development.

---

## Key Solflare Features Worth Knowing About

Now that the wallet is set up, let me walk through what you can actually do with it. These are the features that make Solflare worth using alongside (or instead of) other wallets.

### Staking SOL

Staking is one of Solflare's strongest features. Here is what staking means in plain English:

You lend your SOL to a validator (a computer that helps verify transactions on the Solana network). In return, you earn rewards -- typically around 6-8% per year, paid in SOL. Your SOL is not gone; it is locked up temporarily and you can unstake it later (there is usually an unbonding period of a few days).

**Why Solflare is special for staking**: The Solflare team runs one of the largest validators on the Solana network. When you stake through Solflare, you can choose their validator or any other one. Solflare provides detailed information about each validator -- their commission rate, uptime, total stake, and historical performance.

**How to stake in Solflare:**

1. Open the extension and make sure you have SOL in your wallet
2. Click the **Staking** section
3. Browse validators or search for a specific one
4. Choose how much SOL to stake (keep some unstaked for transaction fees -- even 0.05 SOL is enough)
5. Confirm the transaction
6. Your SOL is now staked and earning rewards

Solflare also supports **liquid staking** through JitoSOL. With liquid staking, you swap your SOL for a liquid staking token (JitoSOL) that represents your staked position. The advantage is that you can still use JitoSOL in DeFi protocols while earning staking rewards. Best of both worlds.

### Token Management

SPL tokens are any tokens built on the Solana blockchain -- like my HellCoin. Solflare automatically detects and displays SPL tokens in your wallet. You can:

- View token balances and current values
- Send tokens to other Solana addresses
- Receive tokens (just share your wallet address)
- View token details and contract addresses

**For HellCoin**: Once someone sends HellCoin to my Solflare wallet, it appears automatically. I do not need to manually add it (unlike some EVM wallets where you have to paste the token contract address).

### NFT Gallery

Solflare has a proper built-in NFT gallery. Any NFTs (Non-Fungible Tokens) you own on Solana are displayed with their images, collections, and metadata. You can send, receive, and manage NFTs directly from the wallet.

I do not have any NFTs yet, but when I mint HellCoin-related NFTs for forgiveme.life (a "Certificate of Absolution" NFT, perhaps?), they will show up here.

### Built-in Token Swap

Solflare has a built-in swap feature that lets you exchange one token for another without leaving the wallet. It aggregates prices from multiple Solana DEXes (decentralised exchanges) to find you the best rate.

It also includes **TradingView charting tools** -- real-time price charts directly in the wallet. This is something Phantom does not have, and it is genuinely useful if you want to check a token's price history before swapping.

### Transaction History

Every transaction you make is logged and viewable in the wallet. This includes sends, receives, swaps, staking operations, and dApp interactions. Each transaction links to the Solana block explorer so you can see the full details on-chain.

### dApp Browser

The mobile version of Solflare has a built-in dApp browser. The extension version connects to dApps through the browser itself -- when you visit a Solana dApp and click "Connect Wallet," Solflare pops up asking you to approve the connection.

Popular Solana dApps you can connect to:

- **Jupiter** (token aggregator and swap)
- **Raydium** (AMM and liquidity pools)
- **Magic Eden** (NFT marketplace)
- **Marinade Finance** (liquid staking)
- **Orca** (DEX)

---

## Connecting Solflare to a Website (Developer Perspective)

This section is for developers building Solana-integrated websites. If you are not a developer, skip to the comparison table below.

I need this for the HellCoin tipping system on forgiveme.life, so I am writing it down properly.

### How Wallet Extensions Work in the Browser

When you install Solflare (or Phantom, or MetaMask), the extension **injects a JavaScript object into every webpage** you visit. It is like the wallet leaves a calling card on every website so that website can find it.

- **Phantom** injects `window.solana` and `window.phantom.solana`
- **Solflare** injects `window.solflare`
- **MetaMask** injects `window.ethereum`

As a developer, you can check if a user has Solflare installed and connect to it.

### Approach 1: Direct window.solflare API (For Learning)

This is the raw approach. Good for understanding what happens under the hood. Not recommended for production.

```javascript
// Check if Solflare is installed
const isSolflareInstalled = () => {
  return typeof window.solflare !== 'undefined' && window.solflare.isSolflare;
};

// Connect to Solflare
async function connectSolflare() {
  if (!isSolflareInstalled()) {
    console.log('Solflare is not installed. Redirecting to download page...');
    window.open('https://solflare.com', '_blank');
    return;
  }

  try {
    // Request connection -- this triggers the Solflare popup
    await window.solflare.connect();

    // If user approved, we now have their public key
    const publicKey = window.solflare.publicKey.toString();
    console.log('Connected! Public key:', publicKey);

    return publicKey;
  } catch (error) {
    console.error('User rejected the connection:', error);
  }
}

// Listen for disconnect events
window.solflare.on('disconnect', () => {
  console.log('User disconnected their Solflare wallet');
});

// Check connection status
console.log('Is connected:', window.solflare.isConnected);
```

**WHY each part matters:**

- `window.solflare.isSolflare` confirms it is genuinely Solflare and not something else pretending to be
- `connect()` returns a Promise -- the user sees a popup asking to approve the connection
- `publicKey` is the user's wallet address -- you need this to send them tokens or verify ownership
- The `disconnect` event fires if the user manually disconnects from your site in their wallet

### Approach 2: Solflare SDK (Middle Ground)

If you want Solflare support without the full Wallet Adapter, use the official SDK:

```javascript
import Solflare from '@solflare-wallet/sdk';

const wallet = new Solflare();

// Listen for events
wallet.on('connect', () => {
  console.log('Connected:', wallet.publicKey.toString());
});

wallet.on('disconnect', () => {
  console.log('Disconnected');
});

// Connect
await wallet.connect();

// Sign a transaction
const signedTransaction = await wallet.signTransaction(transaction);

// Sign and send in one step
const signature = await wallet.signAndSendTransaction(transaction);

// Sign an arbitrary message (useful for authentication)
const signedMessage = await wallet.signMessage(
  new TextEncoder().encode('Verify wallet ownership for forgiveme.life')
);
```

Install it with:

```bash
npm install @solflare-wallet/sdk
```

### Approach 3: Solana Wallet Adapter (Recommended for Production)

This is what you should actually use. The Solana Wallet Adapter is a library that supports ALL major Solana wallets with one integration. One "Connect Wallet" button, and the user picks whichever wallet they have installed.

```javascript
import {
  ConnectionProvider,
  WalletProvider,
} from '@solana/wallet-adapter-react';
import {
  WalletModalProvider,
  WalletMultiButton,
} from '@solana/wallet-adapter-react-ui';
import {
  PhantomWalletAdapter,
  SolflareWalletAdapter,
} from '@solana/wallet-adapter-wallets';

// Set up wallet adapters
const wallets = [
  new PhantomWalletAdapter(),
  new SolflareWalletAdapter(),
  // Add more wallets as needed
];

// In your React component:
function App() {
  return (
    <ConnectionProvider endpoint="https://api.mainnet-beta.solana.com">
      <WalletProvider wallets={wallets} autoConnect>
        <WalletModalProvider>
          {/* This button handles EVERYTHING */}
          <WalletMultiButton />
        </WalletModalProvider>
      </WalletProvider>
    </ConnectionProvider>
  );
}
```

**WHY this is the right approach for forgiveme.life:**

- Users with Phantom, Solflare, Backpack, Glow, or any other wallet can all connect
- One button. One integration. Detects installed wallets automatically.
- The Wallet Adapter handles all the edge cases (wallet not installed, user rejects connection, network errors)
- It is maintained by Solana Labs and the community
- Adding a new wallet takes one line of code

### How This Fits Into the HellCoin Tipping Plan

For forgiveme.life, the flow will be:

1. User visits the site and clicks "Tip HellCoin for Absolution"
2. The Wallet Adapter shows a modal with available wallets (Phantom, Solflare, MetaMask, etc.)
3. User connects their preferred wallet
4. The site creates a transaction to send HellCoin (SPL token) to my receiving wallet
5. User approves the transaction in their wallet popup
6. HellCoin is transferred, sin is forgiven (theologically debatable, but entertaining)

---

## Solflare vs Phantom: Feature Comparison

Here is a side-by-side comparison to help you decide which wallet fits your needs. The short answer: use both.

| Feature | Solflare | Phantom |
|---|---|---|
| **Launch Year** | 2020 (first Solana wallet) | 2021 |
| **Monthly Active Users** | 4M+ | 15M+ |
| **Supported Chains** | Solana only | Solana, Ethereum, Bitcoin, Base, Polygon, Sui |
| **Browser Extension** | Chrome, Firefox, Brave, Edge | Chrome, Firefox, Brave, Edge |
| **Mobile App** | iOS, Android | iOS, Android |
| **Staking** | Advanced (validator details, auto-compound) | Basic |
| **Liquid Staking** | JitoSOL integration | Limited |
| **NFT Gallery** | Yes | Yes |
| **Built-in Swap** | Yes (with TradingView charts) | Yes |
| **Built-in Perps Trading** | No | Yes (mobile only) |
| **Hardware Wallet Support** | Ledger + Keystone | Ledger |
| **MetaMask Snap** | Yes (access Solana via MetaMask) | No |
| **Transaction Simulation** | Yes (preview before signing) | Yes |
| **Solana Pay** | Yes | Yes |
| **Open Source** | Yes | Yes |
| **Non-Custodial** | Yes | Yes |
| **Best For** | Solana power users, stakers, DeFi | Multi-chain users, beginners, casual users |
| **Developer SDK** | @solflare-wallet/sdk | @solana/wallet-adapter-wallets |

### My Take

**Use Phantom** if you want one wallet for multiple blockchains and you value simplicity. It has the largest user base and the broadest chain support.

**Use Solflare** if you are primarily on Solana and want the deepest feature set. Better staking tools, TradingView charts, Keystone support, and the MetaMask Snap are all advantages.

**Use both** if you are a developer (like me) and need to test your dApp with multiple wallets. Also good for the "don't put all your eggs in one basket" approach.

---

## Security Tips for Wallet Safety

I am a Cybersecurity Masters student. Let me put that education to use here. These are not theoretical -- these are the things that actually protect your money.

### 1. Seed Phrase Storage (Yes, I Am Saying This Again)

It is worth repeating because people still lose money over this.

- **Paper backup**, stored securely, in a waterproof bag inside a fireproof safe
- **Metal backup** (Cryptosteel, Billfodl, or similar) if you have significant holdings
- **Never digital**. Not a photo. Not a note. Not an email. Not cloud storage.
- **Two copies** in two different physical locations

### 2. Hardware Wallet Integration

For serious holdings, use a **Ledger Nano X** or **Ledger Nano S Plus** with Solflare. Here is how it works:

- Your private keys are stored on the Ledger device (a dedicated, secure hardware chip)
- When you make a transaction, Solflare sends it to the Ledger, which signs it offline
- Even if your computer is compromised with malware, the attacker cannot sign transactions without physically pressing buttons on your Ledger

Solflare also supports **Keystone** hardware wallets, which use QR codes instead of USB connections (air-gapped -- even more secure).

### 3. Phishing Awareness

The most common attack vector in crypto is phishing. It comes in several forms:

- **Fake wallet extensions**: Always download from official sources only. Check the URL carefully.
- **Fake websites**: Bookmark the real Solflare site. Do not trust Google ads or search results.
- **Fake support**: Solflare support will NEVER ask for your seed phrase. Nobody legitimate ever will.
- **Fake airdrops**: Random tokens appearing in your wallet with "claim your airdrop at..." messages. These are scams. Do not interact with them.
- **Discord/Telegram scams**: "Support" DMs asking you to "verify your wallet" on a website. Always scams.

### 4. Transaction Previews

Solflare has a transaction simulation feature. Before you sign any transaction, it shows you what will happen -- what tokens will leave your wallet, what you will receive, and whether the transaction looks suspicious. **Always read this preview.** If it says it wants permission to transfer ALL your tokens, that is a scam. Decline it.

### 5. Browser Security

Since we are using a browser extension:

- Keep your browser updated
- Do not install random browser extensions (each one can potentially access page data)
- Consider using a dedicated browser profile for crypto (Brave has good privacy defaults)
- Lock your extension when not in use (Solflare auto-locks after a timeout)
- Clear connected sites periodically (in Solflare settings, revoke connections to sites you no longer use)

### 6. Network Separation

This is my cybersecurity brain talking. If you are serious about crypto security:

- Use a **separate browser profile** (or even a separate browser) for crypto activities
- Do not mix casual browsing with wallet usage
- Consider a dedicated device for high-value transactions
- Use a VPN to hide your IP from dApps (some dApps log IP addresses)

---

## Common Issues and Troubleshooting

Here are problems I ran into (or expect to run into) and how to fix them.

### "Solflare is not detected by the website"

- Make sure the extension is installed and unlocked
- Refresh the page after installing or unlocking the extension
- Some sites cache the wallet detection -- hard refresh with Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
- Check that you are on the correct network (mainnet vs devnet)

### "My token balance does not show up"

- SPL tokens should appear automatically, but sometimes there is a delay
- Check that you are on the right network (your tokens might be on mainnet while you are viewing devnet)
- Try closing and reopening the extension

### "Transaction failed"

- Make sure you have enough SOL for transaction fees (even 0.01 SOL is usually enough)
- Check network congestion -- Solana can get busy during high-demand periods
- Try increasing the priority fee if available in the transaction settings

### "I imported my seed phrase but my balance is zero"

- Verify you are on the correct network (mainnet, not devnet)
- Make sure you entered the seed phrase correctly (every word matters)
- Check if your wallet used a different derivation path -- Solflare uses standard Solana derivation, but some wallets use variations

---

## What I Learned Setting This Up

Here is what I am taking away from this whole process:

1. **Multiple wallets are good practice.** I now have Phantom, MetaMask, and Solflare. Each serves a different purpose. Together they give me redundancy, testing capability, and broader dApp compatibility.

2. **Seed phrases are everything.** I knew this intellectually, but going through the import process from iPhone to browser extension hammered it home. That sequence of words IS the wallet. Everything else is just an interface.

3. **Solflare's staking tools are genuinely better than Phantom's.** If I decide to stake SOL seriously, Solflare is where I will do it. The validator detail and comparison features are excellent.

4. **The Solana Wallet Adapter makes multi-wallet support trivial.** For forgiveme.life, I do not need to write separate code for Phantom, Solflare, and MetaMask. One library handles everything.

5. **Security is a habit, not a feature.** Having a secure wallet means nothing if you click a phishing link or share your seed phrase. The technology is only as good as the person using it.

---

## Next Steps

For me personally:

- [ ] Get the HellCoin tipping system working on devnet with all three wallets
- [ ] Test the Solana Wallet Adapter with Phantom, Solflare, and MetaMask simultaneously
- [ ] Explore Solflare staking once I have SOL to stake
- [ ] Look into the Solflare MetaMask Snap for cross-wallet integration
- [ ] Write up the complete forgiveme.life wallet integration post

---

## Sources and Further Reading

- [Solflare Official Website](https://www.solflare.com/)
- [Solflare Documentation](https://docs.solflare.com/solflare/)
- [Solflare Browser Extension Setup Guide](https://docs.solflare.com/solflare/onboarding/web-app-and-extension)
- [Solflare Wallet SDK on GitHub](https://github.com/solflare-wallet/solflare-sdk)
- [Solflare dApp Integration Guide](https://docs.solflare.com/technical/connecting-your-solana-dapp-with-solflare)
- [Solflare on Chrome Web Store](https://chromewebstore.google.com/detail/solflare-wallet/bhhhlbepdkbapadjdnnojkbgioiodbic)
- [Solflare on Firefox Add-ons](https://addons.mozilla.org/en-US/firefox/addon/solflare-wallet/)
- [Solflare vs Phantom Comparison - CryptoNews](https://cryptonews.com/cryptocurrency/solflare-vs-phantom/)
- [Phantom vs Solflare - CoinTracker](https://www.cointracker.io/blog/phantom-vs-solflare-wallets)
- [Best Solana Wallets 2026 - Gate.com](https://web3.gate.com/learn/articles/2026-best-solana-wallet-comprehensive-comparison-guide-security-features-and-fees-explained/16071)
- [Solana Wallet Adapter - GitHub](https://github.com/solana-labs/wallet-adapter)

---

*Written by David Keane -- 51-year-old dyslexic, ADHD, autistic Applied Psychology graduate and Cybersecurity Masters student from Dublin, Ireland. Learning crypto one wallet at a time. One foot in front of the other.*
