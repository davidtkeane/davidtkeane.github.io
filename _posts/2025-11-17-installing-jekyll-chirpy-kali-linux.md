---
title: "Installing Jekyll and Chirpy Theme on Kali Linux"
date: 2025-11-17 05:00:00 +0000
categories: [Blogging, Chirpy]
tags: [jekyll, chirpy, kali, installation, ruby, setup]
pin: false
math: false
mermaid: false
---

## Overview

This guide walks through installing Jekyll and the Chirpy theme on Kali Linux from scratch. Chirpy is a minimal, responsive Jekyll theme perfect for technical blogs, security writeups, and documentation.

## Prerequisites

- Kali Linux (tested on 2024.x, ARM64 or x86_64)
- Terminal access
- ~500MB disk space
- Internet connection

## Step 1: Install Ruby and Dependencies

Jekyll is built on Ruby, so we need the full Ruby development environment.

### Install Ruby

```bash
# Update package lists
sudo apt update

# Install Ruby and build tools
sudo apt install -y ruby-full build-essential zlib1g-dev

# Verify installation
ruby --version
# Should show: ruby 3.x.x

gem --version
# Should show: 3.x.x
```

### Configure Gem Path

Avoid installing gems as root by setting up a user-level gem directory:

```bash
# Add to ~/.zshrc or ~/.bashrc
echo '# Ruby Gems' >> ~/.zshrc
echo 'export GEM_HOME="$HOME/.gem"' >> ~/.zshrc
echo 'export PATH="$HOME/.gem/bin:$PATH"' >> ~/.zshrc

# Reload shell config
source ~/.zshrc

# Verify path
echo $GEM_HOME
# Should show: /home/kali/.gem
```

### Install Bundler

Bundler manages Ruby gem dependencies:

```bash
gem install bundler

# Verify
bundler --version
# Should show: Bundler version 2.x.x
```

## Step 2: Install Jekyll

```bash
gem install jekyll

# Verify installation
jekyll --version
# Should show: jekyll 4.x.x
```

### Test Jekyll Installation

Create a test site to ensure everything works:

```bash
# Create test site
jekyll new test-site
cd test-site

# Start server
bundle exec jekyll serve

# Visit http://127.0.0.1:4000
# You should see the default Jekyll site

# Clean up (Ctrl+C to stop server first)
cd ..
rm -rf test-site
```

## Step 3: Install Chirpy Theme

### Option A: Chirpy Starter (Recommended)

Best for beginners - minimal setup, easy updates:

```bash
# Clone starter template
git clone https://github.com/cotes2020/chirpy-starter.git my-blog
cd my-blog

# Install dependencies
bundle install

# Test it works
bundle exec jekyll serve
# Visit http://127.0.0.1:4000
```

### Option B: Fork Chirpy Repository

Full control, more complex updates:

```bash
# Fork https://github.com/cotes2020/jekyll-theme-chirpy on GitHub
# Then clone your fork:
git clone https://github.com/YOUR-USERNAME/jekyll-theme-chirpy.git my-blog
cd my-blog

# Install dependencies
bundle install

# Initialize (sets up assets)
bash tools/init

# Build and test
bundle exec jekyll serve
```

## Step 4: Configure Chirpy

Edit `_config.yml` to customize your site:

```yaml
# Site identity
title: Your Site Name
tagline: Your tagline here
description: >-
  Brief description of your site for SEO

# Author info
social:
  name: Your Name
  email: your@email.com
  links:
    - https://github.com/yourusername
    - https://twitter.com/yourusername

# Avatar (profile picture)
avatar: /assets/img/profile.png

# Timezone (important for post dates)
timezone: Europe/Dublin  # or America/New_York, etc.

# Language
lang: en
```

### Add Profile Picture

```bash
# Create image directory if needed
mkdir -p assets/img

# Copy your profile picture
cp /path/to/your/image.png assets/img/profile.png

# Update _config.yml
# avatar: /assets/img/profile.png
```

## Step 5: Create Your First Post

### Post Naming Convention

Posts must be in `_posts/` with this format:
```
YYYY-MM-DD-title-with-dashes.md
```

### Create a Post

```bash
# Create new post
touch _posts/2025-11-17-my-first-post.md
```

Edit the file:

```markdown
---
title: "My First Blog Post"
date: 2025-11-17 12:00:00 +0000
categories: [General, Welcome]
tags: [introduction, first-post]
pin: false
math: false
mermaid: false
---

## Welcome to My Blog!

This is my first post using Jekyll and the Chirpy theme.

### Code Example

```bash
echo "Hello, World!"
```

### What I'll Write About

- Security research
- HackTheBox writeups
- Tool development
- Learning notes

Stay tuned for more content!
```

### Common Front Matter Options

```yaml
---
title: "Post Title"
date: 2025-11-17 12:00:00 +0000    # Use PAST time to avoid "future date" skip
categories: [Main, Sub]             # Hierarchical categories
tags: [tag1, tag2, lowercase]       # Lowercase tags
pin: true                           # Pin to top of homepage
math: true                          # Enable LaTeX math
mermaid: true                       # Enable diagrams
image:                              # Featured image
  path: /assets/img/post/image.png
  alt: Description of image
---
```

## Step 6: Run Your Blog

### Basic Server

```bash
cd my-blog
bundle exec jekyll serve
```

Access at: `http://127.0.0.1:4000/`

### With Live Reload

Auto-refresh browser when files change:

```bash
bundle exec jekyll serve --livereload
```

### Network Access

Allow other devices on network to view:

```bash
bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000
```

Access from other devices: `http://YOUR_KALI_IP:4000/`

### Create an Alias

Add to `~/.zshrc` or `~/.bashrc`:

```bash
alias myblog='cd ~/my-blog && bundle exec jekyll serve --livereload'
```

Reload: `source ~/.zshrc`

## Troubleshooting

### Gem Installation Errors

**Permission denied:**
```bash
# Don't use sudo! Configure gem path instead:
export GEM_HOME="$HOME/.gem"
export PATH="$HOME/.gem/bin:$PATH"
```

**Missing build tools:**
```bash
sudo apt install build-essential zlib1g-dev libffi-dev
```

### Jekyll Serve Errors

**Address already in use:**
```bash
# Find process using port 4000
lsof -i :4000

# Kill it
kill -9 PID

# Or use different port
bundle exec jekyll serve --port 4001
```

**Bundler version mismatch:**
```bash
# Update bundler
gem install bundler

# Delete lock file and reinstall
rm Gemfile.lock
bundle install
```

### Posts Not Showing

**Future date:**
```yaml
# WRONG - might be skipped
date: 2025-11-17 23:00:00 +0000

# CORRECT - use past/current time
date: 2025-11-17 12:00:00 +0000
```

**Wrong location:**
- Must be in `_posts/` directory
- Filename must match `YYYY-MM-DD-title.md`

### Build Errors

**Check for YAML syntax errors:**
```bash
# Validate YAML front matter
bundle exec jekyll build --trace
```

Common issues:
- Missing `---` at start/end of front matter
- Special characters need quoting
- Incorrect indentation

## Updating Chirpy

### Starter Template

```bash
# Check for updates
cd my-blog

# Pull latest changes (if you haven't modified theme files)
git pull origin main

# Update gems
bundle update
```

### Forked Repository

```bash
# Add upstream remote
git remote add upstream https://github.com/cotes2020/jekyll-theme-chirpy.git

# Fetch updates
git fetch upstream

# Merge (may have conflicts)
git merge upstream/main
```

## File Structure

```
my-blog/
├── _config.yml          # Site configuration
├── _posts/              # Your blog posts
├── _tabs/               # Sidebar pages (About, Archives, etc.)
├── _data/               # Site data files
├── assets/
│   ├── img/            # Images (profile pic, post images)
│   ├── css/            # Custom CSS (if needed)
│   └── js/             # Custom JavaScript
├── Gemfile              # Ruby dependencies
├── Gemfile.lock         # Locked versions
└── _site/               # Generated static site (don't edit)
```

## Next Steps

After installation:

1. **Customize appearance** - Edit `_config.yml`
2. **Create content** - Write posts in `_posts/`
3. **Add pages** - Edit files in `_tabs/`
4. **Deploy** - GitHub Pages, Netlify, or VPS
5. **Custom domain** - Point your domain to hosting

See related posts:
- [Setting Up Chirpy - Part 1: Local Development](/posts/setting-up-chirpy-jekyll-blog-part-1/)
- [Setting Up Chirpy - Part 2: GitHub Pages Deployment](/posts/deploying-chirpy-to-github-pages/)
- [Cloudflare Tunnel: Expose Local Services](/posts/cloudflare-tunnel-expose-local-services/)

## Quick Reference

```bash
# Install Ruby
sudo apt install ruby-full build-essential zlib1g-dev

# Configure gem path (add to ~/.zshrc)
export GEM_HOME="$HOME/.gem"
export PATH="$HOME/.gem/bin:$PATH"

# Install Jekyll and Bundler
gem install bundler jekyll

# Clone Chirpy starter
git clone https://github.com/cotes2020/chirpy-starter.git my-blog
cd my-blog
bundle install

# Run server
bundle exec jekyll serve --livereload

# Create new post
touch _posts/$(date +%Y-%m-%d)-my-post-title.md
```

## Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Chirpy Theme Wiki](https://github.com/cotes2020/jekyll-theme-chirpy/wiki)
- [Ruby on Debian/Kali](https://www.ruby-lang.org/en/documentation/installation/#apt)
- [Markdown Guide](https://www.markdownguide.org/)

---

*Jekyll + Chirpy provides a powerful, fast, and secure platform for technical blogging. Once set up, you can focus on writing content in Markdown without worrying about databases or dynamic code.*

