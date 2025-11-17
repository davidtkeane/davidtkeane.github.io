---
title: "Customizing Chirpy: Profile Image and Site Branding"
date: 2025-11-17 04:30:00 +0000
categories: [Blogging, Chirpy]
tags: [jekyll, chirpy, customization, branding, configuration]
pin: false
math: false
mermaid: false
---

## Overview

Personalize your Chirpy blog by adding a profile picture, changing the site name, and updating author information. This makes your blog uniquely yours.

## What You'll Customize

- Profile/avatar image in sidebar
- Site title and tagline
- Author name (appears in footer)
- Social media links

## Step 1: Add Profile Picture

### Prepare Your Image

Recommended specifications:
- **Format:** PNG or JPG
- **Size:** 512x512 pixels (square)
- **File size:** Under 500KB

### Copy Image to Assets

```bash
# Create image directory
mkdir -p assets/img

# Copy your profile picture
cp /path/to/your/profile.png assets/img/profile.png

# Or with specific name
cp ~/Documents/images/myavatar.png assets/img/avatar.png
```

Verify it's there:
```bash
ls -la assets/img/
# Should show your image file
```

### Configure in _config.yml

Open `_config.yml` and find the avatar line:

```yaml
# the avatar on sidebar, support local or CORS resources
avatar: /assets/img/profile.png
```

Update it to match your filename:

```yaml
avatar: /assets/img/avatar.png
# or
avatar: /assets/img/rangersmyth-pic.png
```

## Step 2: Change Site Title

In `_config.yml`:

```yaml
# Before
title: Chirpy

# After
title: Ranger
```

This appears in:
- Browser tab/title
- Sidebar header
- SEO metadata

## Step 3: Update Tagline

```yaml
# Before
tagline: A text-focused Jekyll theme

# After
tagline: Security Research & HTB Writeups
```

Appears below the title in the sidebar.

## Step 4: Set Author Name

```yaml
social:
  # This appears in the footer copyright
  name: Ranger
  email: your@email.com  # Optional
```

The name shows in the footer: "© 2025 Ranger"

## Step 5: Update Social Links

```yaml
social:
  name: Ranger
  email: contact@example.com
  links:
    - https://github.com/yourusername
    - https://twitter.com/yourusername
    # Add more as needed
    - https://linkedin.com/in/yourusername
```

These create clickable icons in the sidebar (if theme supports it).

## Step 6: Restart Jekyll

Changes to `_config.yml` require a restart:

```bash
# Stop server (Ctrl+C)
# Restart
bundle exec jekyll serve --livereload
```

Or with your alias:
```bash
jchirpy
```

## Complete Configuration Example

```yaml
# Site identity
title: Ranger
tagline: Security Research & HTB Writeups

description: >-
  Personal blog covering penetration testing,
  HackTheBox writeups, and security tools.

# Author information
social:
  name: Ranger
  email: ranger@example.com
  links:
    - https://github.com/rangersmyth
    - https://twitter.com/rangersmyth

# Profile picture
avatar: /assets/img/rangersmyth-pic.png

# Timezone (affects post dates)
timezone: Europe/Dublin

# Language
lang: en
```

## Verification

After restarting Jekyll:

1. **Check sidebar:**
   - Profile image displays
   - Title shows your name
   - Tagline appears below

2. **Check footer:**
   - Copyright shows your name
   - Year is current

3. **Check browser tab:**
   - Title shows site name
   - On posts: "Post Title | Site Name"

## Troubleshooting

### Image Not Showing

**Check file path:**
```bash
ls -la assets/img/
# Ensure your image file exists
```

**Verify config syntax:**
```yaml
# WRONG - missing leading slash
avatar: assets/img/profile.png

# CORRECT
avatar: /assets/img/profile.png
```

**Clear cache:**
```bash
rm -rf _site .jekyll-cache
bundle exec jekyll serve
```

### Changes Not Appearing

`_config.yml` changes require server restart. Hot reload doesn't apply to config.

```bash
# Ctrl+C to stop
bundle exec jekyll serve --livereload
```

### Image Too Large/Small

Resize before uploading:

```bash
# Using ImageMagick
convert original.png -resize 512x512 avatar.png

# Or using ffmpeg
ffmpeg -i original.png -vf scale=512:512 avatar.png
```

### Wrong File Permissions

```bash
chmod 644 assets/img/profile.png
```

## Advanced Customization

### Social Preview Image

Set a default image for social media sharing:

```yaml
social_preview_image: /assets/img/social-banner.png
```

This appears when your posts are shared on Twitter, Facebook, etc.

### Favicon

Replace favicons in `assets/img/favicons/`:
- favicon.ico
- apple-touch-icon.png
- site.webmanifest

Generate at [favicon.io](https://favicon.io/) or [realfavicongenerator.net](https://realfavicongenerator.net/).

### Custom CSS

For deeper customization, create `assets/css/custom.css`:

```css
/* Larger avatar */
#sidebar .profile-wrapper img {
  width: 150px;
  height: 150px;
}

/* Custom title color */
#sidebar .site-title a {
  color: #00ff00;
}
```

Include in your `_includes/head.html` override.

## File Structure

After customization:

```
ranger-chirpy/
├── _config.yml                    # Main configuration
└── assets/
    └── img/
        ├── profile.png            # Your avatar
        ├── social-banner.png      # Social preview (optional)
        └── favicons/              # Browser icons
            ├── favicon.ico
            └── apple-touch-icon.png
```

## SEO Benefits

Proper branding improves SEO:
- Consistent author name builds recognition
- Professional avatar increases trust
- Descriptive tagline helps search engines
- Social preview images increase click-through

## Quick Checklist

- [ ] Profile image added to `assets/img/`
- [ ] Avatar path set in `_config.yml`
- [ ] Site title updated
- [ ] Tagline customized
- [ ] Author name set
- [ ] Social links added
- [ ] Jekyll restarted
- [ ] Verified in browser

## Next Steps

- Add a favicon for browser tabs
- Create a custom 404 page
- Set up analytics (privacy-respecting)
- Configure comments (Giscus, Disqus)
- Add custom About page content

---

*Personalizing your Chirpy blog makes it stand out and builds your professional brand. These simple changes transform the default theme into your personal space.*

