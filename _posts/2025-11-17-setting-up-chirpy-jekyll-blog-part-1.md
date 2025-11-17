---
title: "Setting Up a Chirpy Jekyll Blog - Part 1: Local Development"
date: 2025-11-17 02:00:00 +0000
categories: [Blogging, Chirpy]
tags: [jekyll, chirpy, blog, setup, series]
pin: false
math: false
mermaid: false
---

## Series Overview

This is **Part 1** of a series on setting up and deploying a Chirpy Jekyll blog:

1. **Part 1: Local Development** (this post)
2. Part 2: Deploying to Production (InMotion/VPS) - Coming Soon
3. Part 3: Custom Domain & SSL - Coming Soon

## What is Chirpy?

Chirpy is a minimal, responsive Jekyll theme designed for technical writing. It's perfect for:
- Security research blogs
- HackTheBox/TryHackMe writeups
- Development documentation
- Personal portfolios

## Local Setup

### Prerequisites

```bash
# Install Ruby and Jekyll (Kali Linux)
sudo apt install ruby-full build-essential zlib1g-dev
gem install jekyll bundler
```

### Installation

1. **Clone the Chirpy starter:**
```bash
git clone https://github.com/cotes2020/chirpy-starter.git ranger-chirpy
cd ranger-chirpy
bundle install
```

2. **Run locally:**
```bash
bundle exec jekyll serve
# Or create an alias:
alias jchirpy='cd /path/to/blog && bundle exec jekyll serve'
```

3. **Access at:** `http://127.0.0.1:4000/`

## Configuration

### Basic Site Settings

Edit `_config.yml`:

```yaml
title: Ranger                              # Site name
tagline: Security Research & HTB Writeups # Subtitle
social:
  name: Ranger                             # Author name in footer
avatar: /assets/img/profile.png           # Sidebar profile picture
```

### Adding Profile Picture

```bash
# Copy image to assets
cp ~/images/profile.png assets/img/profile.png

# Update _config.yml
avatar: /assets/img/profile.png
```

## Creating Posts

### File Naming Convention

Posts must follow: `YYYY-MM-DD-title-with-dashes.md`

```
_posts/
├── 2025-11-17-jerry-hackthebox-walkthrough.md
├── 2025-11-17-building-python-pentest-tool.md
└── 2025-11-17-setting-up-chirpy-part-1.md
```

### Front Matter Template

```yaml
---
title: "Your Post Title"
date: 2025-11-17 00:00:00 +0000
categories: [Primary, Secondary]
tags: [tag1, tag2, tag3]
pin: false
math: false
mermaid: false
---
```

### Category Strategy

I organize posts by purpose:

| Category | Use Case |
|----------|----------|
| `[HackTheBox, Easy]` | HTB writeups by difficulty |
| `[TryHackMe, Medium]` | THM writeups |
| `[Security, Tools]` | Custom tool development |
| `[Blogging, Chirpy]` | Meta posts about the blog |

Chirpy auto-generates category pages at `/categories/hackthebox/`, etc.

## Common Issues

### Posts Not Showing - Future Date

**Problem:** Jekyll skips posts with future timestamps

```
Skipping: _posts/2025-11-17-post.md has a future date
```

**Solution:** Use past/current time in front matter:

```yaml
# BAD - might be in future depending on timezone
date: 2025-11-17 23:00:00 +0000

# GOOD - safe past time
date: 2025-11-17 00:00:00 +0000
```

### Changes Not Appearing

1. **Check Jekyll output** for errors/warnings
2. **Restart server** after `_config.yml` changes
3. **Clear cache:** Delete `.jekyll-cache/` folder

## Current Blog Structure

```
ranger-chirpy/
├── _config.yml           # Site configuration
├── _posts/               # All blog posts
│   ├── HTB writeups
│   ├── Tool documentation
│   └── Setup guides
├── _tabs/                # Sidebar navigation
├── assets/
│   └── img/              # Profile pic, post images
└── _site/                # Generated static site
```

## What's Next

In **Part 2**, I'll cover:
- Choosing a hosting provider (InMotion, DigitalOcean, GitHub Pages)
- Deploying the static site
- Setting up CI/CD for automatic builds
- Custom domain configuration
- SSL/HTTPS setup

## Why Jekyll + Chirpy?

- **Fast:** Static HTML = no database queries
- **Secure:** No PHP/dynamic code to exploit
- **Free hosting:** GitHub Pages support
- **Markdown:** Write posts in familiar format
- **Version control:** Git-based workflow
- **Offline writing:** No internet required for drafts

## Resources

- [Chirpy Theme Demo](https://chirpy.cotes.page/)
- [Chirpy Documentation](https://github.com/cotes2020/jekyll-theme-chirpy/wiki)
- [Jekyll Docs](https://jekyllrb.com/docs/)
- [Markdown Guide](https://www.markdownguide.org/)

---

*This is a living document. As I add more features to the blog, I'll update this series.*

*Series: Setting Up Chirpy Jekyll Blog*
*Part 1 of 3*

