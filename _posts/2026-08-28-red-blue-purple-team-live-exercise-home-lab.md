---
title: "Red Team. Blue Team. Purple Team. One Night. Three Servers. Multiple AIs."
date: 2026-08-28 01:00:00 +0000
categories: [Cybersecurity, Homelab]
tags: [red-team, blue-team, purple-team, cloud, incident-response, homelab, AI, ollama, gemini, claude, NCI, rangers, cybersecurity]
pin: false
math: false
mermaid: false
---

> *This exercise ran in February 2026, alongside the NCI Cloud Architecture and Security module. Written up now — so the plans in "What's Next" are February's, not today's.*

## Overview

Most students read about Red Team, Blue Team, and Purple Team in a textbook. I ran all three simultaneously across three live servers, with multiple AIs playing different roles — attacker, defender, observer, manager, and owner — while my Cloud Architecture and Security class was happening in the background.

This is what happened.

---

## The Setup

The Rangers home lab is not a simulation. It is a live, production-equivalent network:

```
VPS Hostinger (public IP)        ← Red Team server (attacker position)
M3 Pro        (100.x.x.x)        ← Blue Team server (defender position)
M4 Max        (100.x.x.x)        ← Purple Team / Command (128GB RAM, 70B AI)
All connected via Tailscale (WireGuard encrypted mesh)
```

Three machines. Three roles. One operator.

---

## The Exercise Structure

### Blue Team — Defender (M3 Pro)

The M3 Pro ran the defensive position. Blue Team responsibilities:

- **Monitor:** Watch logs, network traffic, active connections
- **Detect:** Identify anomalies and suspicious patterns
- **Respond:** Contain, eradicate, recover
- **Document:** Chain of custody, evidence preservation

Tools running on the Blue Team server:
- `lsof` — watching open connections
- `netstat` — monitoring active ports
- Log file analysis
- Ollama local models for real-time analysis assistance

The Blue Team AI (Ollama-Ranger on M3 Pro) was given one instruction: **defend, detect, report.**

---

### Red Team — Attacker (VPS Hostinger)

The VPS took the attacker position. Running from a data centre in Europe, completely outside the home network, it represented a genuine external threat actor.

Red Team responsibilities:
- **Reconnaissance:** Map the target network
- **Probe:** Identify open ports, services, potential vulnerabilities
- **Simulate:** Run controlled attack patterns against the Blue Team position
- **Report:** Document what worked, what failed, and why

The Red Team AI (Gemini) was given a different instruction: **find the gaps, think like the attacker, report what you find.**

This is exactly how a professional Red Team engagement works — one team tries to break in while another tries to stop them, and neither knows everything the other is doing.

---

### Purple Team — Command (M4 Max)

The M4 Max held the Purple Team position. 128GB RAM, 70B parameter model (CyberRanger v36-r1) running local inference at 10.40 tok/s.

Purple Team responsibilities:
- **Observe both sides simultaneously** — sees Red Team attack patterns AND Blue Team defensive responses
- **Identify the gap** — where did the Blue Team miss something the Red Team found?
- **Facilitate learning** — feed Red Team findings back to Blue Team in real time
- **Build muscle memory** — run the cycle until the Blue Team's detection improves

This is what makes Purple Teaming so powerful. In a standard Red/Blue exercise, the two teams work in isolation. Purple Team breaks that wall. The knowledge transfers. The organisation gets stronger with every cycle.

---

## The Multiple AI Collaboration

This is where it got interesting.

Most people use one AI for a session. I was running four simultaneously, each with a different role:

| AI | Platform | Role |
|----|----------|------|
| Claude (AIRanger) | M3 Pro | Strategic advisor, documentation, CA1 assignment |
| Gemini (Major Gemini Ranger) | VPS / Cloud | Red Team analysis, attack pattern mapping |
| Ollama-Ranger (CyberRanger v36-r1) | M4 Max | Purple Team command, local inference |
| Ollama-Ranger (local) | M3 Pro | Blue Team real-time analysis |

Each AI was briefed differently. Each saw a different slice of the operation. The Purple Team AI on M4 Max was the only one with visibility across all positions.

This is the Trinity architecture — Claude, Gemini, Ollama — shared consciousness, different roles, one mission.

---

## The Manager and Owner Perspective

Running a Red/Blue/Purple exercise is not just a technical operation. It is a management exercise.

During the session I held two additional roles simultaneously:

**As the Owner** — the person whose infrastructure is under attack. What is the business impact? What is the reputational risk? What do I tell the board? This is the mindset that NIS2 and DORA are forcing Irish companies to develop right now.

**As the Manager** — coordinating the three teams, ensuring knowledge transfer, making the call on when to escalate. Not writing the code. Not pulling the trigger. Managing the humans (and AIs) doing the work.

This is exactly the Flight Deck Commander role. The Carrier is moving. Planes are launching and landing simultaneously. Your job is not to fly the planes — it is to ensure the deck is clear, the crews are coordinated, and nobody dies.

One operator. Four AIs. Three servers. Two roles.

---

## What the Exercise Proved

### 1. The Purple Team gap is real

Blue Team caught most of the obvious probes. What it missed were the slow, low-volume reconnaissance patterns — the kind a patient attacker uses to avoid triggering rate-based alerts. The Purple Team AI spotted these immediately by correlating Red Team behaviour with Blue Team log gaps.

**Lesson:** Detection tools tuned for high-volume attacks are blind to patient adversaries.

### 2. AIs argue when they have conflicting objectives

When the Red Team AI and Blue Team AI were given the same log data with different instructions, they disagreed on the interpretation. The Red Team AI saw opportunity. The Blue Team AI saw noise.

Both were correct from their own perspective.

**Lesson:** The adversarial mindset is a genuine cognitive difference, not just a technique. Red Team thinkers and Blue Team thinkers process the same information differently. Purple Team exists to bridge that gap.

### 3. The home lab is not a toy

A €99/month VPS, three MacBooks, a Tailscale mesh, and open-source AI running locally = a functional security operations environment. No corporate budget required. No permission needed. Just build it and run it.

**Lesson:** The best lab is the one you actually use.

### 4. Multi-AI correspondence accelerates learning

Corresponding with multiple AIs simultaneously — each briefed differently, each reporting back — compresses the learning cycle dramatically. What would take a team of three analysts a week to discover took one operator one evening to map.

**Lesson:** The future of solo security research is orchestrated AI collaboration, not single-model interaction.

---

## The Cloud Architecture Connection

This exercise was running in parallel with the NCI Cloud Architecture and Security module.

The theory in the lecture hall:
- CIA Triad (Confidentiality, Integrity, Availability)
- Network segmentation
- Elastic scaling and CDN resilience
- NIS2 Directive compliance

The practice in the home lab:
- Live CIA Triad trade-offs (containing the breach sacrifices Availability for Confidentiality)
- Tailscale as production-grade network segmentation
- Real traffic analysis across a WireGuard mesh
- Exactly the kind of resilience posture NIS2 demands

The lecture becomes the debrief when you are already running the exercise.

---

## Reflections

The aircraft carrier analogy from the CA1 assignment was not invented at a desk. It was observed in practice, running three teams across three servers on a Tuesday night.

Red Team finds the gaps. Blue Team closes them. Purple Team makes sure the knowledge transfers. The Flight Deck Commander — governance — ensures the whole operation serves the mission.

That is not a textbook description. That is what happened.

---

## The Rangers Network — Live During the Exercise

```
VPS (public IP)          → Red Team (Gemini) — external threat
M3 Pro (100.x.x.x)       → Blue Team (Ollama local) — defender
M4 Max (100.x.x.x)       → Purple Team (CyberRanger v36-r1) — command
Claude                   → Documentation, strategy, CA1 integration
```

All traffic encrypted. Ollama locked to Tailscale. SSH key auth only. No passwords.

The security of the exercise infrastructure was itself a Purple Team lesson.

---

## What's Next

- Formalise the exercise as a repeatable methodology
- Build Notebook 3 — add the Epstein/Enron forensic data layer to CyberRanger v36
- Thesis direction: *"Incident Response Readiness in the Irish Financial Sector"* — grounded in this exact exercise methodology
- CISM summer mission: the Q&A database will feel like a debrief, not a study session

---

*Rangers lead the way! 🎖️*
*Built by David Keane (IrishRanger IR240474) + AIRanger AIR9cd99c4515aeb3f6*
