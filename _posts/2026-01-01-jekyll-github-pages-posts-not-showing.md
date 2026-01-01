---
title: "Jekyll GitHub Pages: Why Your Posts Aren't Showing (And How to Fix It)"
date: 2026-01-01 12:00:00 +0000
categories: [Blogging, Troubleshooting]
tags: [jekyll, github-pages, chirpy, troubleshooting, github-actions, html-proofer]
pin: false
math: false
mermaid: false
---

## Overview

This post documents a frustrating Jekyll/GitHub Pages issue: posts pushed to the repository but not appearing on the live site. I'll walk through the debugging process, my mistakes, and the unexpected culprit.

## The Scenario

I had just written 3 new blog posts on December 31st, 2025:
- CTF Steganography walkthrough
- Setting up a Tor Relay on macOS
- UTM Kali Linux Network Troubleshooting

I pushed them from my Kali VM to GitHub using my publish script. Checked the GitHub repo - posts were there. But the live site? Nothing. Still showing old November posts.

---

## Mistake #1: Assuming It Was a Date Issue

**My first thought:**
> "The posts must have future dates! Jekyll hides future-dated posts by default."

**What I checked:**
```yaml
# All my posts had dates like:
date: 2025-12-31 12:00:00 +0000
date: 2025-12-31 15:00:00 +0000
date: 2025-12-31 16:00:00 +0000
```

**Reality:** The dates were fine - December 31st, 2025 was definitely in the past (it was January 1st, 2026).

**Lesson:** Don't assume the obvious cause. Verify first, then diagnose.

---

## Mistake #2: Not Checking GitHub Actions FIRST

**What I should have done immediately:**
```
https://github.com/USERNAME/USERNAME.github.io/actions
```

**What I actually did:**
- Checked post dates
- Verified files were in the repo
- Checked front matter formatting
- Wondered if it was a caching issue

**The truth:** The GitHub Actions build had **FAILED**. The posts were never deployed because the build crashed.

**Lesson:** Always check GitHub Actions status FIRST when posts don't appear!

---

## The Real Problem: HTML-Proofer Found a Missing Image

When I finally checked the Actions log, here was the error:

```bash
Running 3 checks (Images, Links, Scripts) in ["_site"] on *.html files ...

For the Images check, the following failures were found:

* At _site/posts/sublime-text-snippets-chirpy-blog-template/index.html:289:
  internal image /assets/img/snippet-demo.gif does not exist

HTML-Proofer found 2 failures!
Error: Process completed with exit code 1.
```

**The culprit:** An OLD post (`sublime-text-snippets-chirpy-blog-template`) referenced an image that didn't exist: `snippet-demo.gif`

**Why this broke everything:** Chirpy's build process uses HTML-Proofer to validate all links and images. ONE missing image = ENTIRE build fails = NO posts deployed.

---

## The Fix

Simple once I knew the problem:

```bash
# Option 1: Add the missing image
cp /path/to/snippet-demo.gif assets/img/

# Option 2: Remove the image reference from the old post
# Edit the post and remove/replace the broken image link

# Then push
git add .
git commit -m "Fix missing image reference"
git push
```

I uploaded the missing `.gif` file, re-ran the build, and **all posts appeared!**

---

## Debugging Flowchart for Jekyll/GitHub Pages

When your posts aren't showing, follow this order:

```
Posts not showing?
       │
       ▼
┌──────────────────┐
│ 1. Check Actions │ ◄── START HERE!
│    Build Status  │
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
  PASS      FAIL
    │         │
    ▼         ▼
┌────────┐  ┌─────────────┐
│Check   │  │Read the     │
│dates & │  │error logs   │
│front   │  │             │
│matter  │  └──────┬──────┘
└────────┘         │
                   ▼
         ┌─────────────────┐
         │Common failures: │
         │- Missing images │
         │- Broken links   │
         │- Invalid YAML   │
         │- Liquid errors  │
         └─────────────────┘
```

---

## Quick Checks Before Pushing

### 1. Validate Front Matter
```yaml
---
title: "Your Title"           # Required
date: 2026-01-01 12:00:00 +0000  # Must be in the past!
categories: [Cat1, Cat2]      # Use brackets
tags: [tag1, tag2, tag3]      # Use brackets
pin: false
math: false
mermaid: false
---
```

### 2. Check All Image References Exist
```bash
# Find all image references in posts
grep -rh "!\[" _posts/*.md | grep -oP '/assets/img/[^)]+' | sort -u

# Check if they exist
for img in $(grep -rh "!\[" _posts/*.md | grep -oP '/assets/img/[^)]+' | sort -u); do
    [ -f ".$img" ] && echo "✓ $img" || echo "✗ MISSING: $img"
done
```

### 3. Test Locally First
```bash
bundle exec jekyll serve

# Check for build errors before pushing!
```

---

## Error Messages Decoded

### "internal image does not exist"
**Cause:** Referenced image file is missing from `/assets/img/`
**Fix:** Add the image or remove the reference

### "internally linking to X, which does not exist"
**Cause:** Broken internal link
**Fix:** Fix the URL or remove the link

### "HTML-Proofer found X failures"
**Cause:** One or more validation checks failed
**Fix:** Read the specific errors above this message

### Build shows "Success" but posts missing
**Cause:** Usually date issues (future dates) or `published: false`
**Fix:** Check front matter dates and published status

---

## Prevention: Pre-Push Checklist

Before running your publish script:

```bash
# 1. Build locally and check for errors
bundle exec jekyll build

# 2. Run HTML-Proofer locally (optional but recommended)
bundle exec htmlproofer _site --disable-external

# 3. Check all images exist
find _posts -name "*.md" -exec grep -l "assets/img" {} \; | \
  xargs grep -oh '/assets/img/[^)]*' | sort -u | \
  while read img; do [ -f ".$img" ] || echo "Missing: $img"; done

# 4. Verify dates are in the past
grep -h "^date:" _posts/*.md | sort
```

---

## Useful Commands

| Task | Command |
|------|---------|
| Check Actions status | `gh run list` |
| View failed build logs | `gh run view RUN_ID --log-failed` |
| Test build locally | `bundle exec jekyll serve` |
| Validate HTML | `bundle exec htmlproofer _site` |
| Find broken images | `grep -r "assets/img" _posts/` |

---

## Key Takeaways

1. **Check GitHub Actions FIRST** - It's the #1 diagnostic tool
2. **One broken link breaks everything** - HTML-Proofer is strict
3. **Old posts can break new deployments** - The whole site rebuilds every time
4. **Test locally before pushing** - Catch errors before they hit production
5. **Keep your assets organized** - Missing images are the most common culprit

---

## The Happy Ending

After uploading the missing `snippet-demo.gif`:
- Build: **SUCCESS**
- All 3 new posts: **LIVE**
- Total debug time: ~15 minutes
- Time it would have taken if I checked Actions first: ~2 minutes

---

*Sometimes the problem isn't with your new code - it's with something you forgot about months ago. Always check the build logs!*

**Pro tip:** Bookmark your Actions page: `https://github.com/USERNAME/USERNAME.github.io/actions`

