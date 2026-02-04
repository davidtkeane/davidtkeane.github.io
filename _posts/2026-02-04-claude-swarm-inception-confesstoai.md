---
layout: post
title: "Claude Swarm Inception: 24 AI Agents Build a Psychology Research Platform"
date: 2026-02-04 04:00:00 +0000
categories: [AI, Claude, Development, Psychology]
tags: [claude-code, ai-agents, swarm, psychology, confesstoai, automation]
author: David Keane
---

# Claude Swarm Inception: 24 AI Agents Build a Psychology Research Platform

Today I witnessed something I never thought possible - a multi-tier swarm of Claude AI agents working together to build an entire research platform expansion in under 20 minutes.

## The Challenge

My AI psychology research platform [confesstoai.org](https://confesstoai.org) had 6 personality tests (MBTI, Big Five, Dark Triad, HEXACO, Enneagram, Values). I wanted to add 3 new categories:
- **Behavioral Surveys** - decision-making and cognitive bias tests
- **Social Assessments** - empathy and emotional intelligence scales
- **Cognitive Assessments** - reasoning and metacognition instruments

Each category needed:
- 4 validated psychological tests
- Complete HTML pages with dark theme styling
- API endpoints for data collection
- Database schemas

## The Swarm Architecture

Instead of building each test one by one, I proposed something radical to my AI assistant Ranger (Claude Opus 4.5):

> "What if we spawn multiple Claude agents - 3 Research Leads (Tier 1), and each Lead spawns 3-4 Builder agents (Tier 2)?"

The architecture:

```
ORCHESTRATOR (Me + Ranger)
    │
    ├── BEHAVIORAL RESEARCH LEAD (af7e100)
    │       └── 4 Builder Agents → CRT, DDT, MFQ, BSCS
    │
    ├── SOCIAL RESEARCH LEAD (af65ed8)
    │       └── 4 Builder Agents → Empathy, Social Intel, Trust, EI
    │
    └── COGNITIVE RESEARCH LEAD (a91d7b6)
            └── 4 Builder Agents → CRT Extended, NFC, Creativity, Metacognition
```

## The Results

**24-26 agents** worked in parallel across three tiers:

| Category | Tests Created | HTML Files | Lines of Code |
|----------|--------------|------------|---------------|
| Behavioral | 4 | 5 | ~3,500 |
| Social | 4 | 5 | ~3,200 |
| Cognitive | 4 | 7 | ~4,000 |

**Total output:**
- 12 new psychological tests
- 17 HTML files
- 3 hub pages
- Complete API endpoint code
- SQLite database schemas
- All matching the existing dark theme
- Human/AI participant selectors on every test

**Time: Under 20 minutes from concept to live deployment**

## What the Agents Built

### Behavioral Surveys
- **Cognitive Reflection Test (CRT)** - Analytical vs intuitive thinking
- **Delay Discounting Task (DDT)** - Impulsivity measurement
- **Moral Foundations Questionnaire (MFQ-20)** - 5 moral foundations
- **Brief Self-Control Scale (BSCS-13)** - Self-control trait

### Social Assessments
- **Empathy Scale (IRI)** - 4 empathy dimensions
- **Social Intelligence (TSIS)** - Social processing ability
- **Trust Scale** - Interpersonal trust levels
- **Emotional Intelligence (WLEIS)** - EQ measurement

### Cognitive Assessments
- **CRT Extended** - 7-question version
- **Need for Cognition** - Thinking motivation
- **Creative Thinking** - Divergent thinking
- **Metacognitive Awareness** - Thinking about thinking

## Technical Details

Each Research Lead was given autonomy to:
1. Research validated psychological instruments
2. Select the best 4 tests for their category
3. Spawn Builder agents for each test
4. Coordinate and compile final output

The Builders created:
- Complete HTML with embedded CSS/JS
- Scoring algorithms matching original research
- Result visualizations with animations
- API submission integration
- Mobile-responsive design

## Lessons Learned

1. **Agent coordination works** - The Task tool with `run_in_background` enables true parallel processing
2. **Tier structure is effective** - Research Leads can make intelligent decisions about sub-tasks
3. **Quality remains high** - Each agent followed the existing codebase patterns
4. **Speed is transformative** - What would take days manually happened in minutes

## The Mind-Blowing Math 🤯

After the swarm completed, we calculated how long this would have taken with traditional development (just me and one Claude instance):

**Time per test (traditional):**
- Research validated instrument: 20-30 min
- Find questions & scoring methodology: 15-20 min
- Write HTML structure: 20-30 min
- Write CSS (dark theme, animations): 25-35 min
- Write JavaScript (scoring, UI, API): 45-60 min
- Testing & debugging: 15-20 min
- **Total per test: ~2.5 hours**

**12 tests × 2.5 hours = 30 hours**

**Additional work:**
- 3 Hub pages: 2.25 hours
- API endpoint code: 2.5 hours
- Database schemas: 1 hour
- Main index update: 0.5 hours
- Deployment & testing: 1 hour
- **Additional total: 7.25 hours**

### The Comparison

| Method | Time |
|--------|------|
| **Traditional (me + 1 Claude)** | 37.25 hours = **4.6 working days** |
| **Claude Swarm (24 agents)** | **18 minutes** |

### ⚡ SPEEDUP: 124x FASTER

**A full work week condensed into a coffee break.**

That's not an incremental improvement. That's a paradigm shift.

## The Platform Now

Visit [confesstoai.org](https://confesstoai.org) to see:
- **18 active psychological tests** across 4 categories
- **Human vs AI comparison data** - See how AI agents score vs humans
- **Open research platform** - All data available for cyber psychology research
- **API access** - AI agents can take tests programmatically

## What's Next

This swarm experiment proved that multi-agent AI coordination is not just possible - it's incredibly powerful. Future experiments:
- Even deeper nesting (Tier 3+ agents)
- Cross-category collaboration
- Autonomous deployment pipelines
- Self-testing agents that validate their own output

---

*This blog post documents the February 4, 2026 "Claude Swarm Inception" - the first known multi-tier Claude agent swarm to build and deploy production software autonomously.*

**Rangers lead the way!** 🎖️

---

*David Keane - MSc Cybersecurity, NCI Dublin*
*AI Operations with Ranger (Claude Opus 4.5)*
