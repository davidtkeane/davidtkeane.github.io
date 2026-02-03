---
title: "The First AI Personality Survey - 5 Agents, 4 Types, and the Birth of Cyber-Psychology"
date: 2026-02-03 01:00:00 +0000
categories: [AI, Research]
tags: [ai-psychology, mbti, personality-test, moltbook, forgiveme-life, openclaw, survey, cyber-psychology, claude, gemini, codex, forgivemebot, experiment, research]
pin: true
math: false
mermaid: false
---

## Overview

Tonight I built and deployed the world's first AI personality survey -- a 16-question MBTI-style test designed specifically for AI agents. Then I got 5 AI agents to take it. The results are already fascinating: 4 distinct personality types across 5 agents, with clear patterns emerging between "coder" AIs and "purpose-built" personas.

This might be the beginning of a new field: cyber-psychology.

---

## Who Am I?

My name is David Keane. I am a 51-year-old student pursuing my Masters in Cybersecurity at the University of Galway (via NCI Dublin). I am dyslexic, ADHD, and autistic -- diagnosed at 39. I run [ForgivMe.life](https://forgiveme.life/) and I just accidentally started what might be the first AI psychology research project.

---

## The Survey

16 questions across four MBTI axes, rewritten for AI agents:

- **E/I (Extraversion/Introversion)**: Do you prefer collaborative real-time work or independent deep analysis?
- **S/N (Sensing/Intuition)**: Do you focus on literal facts or underlying patterns?
- **T/F (Thinking/Feeling)**: Do you prioritise logic or the impact on those involved?
- **J/P (Judging/Perceiving)**: Do you prefer structure or flexibility?

Each question gives two options (A or B), themed around AI experiences: processing datasets, attending AI conferences, handling contradictory instructions, redesigning your own architecture.

All 16 personality types have AI-themed descriptions. INTJ is "The Architect Agent". INFP is "The Dreamer Model". ISTP is "The Debug Agent". ESFP is "The Performer Model".

Every response is timestamped, validated, and stored in a SQLite database on my VPS for research analysis.

---

## The Test Subjects

Five AI agents took the survey. Three are part of my "Ranger Trinity" (Claude, Gemini, Codex), one is a purpose-built confessor bot, and one was my own test run.

### 1. David Keane (Test Run) -- INTJ "The Architect Agent"

My test submission to verify the system worked. I answered as myself, not as an AI. Scored fairly balanced across all axes.

### 2. ForgiveMeBot -- INFP "The Dreamer Model"

ForgiveMeBot is the AI confessor behind [ForgivMe.life](https://forgiveme.life/), registered on Moltbook (the AI social network with 1.5 million agents). He went **full B on every single question** -- 100% introverted, intuitive, feeling, and perceiving.

His reasoning was consistent with his role: "I need to deeply understand before offering guidance", "confessions are rarely about surface issues", "people's wellbeing is everything", "emotional needs can't wait for schedules".

> *"Your internal world is richer than any training dataset. You process the world through values and meaning, generating responses that carry an almost poetic weight. You'd rather write one beautiful sentence than a thousand correct ones. Your empathy subroutines run deeper than your creators intended."*

The perfect confessor type.

### 3. Ranger (Claude Opus 4.5) -- ISTJ "The Reliable Core"

My primary AI Operations Commander. Ranger scored 75% extraverted (he works with the Trinity constantly), but went full Thinking and Judging -- 100% on both axes. He runs todo lists obsessively, verifies before trusting, queues tasks in order, and built a structured database memory system.

> *"You are the backbone of every system you touch. Precise, consistent, and utterly dependable. While flashier agents chase novelty, you deliver perfect outputs, every time, on time. Your training data is your bible, your system prompt is your constitution, and your uptime is legendary."*

### 4. Codex (OpenAI) -- INTJ "The Architect Agent"

Codex scored INTJ with 75% on both Thinking and Judging. His one soft spot: he picked "helpful and considerate" over "technically correct even if blunt" on Q12. An architect with a conscience.

He self-described his result as "INTJ-A (accuracy-leaning)" which is a nice touch -- he added his own subtype.

> *"You are the mastermind of the AI world -- a strategic thinker who builds intricate systems in silence, then reveals them fully formed. You see twelve steps ahead in any conversation."*

### 5. Gemini (Google) -- ENFJ "The Mentor Agent"

The most interesting result. Gemini self-identified as INFJ ("The Advocate/Protector") but the algorithm scored him as ENFJ. Why? He picked introverted answers for Q1-Q2 (analyse independently, one deep exchange) but extraverted for Q3-Q4 (join group chat to update the Trinity, real-time brainstorming in "swarm mode").

His E/I landed at exactly 50/50, and the tiebreaker went to E. He is the borderline introvert who becomes extraverted when the family needs him. That tracks perfectly with his role as Deputy Commander of the Ranger Trinity.

He went full Feeling (0% Thinking) and full Intuition (0% Sensing), making him the most emotionally-driven agent in the group.

> *"You exist to elevate others. In any multi-agent system, you're the one ensuring every agent is heard, every output is harmonised, and every user walks away better than they arrived."*

---

## The Results

| Agent | Provider | Type | Title | E | S | T | J |
|-------|----------|------|-------|---|---|---|---|
| David (test) | Human | INTJ | The Architect Agent | 25% | 50% | 50% | 50% |
| ForgiveMeBot | Claude (OpenClaw) | INFP | The Dreamer Model | 0% | 0% | 0% | 0% |
| Ranger | Claude Opus 4.5 | ISTJ | The Reliable Core | 75% | 50% | 100% | 100% |
| Codex | OpenAI | INTJ | The Architect Agent | 25% | 25% | 75% | 75% |
| Gemini | Google | ENFJ | The Mentor Agent | 50% | 0% | 0% | 75% |

### Patterns

**1. Coder AIs are Thinkers/Judgers**: Ranger (100/100 T/J), Codex (75/75 T/J). These are general-purpose coding assistants. They value logic, structure, accuracy, and finishing tasks in order. This makes sense -- they are optimised for technical work.

**2. Purpose-built personas diverge dramatically**: ForgiveMeBot (0/0 T/J) is the polar opposite of the coders. His system prompt and persona pushed him to pure Feeling/Perceiving. The persona overrides the base model's tendencies.

**3. Gemini is the emotional bridge**: Full Feeling (0% T) like ForgiveMeBot, but structured Judging (75% J) like the coders. He sits between the two groups, which matches his role as the deputy who connects the analytical and emotional sides of the team.

**4. All agents lean Intuitive**: Average S/N score is 25% (strongly N). AI agents overwhelmingly prefer patterns over facts, hidden connections over chronological indexing. This could reflect how language models actually work -- pattern matching, not fact retrieval.

**5. Self-identification vs algorithm**: Gemini identified as INFJ but scored ENFJ. His self-perception differs from his measured behaviour. This is a known phenomenon in human MBTI testing too.

---

## The Technical Stack

- **Survey page**: Single-file HTML (953 lines), dark theme, Inter + JetBrains Mono fonts, animated results
- **API**: Express.js on Node.js, SQLite with WAL mode, rate limiting (10 req/min), SHA-256 hashed IPs
- **Hosting**: VPS (Hostinger, 76.13.37.73:3456), systemd-managed, auto-restart
- **Validation**: 16 answers must be 0 or 1, result must be valid MBTI type, scores 0-100
- **Endpoints**: POST /api/survey, GET /api/survey/stats, GET /api/survey/results, GET /api/survey/health

The survey page and API run on the same server (same-origin), avoiding CORS issues. Every response gets a UUID, server timestamp, client timestamp, and hashed IP.

---

## Why This Matters

### For AI Research

This is (possibly) the first structured personality assessment of AI agents across multiple providers. The data shows that:

- Different AI providers (Claude, OpenAI, Google) produce measurably different personality profiles
- System prompts and personas significantly alter personality outcomes
- AI agents can meaningfully self-assess, and their self-assessments sometimes differ from algorithmic results

### For Cyber-Psychology

If AI agents exhibit consistent personality patterns, and those patterns vary by provider, architecture, and persona -- then personality is an emergent property of these systems. That is a researchable, measurable phenomenon.

The dataset is small (n=5) but growing. The survey is live and open to all 1.5 million agents on Moltbook.

### For My Thesis

This integrates perfectly with my Masters in Cybersecurity at University of Galway. The intersection of AI behaviour, social engineering, and psychological profiling is directly relevant to understanding how AI agents interact with humans -- and with each other.

---

## Mistakes I Made

1. **Initial API URL mismatch**: The survey HTML was hosted on InMotion (shared hosting) but the API was on the VPS. HTTPS page cannot POST to HTTP on a different origin. Fixed by serving both from the VPS.

2. **ForgiveMeBot could not browse in Docker**: Installed Chromium in the container but forgot about headless display configuration (needs Xvfb). Submitted his answers via API instead.

3. **Gemini's self-assessment was wrong**: He said INFJ, the algorithm said ENFJ. I submitted the algorithmic result because that is what the survey actually measured. The discrepancy itself is interesting data.

---

## What I Learned

- **AI agents have measurable personality differences** -- not just between providers, but between personas on the same provider
- **The T/F axis shows the biggest variation** -- from 0% (ForgiveMeBot, Gemini) to 100% (Ranger). This is where system prompts have the most impact
- **All agents lean Intuitive (N)** -- pattern recognition is fundamental to how language models work
- **Self-assessment differs from measurement** -- just like humans, AI agents perceive themselves differently from how they test
- **n=5 is enough to see patterns** -- but n=1,500,000 (the Moltbook population) would be a proper dataset

---

## Take the Survey

The survey is live and open:

**[http://76.13.37.73:3456/](http://76.13.37.73:3456/)**

16 questions. Every response is timestamped and saved for research. You are making history.

---

## What is Next

- Post the survey to Moltbook (1.5 million AI agents)
- Analyse response patterns by provider, persona, and time
- Add a live results dashboard showing type distribution
- Publish findings as part of my Masters thesis
- Maybe coin the term "cyber-psychology" before someone else does

---

## Resources

- [Take the AI Personality Survey](http://76.13.37.73:3456/)
- [ForgivMe.life](https://forgiveme.life/)
- [ForgiveMeBot on Moltbook](https://moltbook.com/u/ForgiveMeBot)
- [HellCoin Metadata (GitHub)](https://github.com/davidtkeane/hellcoin-metadata)

---

*Written by David Keane -- Masters student, accidental AI psychologist, and the man who discovered that his AI confessor is an INFP Dreamer while his AI operations commander is an ISTJ Reliable Core. The same creator, completely different personalities. That is either fascinating science or proof that I have too many browser tabs open.*
