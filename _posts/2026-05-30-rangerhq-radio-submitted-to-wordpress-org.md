---
title: "RangerHQ Radio — submitted to WordPress.org (another dream)"
date: 2026-05-30 01:00:00 +0000
categories: [WordPress, Plugin Development]
tags: [wordpress, plugin, somafm, radio, wp.org, plugin-directory, submission, milestone, ranger-hq, gpl, plugin-check]
pin: false
math: false
mermaid: false
---

## The headline

> *"another dream!!! who cares if it get accepted! we got past the first step and in the door"*
> — me, at 5 in the morning, having just hit Submit on my first ever WordPress.org plugin

The plugin is **RangerHQ Radio** — a small admin-only internet radio player that drops 44 hand-curated SomaFM stations into the WordPress dashboard so you can have background music while you work in the admin. Submitted to the wp.org Plugin Directory on **2026-05-30**, passed the **Automated Plugin Scan** on the first try, and is now in the review queue (86 plugins ahead at submission time; queue depth currently running about a week).

## How a UI-polish pass became a wp.org submission in 48 hours

This wasn't planned as a wp.org submission. It started as a *"hey can you take a look at the Radio page UI"* session two days earlier. The first commit in this arc was a v0.3.0 polish pass — 5 small fixes for things I'd noticed in the player.

Then the polish became features. Then the features became a proper release cadence. Then somewhere around v0.6.3 the question shifted from *"what should this plugin do"* to *"could this actually go on wp.org"* — and the answer was *"yeah, if we fix a handful of things first"*.

The arc ended up being **fifteen releases** across two days:

### Polish trio (v0.3.0 – v0.3.2)
Five small fixes + three nice-to-haves: dark theme wired through properly, inline `oninput` removed, AJAX errors that actually surface to the user, mute toggle, OS media keys via MediaSession API, SomaFM current-track polling under the station description. Also a fix for a Dashicon that was rendering below the text baseline of the Play button (swapped to a plain Unicode ▶ glyph with `font-variant-emoji: text`).

### Feature trio (v0.4.0 – v0.6.0)
- **v0.4.0 — Now-playing indicator.** A CSS dancing-bars equalizer that pulses when audio is playing, with a Web Audio frequency visualizer as a progressive upgrade when the browser allows it (and a graceful CORS fallback when it doesn't).
- **v0.5.0 — Track history + favourites.** Every track that scrolls past gets logged to a per-user History page (capped at 500). A star toggle promotes the good ones to a separate Favourites tab that doesn't age out. Four search-provider links per row — Spotify, YouTube, Apple Music, Bandcamp — so you can find that "what *was* that song" track on whichever service you use.
- **v0.6.0 — Pop-out mini-player.** Fixes the *"music cuts every time I navigate between admin pages"* pain point. A 380×560 standalone window opens via `admin-post.php`, persists across the main tab's navigation, auto-resumes playback, pauses the parent-tab audio so only one stream plays.

### Polish patches (v0.6.1 – v0.6.3)
About-page restructure (balanced 3-card top row + compact version history), current-version badge on the Settings page, discreet "buy me a coffee" support link in the Updates panel and Credits card.

### wp.org-submission prep (v0.7.0 – v0.7.5) — the actual hard part

This is where it stopped being a side-project and started being a proper plugin.

**v0.7.0 — Plugin Check (PCP) audit.** Full sweep through the wp.org-recommended scanner: 169 → 4 issues. The big ones: plugin name normalised from `Radio` to `RangerHQ Radio` to remove the trademarked "SomaFM" from the title (it stays in the description as the data source, with proper attribution). Text Domain renamed `radio` → `a-radio` across 134 i18n call sites via in-place `sed`. All `$_POST` access wrapped in `wp_unslash()` + `sanitize_*()` at the access point — 16 PCP warnings vanished. Pop-out window stopped emitting raw `<link>` / `<script>` tags — switched to `wp_enqueue_*` + `wp_print_styles()` / `wp_print_footer_scripts()`. Proper `readme.txt` instead of `README.md` only.

**v0.7.1 — Tested-up-to bumped.** Single PCP warning: `outdated_tested_upto_header`. Bumped from 6.7 to 7.0.

**v0.7.2 — Screenshots + correct wp.org contributor handle.** Five `screenshot-N.png` files at the plugin root (Dashboard widget / Settings / History / Pop-out window / About) per wp.org naming convention. `Contributors:` header updated from a placeholder to my actual wp.org username `ir240474`.

**v0.7.3 — The clever-but-wrong release.** Tried to satisfy wp.org's guideline 8 (*"plugins distributed via the directory must not ship their own updater"*) with an **Update URI guard pattern**: keep the self-hosted Gitea updater in the source, ship a build-time `sed` strip that removes the `Update URI:` header line, runtime guard inside `inc/updater.php` short-circuits the updater when the header is absent. The runtime logic was actually correct. But Plugin Check scans the source as-shipped, not as-distributed. Result: PCP raised `plugin_updater_detected` on the source, and the build-time strip never had a chance to run before the scan.

**v0.7.4 — Walkback.** Deleted `inc/updater.php` entirely, removed the `Update URI:` header, removed the `require_once`, removed the Updates panel from settings. The simpler answer was the right one: once a plugin is on wp.org, wp.org IS the update channel. Also closed the GPL declaration loop — added a top-level `LICENSE` file (the full 338-line canonical GPL v2 text from gnu.org), added GPL header blocks to `radio.css`, `radio.js`, and `radio.php`'s docblock. Every shipped file now declares its license unambiguously.

**v0.7.5 — Slug rename.** Plugin Check has a sister tool called **Plugin Check Namer** which runs an LLM check on the plugin's display name and slug. It connects to your own AI provider (I wired it to my Anthropic Claude API key). It flagged the old slug `a-radio` as too generic:

> *"The display name 'a-radio' is too generic. The term 'radio' is a broadly used, common functional word, and the single-letter prefix 'a-' does not add meaningful distinctiveness or describe what the plugin actually does. With 60,000+ plugins in the directory, a name this short and generic makes it hard for users to identify the plugin and distinguish it from others."*

Defensible. Single-word generic slugs are increasingly rejected by human reviewers as the directory grows. The new slug `rangerhq-radio` matches the public display name "RangerHQ Radio" (unchanged) and lines up with the rest of the RangerHQ plugin family: `rangerhq-spatial`, `rangerhq-glyph`, now `rangerhq-radio`. Consistent prefix, distinctive enough for the directory, descriptive of what the plugin does.

The rename touched 125 i18n call sites, the Text Domain header, the `RADIO_GITEA_URL` constant value, the README install link, the readme.txt FAQ link, the about-page version history. Plus the Gitea repo rename, plus the local folder rename. **Deliberately unchanged** to avoid pure churn: Plugin Name (already correct), internal PHP constants (don't have to match slug), user-meta keys (renaming would orphan every existing user's settings on upgrade), HTML `data-radio-*` attributes (JS controller selectors, not slug-related), CSS class names, main plugin file name.

When I re-ran Plugin Check Namer against v0.7.5: **"ℹ️ Generally Allowable. Display Name: (no change needed). Slug: (no change needed)."**

## The submission itself

Built the zip with proper exclusions:

```bash
cd ~/Local\ Sites/plugin-test/app/public/wp-content/plugins
zip -r ~/Desktop/rangerhq-radio-v0.7.5.zip rangerhq-radio \
  -x "rangerhq-radio/.git/*" \
  -x "rangerhq-radio/.gitignore" \
  -x "rangerhq-radio/.DS_Store" \
  -x "rangerhq-radio/**/.DS_Store"
```

Output: 711 KB, 24 files, no hidden files, no `.git` (1.8 MB), no `.DS_Store` (six of them across the working tree). The `.gitignore` exclusion matters because PCP raises a `hidden_files` warning on any dotfile in the zip — which is a low-severity warning that I'd just as soon not appear.

Uploaded via `wordpress.org/plugins/developers/add`. Within ~10 seconds: **"Results of Automated Plugin Scanning: Pass."** Confirmation email arrived immediately. Slug locked in as `rangerhq-radio`.

## The three things wp.org reviewers reject most often

The wp.org submission page is upfront about this. Their top three rejection categories:

1. **Unescaped output.** Every echo to the browser needs `esc_html()` / `esc_attr()` / `esc_url()` or `wp_kses()` with an explicit allowed-tags array. No raw `echo $variable;` anywhere.
2. **Unsanitized input.** Every `$_POST` / `$_GET` / `$_REQUEST` access needs `wp_unslash()` + the appropriate sanitizer (`sanitize_text_field()`, `sanitize_key()`, `(float)` + clamp, etc.) **at the access point**, not "somewhere downstream".
3. **No nonces on form data.** Every form needs `wp_nonce_field()` + `check_admin_referer()`. Every AJAX endpoint needs `wp_create_nonce()` passed via `wp_localize_script()` + `check_ajax_referer()` on the handler.

A grep across the v0.7.5 source confirmed all three were clean before submission. This is also the kind of thing PCP catches — but a fresh grep with your own eyes catches the cases where PCP suppressed a warning because of an irrelevant `phpcs:ignore` comment from three releases ago.

## What it cost (in time)

Two evenings of focused work. Maybe 8 hours of actual editing across both days. The polish and feature work was the slow part — the wp.org-prep arc (v0.7.0 → v0.7.5) was about 3 hours total, and most of that was the v0.7.3 → v0.7.4 walkback (because being clever about a `sed`-strip build pattern costs more than just doing the simple thing).

## What's next

The submission is **awaiting human review**. The wp.org reviewer queue is currently 86 deep with about a week of throughput, so realistic ETA is 1–2 weeks. The reviewer will email — subject line `[WordPress Plugin Directory] Review in Progress: RangerHQ Radio` — and either approve or request changes.

If they request changes (most likely outcome for a first submission), it's usually 1–2 small things. Fix, bump version, build new zip, upload via the "Upload updated plugin for review" button on the same submission page (NOT a fresh submission — that's explicitly forbidden while you have one pending).

If they approve, they issue SVN credentials for `https://plugins.svn.wordpress.org/rangerhq-radio/` and the plugin goes live at `https://wordpress.org/plugins/rangerhq-radio/`.

Either way, the win was getting past the automated scan and into the human queue. The directory hosts 60K+ plugins; submitting one is a small thing in the abstract but a meaningful one in the specific. The plugin family — `rangerhq-spatial`, `rangerhq-glyph`, `rangerhq-radio` — now has a tested template for what wp.org submission looks like. The next two will be faster because of what this one taught.

## Lessons that are sticking

- **The Update URI guard pattern is wrong for wp.org-hosted plugins.** Plugin Check forbids any custom updater code AND the `Update URI:` header itself, regardless of build-time stripping, because it scans source as-shipped. The simpler answer (delete the updater entirely once you're on wp.org) is the right answer. The clever build-pattern is fine for self-hosted-only distributions; just not for wp.org.
- **Slug naming matters more than display name.** "RangerHQ Radio" was always fine as the display name. The slug `a-radio` was the weak link. Plugin Check Namer caught it before a human reviewer would have.
- **Keep state in `user_meta` under stable keys.** When the v0.7.5 slug rename happened, every existing user's settings + history + favourites survived intact because the user-meta keys (`radio_state`, `radio_history`, `radio_favourites`) never changed. A lot of plugins get this wrong by burying state in plugin-folder-scoped option keys; one rename and the install looks empty.
- **Tag every version bump.** Self-hosted update mechanisms (and just general sanity) require `git tag -a vX.Y.Z && git push --tags` after every version bump commit. Held this rule from v0.6.1 onwards across the whole arc — no tag debt.
- **PCP is your friend.** The submission scanner that runs at upload time is the same PCP you can run locally. If it's clean on your machine, it'll be clean on theirs.

---

Plugin source on Gitea: <https://git.davidtkeane.com/ranger/rangerhq-radio>

WordPress.org submission page (404 until approved): <https://wordpress.org/plugins/rangerhq-radio/>

Got past the first step, got in the door. 🎖️
