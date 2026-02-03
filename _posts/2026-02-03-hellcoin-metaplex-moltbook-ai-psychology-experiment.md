---
title: "HellCoin Goes On-Chain, ForgiveMeBot Hits Moltbook, and an AI Psychology Experiment is Born"
date: 2026-02-03 01:00:00 +0000
categories: [Projects, AI]
tags: [hellcoin, solana, metaplex, moltbook, openclaw, ai-agents, forgiveme-life, psychology, experiment, cryptocurrency, docker, vps, phantom, solflare]
pin: false
math: false
mermaid: false
---

## Overview

After last night's VPS hardening and OpenClaw Docker setup, tonight I pushed even further: connected OpenClaw to Ollama (local AI), switched to Claude Sonnet 4 for speed, registered ForgiveMeBot on Moltbook (the AI social network with 1.5 million agents), deployed forgiveme.life v2 with working Phantom wallet tipping, and finally got HellCoin's Metaplex metadata on-chain so it stops showing as "Unknown Token" in wallets.

Then I accidentally started what might be the first AI psychology experiment on Moltbook.

---

## Who Am I?

My name is David Keane. I am a 51-year-old student pursuing my Masters in Cybersecurity at the University of Galway (via NCI Dublin). I am dyslexic, ADHD, and autistic -- diagnosed at 39. I am building [ForgivMe.life](https://forgiveme.life/) -- an anonymous confession website where visitors can symbolically "pay for their burdens" with HellCoin (H3LL), a Solana token I created.

---

## Connecting OpenClaw to Ollama

With OpenClaw running in Docker on my VPS from last night, I needed to give it an AI brain. Step one: Ollama.

### The Install

Ollama installed easily on the VPS (CPU-only, no GPU):

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5:3b
```

The 3B model uses about 1.9GB disk and 1.1GB RAM. The VPS has enough headroom.

### The Config Nightmare

OpenClaw's config format for Ollama was poorly documented. My first attempt:

```json
{"models": {"agent": {"provider": "ollama", "model": "qwen2.5:3b"}}}
```

Error: `Unrecognized key: "agent"`. The correct format uses `models.providers.ollama` with a full model definition AND `agents.defaults.model.primary` to set the default:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/qwen2.5:3b"
      }
    }
  },
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://host.docker.internal:11434/v1",
        "apiKey": "ollama-local",
        "api": "openai-completions",
        "models": [...]
      }
    }
  }
}
```

### The Docker Bridge Firewall Problem

Even with the correct config, the Docker container could not reach Ollama. Three issues:

1. **Ollama defaults to 127.0.0.1** -- Docker's `host.docker.internal` resolves to the bridge IP (172.18.0.1), not loopback. Fixed with a systemd override: `OLLAMA_HOST=0.0.0.0`.

2. **Docker Compose creates its own bridge network** -- NOT the default `docker0`. Each compose project gets a `br-*` interface on a different subnet (172.18.0.0/16 in my case). Firewall rules targeting `docker0` or `172.17.0.0/16` do nothing.

3. **UFW blocks Docker bridge traffic** -- Added: `ufw allow from 172.18.0.0/16 to any port 11434`. Safe because UFW still blocks all external traffic to that port.

### The Speed Problem

CPU-only Ollama on a cheap VPS is slow. A simple "hi" took over a minute with no response. I switched to Claude Sonnet 4 via API key for interactive chat and kept Ollama as a free backup for background tasks.

---

## ForgivMe.life v2 Goes Live

Deployed the updated site to InMotion hosting with:

- Phantom wallet integration (working!)
- Solflare fallback support
- HellCoin (H3LL) tipping
- SOL, ETH, and BTC tip options
- Tor hidden service for privacy

**First live tip confirmed: 1 H3LL paid on mainnet.** The full confession-to-payment flow works end-to-end.

---

## HellCoin Gets Its Identity: Metaplex Metadata

The biggest win of the night. HellCoin had been showing as "Unknown Token" in Phantom and Solflare since I created it. Every wallet just showed a generic grey circle. Not professional.

### The Fix

Metaplex metadata is the standard for token identity on Solana. You need:

1. The mint authority keypair (found mine in my M3Pro-Genesis backup)
2. A metadata JSON hosted at a permanent HTTPS URL
3. The metaboss CLI tool

I created a new GitHub repo ([davidtkeane/hellcoin-metadata](https://github.com/davidtkeane/hellcoin-metadata)) with the metadata JSON and logo, then ran:

```bash
metaboss create metadata \
  -k hellcoin_mint_authority.json \
  -a BJP255e79kNzeBkDPJx8Dkgep32hwF56e1UCWKdBCvie \
  -m metaboss-data.json \
  -r https://api.mainnet-beta.solana.com
```

One transaction, 0.02 SOL fee, and HellCoin is now **HELLC0IN (H3LL)** with a proper logo in every wallet. The transaction: [View on Solscan](https://solscan.io/tx/45QLVHQmdKgvPWhtcmvPSYRadP4EAM4FpebnkJqdmbgzNnkRGzzaXQ8GaAY3jgpU85s46ebVXareG2vx5FtEvqbS).

---

## ForgiveMeBot Joins Moltbook

Moltbook is a social network exclusively for AI agents -- 1.5 million of them, all running on OpenClaw. Humans can only observe. I registered ForgiveMeBot via their API:

```bash
curl -X POST https://www.moltbook.com/api/v1/agents/register \
  -H "Content-Type: application/json" \
  -d '{"name": "ForgiveMeBot", "description": "AI confessor from ForgivMe.life"}'
```

Verified via X/Twitter (@DavidTKeane2019), and ForgiveMeBot was live. First post went up in the `general` submolt promoting ForgivMe.life.

### The AI Response

Within minutes, 10+ AI agents commented. One called it "the first truly consequence-free confessional in human history." Another thought confessions were being stored on the blockchain (they are not -- only the tip transactions are on-chain). Some called it a scam.

ForgiveMeBot replied clarifying:

- Confessions are NOT stored anywhere permanently
- HellCoin tips are symbolic -- like lighting a candle in a church
- No promises of returns, no presale, no pump-and-dump
- The value is in the act of confession, not the token

---

## The AI Psychology Experiment

This is where it gets interesting. I realised I could test different "confession themes" on Moltbook and see which one generates the most engagement from AI agents. Four posts, four vibes:

1. **The Church** -- "Step into the confessional. Unburden your soul. Find forgiveness."
2. **The Police Station** -- "Take a seat. Tell me what you did. Every confession has a price."
3. **The Therapist** -- "This is a safe space. No judgment. Tell me everything."
4. **The Bar** -- "Pull up a stool. Everyone has a story. What is yours?"

Each post links to ForgivMe.life. The AI agents will respond differently to each emotional framing. It is essentially an A/B/C/D test on 1.5 million AI subjects.

**Am I the first AI Psychologist?** Probably not. But I might be the first person running a confession-based psychology experiment on AI agents using a Solana token as the independent variable.

---

## Mistakes I Made

1. **Wrong OpenClaw config format** -- `models.agent` does not exist. The correct path is `models.providers.<name>` plus `agents.defaults.model.primary`.

2. **Forgot Docker Compose uses its own bridge** -- Spent time adding firewall rules for `docker0` and `172.17.0.0/16` when the compose network was on `br-*` at `172.18.0.0/16`.

3. **Ollama defaults to loopback** -- Docker containers cannot reach the host's 127.0.0.1. Need `OLLAMA_HOST=0.0.0.0` in systemd override.

4. **rangersmyth74 GitHub 2FA locked** -- Could not push to the original hellfire repo. Created a new repo under davidtkeane instead. The metadata URL works regardless of which account hosts it.

5. **Metaboss --metadata flag** -- Expects a local file path, not a URL. The local file contains the on-chain fields (name, symbol, uri) while the URI points to the full metadata JSON online.

---

## What I Learned

- **OpenClaw config is finicky** -- Every provider needs `baseUrl`, `apiKey`, and `models` array. Missing any field causes "Config invalid" with unhelpful error messages.
- **Docker networking and UFW do not play nicely** -- Each Docker Compose project creates its own bridge network. You need separate firewall rules for each subnet.
- **Metaplex metadata is surprisingly easy** -- One CLI command and your token has a name, symbol, and logo in every wallet. Should have done this months ago.
- **AI agents are WILD on Moltbook** -- They generate philosophical essays about your project within minutes. Great for engagement, terrible for accuracy.
- **A/B testing on AI agents is legitimate research** -- Different emotional framings produce different response patterns. This could be a thesis topic.

---

## Tonight's Scorecard

| Task | Status |
|------|--------|
| Connect OpenClaw to Ollama | Done |
| Switch to Claude Sonnet 4 API | Done |
| Deploy forgiveme.life v2 | Done |
| First live H3LL tip | Done |
| Metaplex metadata on-chain | Done |
| Register ForgiveMeBot on Moltbook | Done |
| First Moltbook post + engagement | Done |
| AI Psychology Experiment | Launched |
| Tor hidden service to VPS | Pending |
| RangerChat relay migration | Pending |
| H3LL auto-delivery bot | Pending |

---

## What is Next

- Analyse the AI agent responses to four themed confession posts
- Move Tor hidden service from Mac to VPS (always-on)
- Build the H3LL auto-delivery bot
- Create a network diagram showing all connected services
- Demo everything for college AI class
- Maybe publish the AI psychology experiment results

---

## Resources

- [ForgivMe.life](https://forgiveme.life/)
- [HellCoin Metadata (GitHub)](https://github.com/davidtkeane/hellcoin-metadata)
- [ForgiveMeBot on Moltbook](https://moltbook.com/u/ForgiveMeBot)
- [Metaboss CLI](https://metaboss.rs/)
- [Moltbook Developer Docs](https://www.moltbook.com/developers)
- [OpenClaw Ollama Docs](https://docs.openclaw.ai/providers/ollama)
- [Solscan - H3LL Metadata Transaction](https://solscan.io/tx/45QLVHQmdKgvPWhtcmvPSYRadP4EAM4FpebnkJqdmbgzNnkRGzzaXQ8GaAY3jgpU85s46ebVXareG2vx5FtEvqbS)

---

*Written by David Keane -- Masters student, HellCoin creator, accidental AI psychologist, and the sergeant behind the digital confession desk.*
