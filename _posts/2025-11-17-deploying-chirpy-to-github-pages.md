---
title: "Deploying Chirpy Jekyll Blog to GitHub Pages from Kali Linux"
date: 2025-11-17 01:00:00 +0000
categories: [GitHub, Deployment]
tags: [jekyll, chirpy, github-pages, deployment, kali-linux, blogging]
pin: false
math: false
mermaid: false
---

## Overview

This guide documents my actual deployment of a Chirpy Jekyll blog to GitHub Pages from **Kali Linux VM** running on a MacBook Pro M3. These are the exact commands I ran - no theory, just real steps that worked.

> **Platform Note:** This guide is tested on **Kali Linux**. The process should be similar on macOS, but key differences may exist (especially with Git configuration). If you're on macOS, some commands may need adjustments.
{: .prompt-info }

## Why GitHub Pages?

- **Free hosting** for static sites
- **Automatic builds** on git push
- **Custom domain** support
- **HTTPS** included
- **Git-based workflow** you're already using

## Prerequisites

- GitHub account
- Local Chirpy blog working (tested with `bundle exec jekyll serve`)
- Git installed and configured
- Your blog posts ready in `_posts/` directory

## Step 1: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)

2. **Repository name options:**
   - `username.github.io` → Site at `https://username.github.io/`
   - `blog` or `ranger-blog` → Site at `https://username.github.io/blog/`

3. **Settings:**
   - Public (required for free GitHub Pages)
   - Don't initialize with README (we have local files)

4. Click **Create repository**

## Step 2: Prepare Local Repository

### Check Current Git Remote

If you cloned chirpy-starter, it points to their repo:

```bash
cd /home/kali/Documents/web/ranger-chirpy

git remote -v
# Shows: origin  https://github.com/cotes2020/chirpy-starter.git
```

### Change Remote to YOUR Repository

Don't delete `.git`! Just change where it points:

```bash
# Remove old remote (chirpy-starter)
git remote remove origin

# Add YOUR new repository
git remote add origin https://github.com/yourusername/yourusername.github.io.git

# Verify it's correct
git remote -v
# Should show: origin  https://github.com/yourusername/yourusername.github.io.git
```

**My actual command:**
```bash
git remote add origin https://github.com/davidtkeane/davidtkeane.github.io.git
```

### Update Configuration

Edit `_config.yml` with your actual GitHub Pages URL:

```yaml
# For username.github.io repository:
url: "https://yourusername.github.io"
baseurl: ""

github:
  username: yourusername
```

**My actual config:**
```yaml
url: "https://davidtkeane.github.io"

github:
  username: davidtkeane
```

> **Important:** The `url` must match your GitHub Pages URL exactly, without trailing slash.
{: .prompt-warning }

## Step 3: GitHub Actions Workflow

Chirpy uses GitHub Actions to build the site. The workflow file should already exist:

```bash
ls .github/workflows/
# Should see: pages-deploy.yml or jekyll.yml
```

If missing, create `.github/workflows/pages-deploy.yml`:

```yaml
name: "Build and Deploy"
on:
  push:
    branches:
      - main
    paths-ignore:
      - .gitignore
      - README.md
      - LICENSE

  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true

      - name: Build site
        run: bundle exec jekyll b -d "_site"
        env:
          JEKYLL_ENV: "production"

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: "_site"

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## Step 4: Commit and Push to GitHub

```bash
# Add all your files (posts, config, assets)
git add .

# Check what will be committed
git status

# Commit with descriptive message
git commit -m "Initial deployment: Chirpy blog with posts"

# Push to GitHub (first time requires -u flag)
git push -u origin main
```

**My actual sequence:**
```bash
git add .
git commit -m "Deploy Chirpy blog to GitHub Pages"
git push -u origin main
```

> **Note:** If you get authentication errors, make sure you have a Personal Access Token (PAT) set up, or use SSH keys. See [Git Authentication Common Mistakes](/posts/git-authentication-common-mistakes/).
{: .prompt-tip }

## Step 5: Configure GitHub Pages

1. Go to your repository on GitHub

2. Click **Settings** → **Pages** (left sidebar)

3. Under **Build and deployment**:
   - Source: **GitHub Actions**
   - (Not "Deploy from a branch")

4. Wait for the first workflow to complete:
   - Go to **Actions** tab
   - Watch the build progress
   - Green checkmark = success

5. Your site URL appears in **Settings → Pages**

## Step 6: Verify Deployment

Visit your site:
- `https://username.github.io/` (if using username.github.io repo)
- `https://username.github.io/blog/` (if using project repo with baseurl)

Check that:
- Homepage loads with posts
- Profile picture appears
- Categories/tags work
- Post links are correct

## Updating Your Blog

After initial setup, publishing is simple:

```bash
# Create new post
# Edit _posts/YYYY-MM-DD-title.md

# Commit and push
git add .
git commit -m "Add new post: Title"
git push

# GitHub Actions automatically builds and deploys
# Check Actions tab for build status
# Site updates in ~2-3 minutes
```

## Troubleshooting

### Build Fails - Check Actions Log

1. Go to **Actions** tab
2. Click failed workflow
3. Expand the failed step
4. Common issues:
   - Missing gems in Gemfile
   - Syntax errors in YAML front matter
   - Invalid liquid template

### 404 Errors on Assets

**Problem:** CSS/JS not loading, broken images

**Solution:** Check `baseurl` in `_config.yml`:

```yaml
# Wrong - trailing slash causes issues
baseurl: "/blog/"

# Correct
baseurl: "/blog"
```

### Posts Not Appearing

1. **Future date issue** - Use past timestamp in front matter
2. **Wrong file location** - Must be in `_posts/` directory
3. **Invalid filename** - Must be `YYYY-MM-DD-title.md`

### Local Works, Production Broken

Test with production settings locally:

```bash
JEKYLL_ENV=production bundle exec jekyll serve --baseurl '/blog'
```

## Network Access (Before Deployment)

While developing locally, you can access your Chirpy blog from other devices on your network.

### Enable Network Access

Add `--host 0.0.0.0` to bind to all network interfaces:

```bash
bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000
```

**Output shows:**
```
LiveReload address: http://0.0.0.0:35729
Server address: http://0.0.0.0:4000/
```

### Find Your Local IP

```bash
# Linux/Kali
hostname -I | awk '{print $1}'
# Example: 192.168.1.29

# Or check your prompt/network settings
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### Access from MacBook/Windows

Once Jekyll is running with `--host 0.0.0.0`:

**From MacBook:**
```
http://192.168.1.29:4000/
```

**From Windows:**
```
http://192.168.1.29:4000/
```

**From iPhone/Android:**
```
http://192.168.1.29:4000/
```

Replace `192.168.1.29` with your actual Kali VM IP.

### Automated Function Example

Create a shell function that shows both URLs:

```bash
# In ~/.zshrc or ~/.bashrc
function jchirpy {
    cd ~/Documents/web/ranger-chirpy
    local_ip=$(hostname -I | awk '{print $1}')
    echo "Local:   http://127.0.0.1:4000/"
    echo "Network: http://${local_ip}:4000/"
    bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000
}
```

### Troubleshooting Network Access

**Can't connect from other device:**

1. Check firewall:
```bash
sudo ufw status
# If active, allow port 4000:
sudo ufw allow 4000
```

2. Verify Jekyll is listening on 0.0.0.0:
```bash
netstat -tlnp | grep 4000
# Should show: 0.0.0.0:4000 (not 127.0.0.1:4000)
```

3. Ensure devices are on same network (same WiFi/subnet)

4. Check VM network settings (if using VirtualBox/VMware):
   - Use "Bridged Adapter" not "NAT"
   - VM gets its own IP on your network

### Public Internet Access

For sharing outside your local network, consider:

- **GitHub Pages** - Deploy permanently (this guide)
- **Cloudflare Tunnel** - Temporary public URL without port forwarding
- **Port Forwarding** - Opens your home IP (security risk)

See: [Cloudflare Tunnel: Expose Local Services Securely](/posts/cloudflare-tunnel-expose-local-services/)

## Security Considerations

### Don't Commit Secrets

Add to `.gitignore`:

```
# Sensitive files
.env
*credentials*
*secret*
*.pem
*.key
```

### Review Before Pushing

```bash
# Check what will be committed
git status
git diff --cached

# Review history
git log --oneline
```

### Sensitive Content Warning

Remember: GitHub Pages repos are **public**. Don't include:
- API keys
- Passwords (even in screenshots)
- Private IP addresses
- Client information
- Unpublished vulnerabilities

## Workflow Automation

### Pre-commit Checks

Create `scripts/pre-commit.sh`:

```bash
#!/bin/bash
# Check for common issues before committing

# No future-dated posts
for file in _posts/*.md; do
  date=$(grep "^date:" "$file" | head -1)
  echo "Checking: $file"
done

# No secrets in posts
if grep -r "password\|secret\|api_key" _posts/; then
  echo "WARNING: Potential secret in post!"
  exit 1
fi

echo "Pre-commit checks passed!"
```

### Git Hooks

```bash
# Make executable
chmod +x scripts/pre-commit.sh

# Link to git hooks
ln -s ../../scripts/pre-commit.sh .git/hooks/pre-commit
```

## Cost Comparison

| Platform | Monthly Cost | Custom Domain | SSL | Build Minutes |
|----------|-------------|---------------|-----|---------------|
| **GitHub Pages** | **Free** | Yes (free) | Yes | 2000/month |
| Netlify (free) | Free | Yes | Yes | 300/month |
| Vercel (free) | Free | Yes | Yes | 6000/month |
| DigitalOcean | $4-6 | Manual | Manual | N/A |
| InMotion Shared | $3-8 | Included | Included | N/A |

GitHub Pages is perfect for personal blogs and HTB writeups.

## SUCCESS! It's Live! 🎉

After following all these steps, my blog is now live at:

**https://davidtkeane.github.io/**

The GitHub Actions workflow built the site automatically, and within 2-3 minutes everything was online. All 20+ posts, images, and configuration - all working perfectly!

---

## Daily Workflow: Editing & Publishing

Now that your blog is deployed, here's how to manage it day-to-day.

### Editing an Existing Post

```bash
# 1. Navigate to your blog directory
cd /home/kali/Documents/web/ranger-chirpy

# 2. Edit the post
vim _posts/2025-11-17-your-post.md
# Or use any editor: nano, code, etc.

# 3. Test locally (optional but recommended)
bundle exec jekyll serve
# Visit http://127.0.0.1:4000/ to preview

# 4. Stage the changes
git add _posts/2025-11-17-your-post.md

# 5. Commit with descriptive message
git commit -m "Update: fix typo in deployment post"

# 6. Push to GitHub
git push

# 7. Wait 2-3 minutes for GitHub Actions to rebuild
# Check: https://github.com/yourusername/yourusername.github.io/actions
```

### Creating a New Blog Post

```bash
# 1. Navigate to blog directory
cd /home/kali/Documents/web/ranger-chirpy

# 2. Create new post with correct naming
# Format: YYYY-MM-DD-title-with-dashes.md
touch _posts/2025-11-18-my-new-awesome-post.md

# 3. Edit the post
vim _posts/2025-11-18-my-new-awesome-post.md
```

**Add front matter:**
```yaml
---
title: "My New Awesome Post"
date: 2025-11-18 01:00:00 +0000  # Use 01:00:00 - safe default!
categories: [GitHub, Guides]
tags: [tutorial, beginner, example]
pin: false
math: false
mermaid: false
---

## Introduction

Your content here...
```

**Then publish:**
```bash
# 4. Test locally
bundle exec jekyll serve
# Check http://127.0.0.1:4000/

# 5. Stage new post
git add _posts/2025-11-18-my-new-awesome-post.md

# 6. Commit
git commit -m "Add new post: My New Awesome Post"

# 7. Push to live site
git push

# 8. Verify deployment
# Check GitHub Actions tab for build status
# Your post appears at: https://yourusername.github.io/posts/my-new-awesome-post/
```

### Adding Images to Posts

```bash
# 1. Copy image to assets folder
cp ~/Downloads/screenshot.png assets/img/screenshot.png

# 2. Reference in your post
![Description](/assets/img/screenshot.png)

# 3. Stage both post and image
git add _posts/2025-11-18-post-with-image.md
git add assets/img/screenshot.png

# 4. Commit and push
git commit -m "Add post with screenshot"
git push
```

### Multiple Changes at Once

```bash
# Stage everything
git add .

# Or stage specific files
git add _posts/2025-11-18-post1.md _posts/2025-11-18-post2.md

# Commit all together
git commit -m "Add two new posts about security tools"

# Single push updates everything
git push
```

---

## Quick Reference Card

```bash
# === DAILY COMMANDS ===

# Start local server
cd ~/Documents/web/ranger-chirpy
bundle exec jekyll serve

# Create new post
touch _posts/$(date +%Y-%m-%d)-post-title.md

# Edit post
vim _posts/YYYY-MM-DD-title.md

# Deploy changes
git add .
git commit -m "Your message here"
git push

# Check build status
# https://github.com/username/username.github.io/actions

# View live site
# https://username.github.io/
```

---

## What's Next

In **Part 3**, I'll cover:
- Adding a custom domain (yourdomain.com)
- DNS configuration
- SSL certificate verification
- SEO optimization
- Analytics setup (privacy-respecting options)

## Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Chirpy Deployment Guide](https://chirpy.cotes.page/posts/getting-started/#deploy-by-using-github-actions)
- [Jekyll GitHub Pages](https://jekyllrb.com/docs/github-pages/)
- [GitHub Actions for Jekyll](https://github.com/marketplace/actions/jekyll-actions)

---

*Deployed from Kali Linux VM on MacBook Pro M3*

*Blog live at: https://davidtkeane.github.io/*

