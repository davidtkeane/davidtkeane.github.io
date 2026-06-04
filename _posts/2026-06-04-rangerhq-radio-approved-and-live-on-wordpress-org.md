---
layout: post
title: "RangerHQ Radio — approved and live on WordPress.org"
date: 2026-06-04 14:00:00 +0000
categories: [WordPress, Plugin Development]
tags: [wordpress, plugin, wp-org, svn, rangerhq-radio, somafm, milestones, shipping]
author: David Keane
---

Six days ago this plugin was a folder on my Mac that I'd been polishing for the love of it. As of about an hour ago it lives on **`wordpress.org/plugins/rangerhq-radio/`**, with a real version number, a real "Last updated 3 minutes ago" badge, and a real plugin-page URL that anybody on the internet can install from.

I'm writing this while the page is still showing **"Active installations: Fewer than 10"** — the lowest tier wp.org displays. The plugin's a baby on a platform that hosts ~60,000 others. The number doesn't matter. The shipping does.

This post documents the journey from *submitted* (last Saturday) to *approved + live* (today, Wednesday afternoon Dublin time) and the bits that surprised me along the way.

> [The submission post →]({% post_url 2026-05-30-rangerhq-radio-submitted-to-wordpress-org %}) is the prequel. This one's the landing.

---

## The 6-day arc

| Date | Event |
| --- | --- |
| **Sat 30 May 2026** | Submitted v0.7.5 (after the v0.7.0 → v0.7.5 Plugin Check fix arc) |
| **Sun 31 May / Mon 1 Jun** | Quiet — no email from wp.org |
| **Tue 2 Jun (early hours)** | wp.org reviewer email: "verify your domain ownership" |
| **Tue 2 Jun (afternoon)** | Wrote the [WP_ORG_SUBMISSION_CHECKLIST]({% post_url 2026-05-30-rangerhq-radio-submitted-to-wordpress-org %}) Phase 1.5 — the identity-verification step I'd skipped |
| **Tue 2 Jun (evening)** | DNS TXT record added on Cloudflare. Email on wp.org account changed to `david@davidtkeane.com`. v0.7.6 packaged + uploaded for re-review with Plugin URI + Author URI both pointing to `davidtkeane.com` |
| **Wed 3 Jun** | Quiet again |
| **Thu 4 Jun (this morning)** | wp.org email: **"Plugin approved. Here are your SVN credentials."** |
| **Thu 4 Jun (afternoon)** | SVN checkout → rsync → commit → tag → live on wp.org. Hit GO at ~15:45 IST |

Six days. Three of those waiting. One of those fixing what I hadn't anticipated. The actual work was condensed into a few hours.

---

## What the pre-review email actually said

The wp.org review team didn't reject the plugin. They paused it.

The exact phrasing (paraphrased — I'm not pasting the literal email) was: *the URLs in your plugin headers don't resolve, and the email on your wp.org account doesn't match the domain in your plugin headers. Please verify domain ownership before we can publish.*

Three things triggered it:

1. The `Plugin URI` header in `radio.php` pointed at a `git.davidtkeane.com/...` path that gave a soft-404 (the repo was there, but the page rendered an "object not found" stub on certain user-agents)
2. The `Author URI` header pointed at a different domain entirely that wasn't returning anything clean
3. My wp.org account email was a `@gmail.com` address — which is fine for a generic plugin, but trips the review heuristic for plugins branded with a specific company / personal domain

The fix had three pieces:

**1. Make the URLs resolve cleanly.** I owned `davidtkeane.com` (a static personal site I'd quietly run since 2025 that, embarrassingly, I'd half-forgotten about) so I put both URLs there. The plugin's Plugin URI became `https://davidtkeane.com/rangerhq-radio`. The Author URI became `https://davidtkeane.com`. Both now serve real HTML.

**2. Prove I own the domain.** wp.org accepts two methods: a DNS TXT record, or an email at the matching domain. I did **both** — belt and braces. The TXT record went on Cloudflare (the authoritative nameserver — InMotion, who I'd assumed handled the DNS, had been delegated to Cloudflare years ago and I'd forgotten). The email — `david@davidtkeane.com` — I'd had configured for ages but never switched my wp.org account to.

**3. Rebuild + re-upload.** v0.7.6. Same code as v0.7.5, headers updated, readme.txt entry added.

That round-trip — feedback to fix to re-upload — took about 6 hours of actual work spread across an evening.

---

## The thing nobody told me about wp.org SVN

Most plugin tutorials say "after approval you'll get SVN access and you can upload your files." What they don't say clearly is how the **Stable tag** dance actually works.

Here's the shape of it. After approval:

```
plugins.svn.wordpress.org/rangerhq-radio/
├── trunk/       ← the current dev version (you push here first)
├── tags/        ← versioned snapshots that map to release versions
└── assets/      ← icon, banner, screenshots (separate from plugin code)
```

The thing that's *not* obvious: **your plugin doesn't go live until you create a `tags/X.Y.Z` directory that matches the `Stable tag:` line in your readme.txt.**

You can push all the code you want to `trunk/`. wp.org will sit there politely, will show the plugin page as existing, will not actually serve your plugin to users. You have to:

1. `svn copy trunk tags/0.7.6`
2. `svn commit -m "Tag v0.7.6"`

…and the moment that second `svn commit` lands, the plugin page flips from "exists" to "serving 0.7.6". The page metadata refreshes within minutes. **`tags/X.Y.Z` is the go-live trigger.** Trunk on its own does nothing.

The other surprise: SVN is not git. I'd installed `subversion` via Homebrew the day before, but I hadn't touched SVN in maybe ten years. Some things that caught me out:

- `svn status` is your friend; `svn add file.php` is not optional like `git add .` mostly is. New files need an explicit add before commit
- `--force` on `svn add trunk/*` was needed because I'd `rsync`ed files in first and SVN doesn't auto-detect them like git would
- There's no `pull`. There's `svn update`. Same idea, different verb
- The `.svn/` directory in each subfolder is the SVN equivalent of `.git/` at the repo root. Different mental model — every directory remembers its own version metadata

I'd `rsync`ed the plugin files in from my local WordPress dev install with a careful exclude list (`.git`, `.gitignore`, `.DS_Store`, `node_modules`, `*.map`, `.vscode`, `.idea`) and then ran the standard SVN flow on top.

The final command sequence:

```bash
svn checkout https://plugins.svn.wordpress.org/rangerhq-radio/
# A trunk/  A tags/  A assets/  rev 3561165

rsync -av --delete \
  --exclude=.git --exclude=.gitignore --exclude=.DS_Store \
  --exclude=node_modules --exclude='*.map' \
  --exclude=.vscode --exclude=.idea \
  ~/Local\ Sites/plugin-test/app/public/wp-content/plugins/rangerhq-radio/ \
  trunk/

svn add trunk/* --force
svn commit -m "Initial release v0.7.6"
# Committed revision 3561171

svn copy trunk tags/0.7.6
svn commit -m "Tag v0.7.6"
# Committed revision 3561176  ← THE GO-LIVE TRIGGER
```

That was it. Five real commands. Two `svn commit` calls. A handful of seconds between the second commit and `https://wordpress.org/plugins/rangerhq-radio/` returning HTTP 200 with the metadata properly populated.

---

## What the live page actually shows (right now)

| Field | Value | Where wp.org parsed it from |
| --- | --- | --- |
| Version | 0.7.6 | `radio.php` plugin header |
| Last updated | a few minutes ago | timestamp of the SVN tag commit |
| Active installations | Fewer than 10 | live count, hidden in 10-band buckets until you cross thresholds |
| WordPress version | 5.3 or higher | `readme.txt` `Requires at least:` line |
| Tested up to | 7.0 | `readme.txt` `Tested up to:` line (the v0.7.1 fix paid off) |
| PHP version | 7.4 or higher | `readme.txt` `Requires PHP:` line |
| Tags | 5 max | wp.org enforces a hard cap of 5 |
| Contributors | ir240474 | matches the email on the wp.org account now |

No warnings on the page. No "this plugin hasn't been tested with your version of WordPress" yellow banner. The version-compatibility info is clean because we put 7.0 in `Tested up to`, not the older 6.x I'd had originally — that was one of the Plugin Check findings on the v0.7.0 → v0.7.1 hop.

The header icon shows the wp.org default placeholder. I haven't uploaded a custom icon or banner to `assets/` yet. That's the next small thing. Once I do, the page'll look properly furnished.

---

## The wp-notes 2025 loop, finally closed

There's a small piece of personal context that makes this not just a "look I shipped a plugin" post.

About a year ago — late 2025 — I'd built **another** WordPress plugin called `wp-notes`. Similar level of polish to this one. Similar amount of work. I packaged it up to submit to wp.org and then… didn't. I closed the laptop, decided it wasn't ready, decided I'd come back to it.

I never came back to it. The submission window passed and the plugin sat in my projects folder gathering dust. That was my first abandoned plugin submission.

When I started polishing `rangerhq-radio` last week — initially just as a UI pass on a personal-use admin-bar music player — I noticed the same pre-submission anxiety creeping in. The same "it's not ready" voice. The same urge to add one more feature before shipping.

I shipped it anyway. Six days from "I should clean up the UI" to "live on wp.org" — including a reviewer round-trip that would have given me every excuse to give up on it.

Wp-notes 2025 abandoned. Rangerhq-radio 2026 live. Same project type, different outcome. The year-old quit-point is closed.

This is the part I want to remember more than the SVN commands.

---

## What I'd tell someone else doing this for the first time

Five concrete things that would have saved me time, in order of how much pain they avoided:

**1. Submit the plugin from the email that matches the domain in your plugin headers.** The 6-hour pre-review fix was almost entirely about this one alignment. If my wp.org account had been `david@davidtkeane.com` from the start, with the plugin headers pointing at `davidtkeane.com/<slug>`, the reviewer would have just approved the first submission. The TXT record might have been unnecessary entirely.

**2. Make every URL in your plugin headers return a real HTTP 200.** Reviewers (or the automated pre-check) curl your Plugin URI and Author URI. If either returns a soft-404 or a "DNS resolution failed" type error, you get bounced. Run `curl -fsLI <url>` against every header URL before submitting. It takes 60 seconds.

**3. Plugin Check (PCP) is the bouncer; readme.txt is the door.** I ran PCP locally before submitting v0.7.5. It caught maybe 169 issues across the v0.7.0 → v0.7.5 arc. By the time the human reviewer touched the plugin there was nothing left for them to flag *in the code*. The only thing they could flag was the identity stuff above. Use PCP heavily before submission.

**4. The Stable tag dance is the actual go-live moment.** Don't expect anything to happen when you push to `trunk/`. The `svn copy trunk tags/X.Y.Z` + commit is what flips the switch. If you push to trunk on Monday and nobody can install your plugin on Tuesday, this is why.

**5. Don't optimise for the page metrics on day one.** "Active installations: Fewer than 10" is the lowest band. You will sit at "Fewer than 10" for a while. wp.org search indexing takes ~72 hours. The plugin page exists from the moment you push the tag, but search results catch up later. Don't refresh the install count compulsively. Build the next thing.

---

## What's still pending

A short, honest list:

- **Icon + banner upload to `assets/`.** A 256×256 PNG icon + 1544×500 and 772×250 PNG banners. These give the plugin page a proper visual identity instead of the default placeholder. I'll do this over the weekend — they're cosmetic, not blockers.
- **72-hour wp.org search-index wait.** Searching `RangerHQ Radio` in WP Admin → Add New currently might not surface the plugin in the top results. That settles after the search index runs its next pass.
- **The next two plugins in the RangerHQ family.** `a-buddy` and `a-logbook` were built alongside `rangerhq-radio` and would follow the same tested template now that the pipeline's proven. Whether they're worth submitting to wp.org or just keeping as private Gitea repos is still an open question — those are more specifically-mine plugins, less broadly useful.
- **Updating the davidtkeane.com landing page.** The `/rangerhq-radio/` static page currently says "submission pending review" with an `<em class="tag">` next to the WordPress.org install line. That needs updating to "live on wp.org" with the direct link. Five-minute edit.

That last one I'll do as I close this post.

---

## Footnote — the upload-first mindset

There's a memory I have that's been quietly informing this whole arc, going back about a month.

The instinct, when you submit a plugin to a directory that hosts 60,000 of them, is to start watching the download counter, the install count, the review stars. To treat the metrics as the scoreboard.

That's the wrong scoreboard. The scoreboard is whether you uploaded it at all.

Wp-notes 2025 — never uploaded. Zero downloads. Zero reviews. Zero metrics. Indistinguishable from a plugin that didn't exist.

Rangerhq-radio 2026 — uploaded. Fewer-than-10 active installs at the time of writing. Indistinguishable from wp-notes 2025 by the metrics scoreboard. But fundamentally different by the only scoreboard that matters: the work *exists* for other people to encounter.

The downloads will or won't happen. The reviews will or won't come. The "Fewer than 10" might become "10+", might become "100+", might stay where it is forever. None of that's the win.

The win is that the plugin shipped. The directory page renders. Someone, somewhere, between now and the heat-death of the universe, might install a thing I built and have it play SomaFM in their dashboard while they work. That's enough. That was always enough.

---

🎖️ **Rangers lead the way.** ☕

**Live page:** [`wordpress.org/plugins/rangerhq-radio`](https://wordpress.org/plugins/rangerhq-radio/)
**Landing page:** [`davidtkeane.com/rangerhq-radio`](https://davidtkeane.com/rangerhq-radio/)
**Source (Gitea):** [`git.davidtkeane.com/ranger/rangerhq-radio`](https://git.davidtkeane.com/ranger/rangerhq-radio)

*Built in Dublin. GPL v2 or later. Stations courtesy of [SomaFM](https://somafm.com/support/) — please consider donating to them directly if you enjoy the plugin.*
