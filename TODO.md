# Chirpy Blog - TODO & Roadmap

**Last Updated:** 2025-11-17
**Blog Location:** `/home/kali/Documents/web/ranger-chirpy/`
**Local URL:** `http://127.0.0.1:4000/`
**Network URL:** `http://192.168.1.29:4000/`

---

## COMPLETED TODAY (2025-11-17) ✅

### Initial Setup
- [x] Installed Jekyll and Ruby on Kali Linux
- [x] Cloned Chirpy starter template
- [x] Configured bundle dependencies
- [x] Set up local development server

### Site Customization
- [x] Changed site title to "Ranger"
- [x] Updated tagline to "Security Research & HTB Writeups"
- [x] Set author name to "Ranger"
- [x] Added profile picture (`rangersmyth-pic.png`)
- [x] Fixed avatar path in `_config.yml`

### Blog Posts Created
- [x] **Python Penetration Testing Tool** - Detailed documentation of pentest.py (PINNED)
- [x] **Jerry HackTheBox Walkthrough** - Complete writeup with exploitation steps
- [x] **Chirpy Part 1: Local Development** - Installation and setup guide
- [x] **Chirpy Part 2: GitHub Pages Deployment** - Deployment instructions with network access
- [x] **Installing Jekyll/Chirpy on Kali** - Complete installation guide
- [x] **Cloudflare Tunnel Guide** - Verified installation and usage
- [x] **Adding Print/Download Buttons** - JavaScript customization guide
- [x] **Customizing Profile/Branding** - Site personalization

### Custom Features
- [x] **Print/PDF/Download Buttons** - Added to all posts
  - Print/PDF button with optimized print stylesheet
  - Copy Link button with clipboard API
  - Download .md button for offline reading
  - Appears only on post pages (not home/categories)
  - Dark mode support

- [x] **Shell Functions/Aliases**
  - `jchirpy` - Start server with Firefox option + network URL display
  - `jpublish` - One-click GitHub publish script
  - `jnewpost` - Interactive new post creator

- [x] **Networking Configuration**
  - Enabled `--host 0.0.0.0` for network access
  - Auto-displays local and network URLs
  - Accessible from MacBook/Windows on same network

- [x] **Documentation**
  - Created `/home/kali/CLAUDE.md` global reference
  - Created `_drafts/TEMPLATE-post.md` for consistency
  - Created this TODO file

### Technical Fixes
- [x] Fixed "future date" issue by using past timestamps
- [x] Fixed zsh function syntax for `jchirpy`
- [x] Fixed post-actions.js to target Chirpy's `.content` class
- [x] Added URL check to only show buttons on `/posts/` pages

---

## HIGH PRIORITY - Next Session 🔴

### Deployment
- [ ] Create GitHub repository for blog
- [ ] Configure GitHub Pages
- [ ] Update `_config.yml` for production (url, baseurl)
- [ ] Push initial content
- [ ] Verify GitHub Actions build
- [ ] Document deployment process

### Content
- [ ] Add more HackTheBox writeups
- [ ] Add TryHackMe writeups
- [ ] Create "About" page with bio
- [ ] Add tool documentation posts

### Features
- [ ] Add Giscus/Disqus comments
- [ ] Configure Google Analytics (or privacy-respecting alternative)
- [ ] Add search functionality improvements
- [ ] Create custom 404 page

---

## MEDIUM PRIORITY 🟡

### SEO & Social
- [ ] Add social preview image for sharing
- [ ] Configure meta descriptions
- [ ] Add structured data (JSON-LD)
- [ ] Set up Google Search Console
- [ ] Create sitemap.xml optimization

### Customization
- [ ] Custom favicon (browser tab icon)
- [ ] Custom code syntax highlighting theme
- [ ] Add "Reading Time" to posts
- [ ] Add "Last Updated" timestamp
- [ ] Create series/collection functionality

### Additional Posts to Write
- [ ] Chirpy Part 3: Custom Domain & SSL
- [ ] Advanced Nmap Scanning Techniques
- [ ] Post-Exploitation Enumeration Scripts
- [ ] Reverse Shell Cheat Sheet
- [ ] Password Cracking with Hashcat/John

### Tools Integration
- [ ] Add RSS feed optimization
- [ ] Set up automatic backup script
- [ ] Create post validation pre-commit hook
- [ ] Add image optimization workflow
- [ ] Implement draft preview system

---

## LOW PRIORITY 🟢

### Advanced Features
- [ ] Add table of contents toggle button
- [ ] Implement "Read Later" with localStorage
- [ ] Add social sharing buttons (Twitter, LinkedIn)
- [ ] Create post rating/feedback system
- [ ] Add code copy button to all code blocks
- [ ] Implement dark/light mode toggle memory

### Design
- [ ] Custom CSS for personal branding
- [ ] Add category-specific icons
- [ ] Create post featured images
- [ ] Animate button interactions
- [ ] Add progress bar for long posts

### Performance
- [ ] Optimize images (WebP format)
- [ ] Lazy load images
- [ ] Minimize JavaScript
- [ ] Add service worker for offline
- [ ] Implement CDN for assets

---

## INFRASTRUCTURE 🔧

### Backup & Version Control
- [ ] Set up automatic Git commits
- [ ] Create backup script for images
- [ ] Document recovery process
- [ ] Set up branch protection rules

### Security
- [ ] Review published content for sensitive info
- [ ] Add security.txt file
- [ ] Configure CORS properly
- [ ] Add Content Security Policy headers

### Monitoring
- [ ] Set up uptime monitoring
- [ ] Add error tracking
- [ ] Monitor broken links
- [ ] Track page load performance

---

## PROJECT STRUCTURE

```
/home/kali/Documents/web/ranger-chirpy/
├── _config.yml              # Main site configuration
├── _posts/                  # All blog posts (8+ posts)
│   ├── 2025-11-17-building-python-pentest-automation-tool.md
│   ├── 2025-11-17-jerry-hackthebox-walkthrough.md
│   ├── 2025-11-17-setting-up-chirpy-jekyll-blog-part-1.md
│   ├── 2025-11-17-deploying-chirpy-to-github-pages.md
│   ├── 2025-11-17-installing-jekyll-chirpy-kali-linux.md
│   ├── 2025-11-17-cloudflare-tunnel-expose-local-services.md
│   ├── 2025-11-17-adding-print-download-buttons-chirpy.md
│   └── 2025-11-17-customizing-chirpy-profile-branding.md
├── _drafts/                 # Templates and unpublished
│   └── TEMPLATE-post.md     # Standard post template
├── _includes/               # Custom includes (overrides theme)
│   ├── metadata-hook.html   # Loads custom JS
│   └── post-actions.html    # Button component (optional)
├── assets/
│   ├── img/
│   │   └── rangersmyth-pic.png  # Profile picture
│   └── js/
│       └── post-actions.js  # Print/Download functionality
├── publish.sh               # Git publish automation
├── TODO.md                  # This file
└── _site/                   # Generated static site (don't edit)
```

---

## QUICK COMMANDS

```bash
# Start local server with Firefox option
jchirpy

# Create new post interactively
jnewpost

# Publish to GitHub (after setup)
jpublish

# Manual Jekyll serve
cd ~/Documents/web/ranger-chirpy
bundle exec jekyll serve --livereload --host 0.0.0.0

# Create tunnel for public access
cloudflared tunnel --url http://localhost:4000

# Check post count
ls -la _posts/ | grep ".md" | wc -l
```

---

## KEY FILES TO MAINTAIN

1. **_config.yml** - Site configuration (restart required for changes)
2. **_posts/** - All blog content
3. **assets/js/post-actions.js** - Print/Download button logic
4. **_includes/metadata-hook.html** - Script loader
5. **publish.sh** - Deployment automation
6. **TODO.md** - This roadmap

---

## METRICS

- **Total Posts:** 8
- **Categories:** HackTheBox, Security, Blogging, Networking
- **Custom Features:** 3 (buttons, aliases, publish script)
- **Lines of JavaScript:** ~260
- **Setup Time:** ~2 hours
- **Documentation:** Comprehensive

---

## NEXT SESSION GOALS

1. Deploy to GitHub Pages (create repo, push, verify)
2. Write 2 more HTB writeups (Blue, Lame, or Netmon)
3. Add comments system (Giscus preferred)
4. Custom favicon and social preview image
5. Create About page with professional bio

---

*This blog is production-ready for local development. Deployment to GitHub Pages is the next major milestone.*
*All features tested and working on Kali Linux ARM64.*

