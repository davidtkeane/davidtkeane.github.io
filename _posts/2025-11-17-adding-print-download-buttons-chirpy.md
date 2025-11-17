---
title: "Adding Print and Download Buttons to Chirpy Posts"
date: 2025-11-17 04:00:00 +0000
categories: [Blogging, Chirpy]
tags: [jekyll, chirpy, javascript, customization, pdf]
pin: false
math: false
mermaid: false
---

## Overview

Add print/PDF and download functionality to your Chirpy blog posts. This feature lets readers save your content for offline reading - perfect for HTB writeups they want to reference during challenges.

## Features

The buttons provide three functions:
- **Print / PDF** - Opens browser print dialog (save as PDF)
- **Copy Link** - One-click copy post URL to clipboard
- **Download .md** - Save post as Markdown file

## Prerequisites

- Working Chirpy Jekyll blog
- Basic understanding of JavaScript
- Terminal access

## Step 1: Create Directories

```bash
cd ~/Documents/web/ranger-chirpy
mkdir -p _includes assets/js
```

## Step 2: Create the JavaScript File

Create `assets/js/post-actions.js`:

```javascript
// Post Actions: Print, Save, Copy - Auto-inject on posts
(function() {
  'use strict';

  // Only run on actual post pages (URL contains /posts/)
  if (!window.location.pathname.includes('/posts/')) return;

  // Only run on post pages (Chirpy uses 'content' class)
  const postContent = document.querySelector('article .content') || document.querySelector('.post-content');
  if (!postContent) return;

  // Create action buttons HTML
  const actionsHTML = `
    <div class="post-actions" id="post-actions">
      <button onclick="printPost()" class="btn-action" title="Print or Save as PDF">
        <i class="fas fa-print"></i> Print / PDF
      </button>
      <button onclick="copyPostLink()" class="btn-action" title="Copy link to clipboard">
        <i class="fas fa-link"></i> Copy Link
      </button>
      <button onclick="downloadPost()" class="btn-action" title="Download as Markdown">
        <i class="fas fa-download"></i> Download .md
      </button>
    </div>
  `;

  // Insert before content
  if (postContent) {
    postContent.insertAdjacentHTML('beforebegin', actionsHTML);
  }

  // Add styles
  const styles = `
    <style>
    .post-actions {
      display: flex;
      gap: 10px;
      margin: 20px 0;
      padding: 15px;
      background: var(--card-bg);
      border-radius: 8px;
      border: 1px solid var(--btn-border-color, #dee2e6);
      flex-wrap: wrap;
    }

    .btn-action {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 16px;
      background: var(--btn-bg, #f8f9fa);
      color: var(--text-color, #333);
      border: 1px solid var(--btn-border-color, #dee2e6);
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.9rem;
      font-family: inherit;
      transition: all 0.2s ease;
    }

    .btn-action:hover {
      background: var(--btn-active-bg, #e9ecef);
      transform: translateY(-2px);
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    /* Dark mode support */
    [data-mode="dark"] .btn-action {
      background: var(--card-bg, #2a2a2a);
      color: var(--text-color, #d3d3d3);
      border-color: var(--btn-border-color, #404040);
    }

    /* Print styles - hide navigation, show only content */
    @media print {
      .post-actions, #sidebar, #topbar, .post-tail-wrapper,
      #toc-wrapper, footer, .post-navigation {
        display: none !important;
      }
      body { font-size: 11pt; color: #000 !important; background: #fff !important; }
      pre { white-space: pre-wrap !important; border: 1px solid #999 !important; }
      a[href^="http"]:after { content: " [" attr(href) "]"; font-size: 8pt; }
    }
    </style>
  `;
  document.head.insertAdjacentHTML('beforeend', styles);
})();

// Global functions for button clicks
function printPost() {
  window.print();
}

function copyPostLink() {
  navigator.clipboard.writeText(window.location.href).then(() => {
    showFeedback(event, 'Copied!', '#28a745');
  });
}

function downloadPost() {
  const title = document.querySelector('.post-title, h1').innerText.trim();
  const date = document.querySelector('.post-meta time')?.getAttribute('datetime') || new Date().toISOString();
  const content = (document.querySelector('article .content') || document.querySelector('.post-content')).innerText;
  const url = window.location.href;

  let markdown = `# ${title}\n\n`;
  markdown += `**Source:** ${url}  \n`;
  markdown += `**Date:** ${date.split('T')[0]}  \n\n---\n\n`;
  markdown += content;

  const blob = new Blob([markdown], { type: 'text/markdown;charset=utf-8' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = title.toLowerCase().replace(/[^a-z0-9]+/g, '-') + '.md';
  link.click();

  showFeedback(event, 'Downloaded!', '#28a745');
}

function showFeedback(evt, text, color) {
  const btn = evt.target.closest('.btn-action');
  const originalHTML = btn.innerHTML;
  btn.innerHTML = `<i class="fas fa-check"></i> ${text}`;
  btn.style.background = color;
  btn.style.color = '#fff';
  setTimeout(() => {
    btn.innerHTML = originalHTML;
    btn.style.background = '';
    btn.style.color = '';
  }, 2000);
}
```

## Step 3: Include the Script

Create `_includes/metadata-hook.html`:

```html
<!-- Custom metadata hook - Add post action buttons -->
<script defer src="{{ '/assets/js/post-actions.js' | relative_url }}"></script>
```

This hooks into Chirpy's head template and loads the script on every page.

## Step 4: Restart Jekyll

```bash
# Stop current server (Ctrl+C)
# Restart
bundle exec jekyll serve --livereload
```

## Step 5: Test the Buttons

1. Navigate to any post page (e.g., `/posts/jerry-hackthebox-walkthrough/`)
2. Buttons should appear above the content
3. Test each function:
   - **Print / PDF** → Opens print dialog
   - **Copy Link** → Shows "Copied!" confirmation
   - **Download .md** → Downloads Markdown file

## How It Works

### Selective Display

```javascript
// Only shows on post pages, not home or categories
if (!window.location.pathname.includes('/posts/')) return;
```

Buttons only appear on individual post pages (`/posts/post-title/`), not on:
- Home page
- Category listings
- Tag pages
- Archive page

### Print Optimization

The `@media print` CSS hides unnecessary elements:
- Sidebar
- Top navigation
- Table of contents
- Footer
- Share buttons

This creates a clean, printable version focused on content.

### Download Function

Creates a Markdown file with:
- Post title as header
- Source URL for reference
- Original date
- Full content text

Perfect for offline reading or importing into note-taking apps like Obsidian.

## Customization

### Change Button Colors

Modify in the styles section:

```css
.btn-action:hover {
  background: #your-color;
}
```

### Add More Buttons

Add new button in `actionsHTML`:

```html
<button onclick="yourFunction()" class="btn-action">
  <i class="fas fa-icon"></i> Label
</button>
```

### Different Icons

Uses Font Awesome (included in Chirpy). Find icons at [fontawesome.com](https://fontawesome.com/icons).

## Troubleshooting

### Buttons Not Appearing

1. **Check URL:** Must be on `/posts/` page
2. **Verify file exists:** `ls assets/js/post-actions.js`
3. **Check include:** `cat _includes/metadata-hook.html`
4. **Restart Jekyll:** Changes need rebuild

### Copy Not Working

Clipboard API requires HTTPS or localhost. Works locally but may fail on HTTP production sites.

### Print Layout Issues

Adjust `@media print` CSS for your needs. Some elements may need specific hiding.

## File Structure

```
ranger-chirpy/
├── _includes/
│   └── metadata-hook.html      # Loads the JS file
└── assets/js/
    └── post-actions.js         # Button logic and styles
```

## Security Notes

- Scripts run client-side only
- No external dependencies (except Font Awesome from Chirpy)
- No data sent to servers
- Download creates local file only

## Next Steps

- Add social sharing buttons
- Implement "Read Later" with localStorage
- Add "Reading Time" estimate
- Create "Table of Contents" toggle

---

*This enhancement makes your blog more user-friendly, especially for technical content that readers want to save for offline reference.*

