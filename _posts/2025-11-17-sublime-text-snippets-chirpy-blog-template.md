---
title: "Creating Sublime Text Snippets for Blog Post Templates"
date: 2025-11-17 01:00:00 +0000
categories: [Blogging, Tools]
tags: [sublime-text, productivity, automation, chirpy, jekyll, blogging]
pin: false
math: false
mermaid: false
---

## Overview

Learn how to create custom Sublime Text snippets that dramatically speed up your blogging workflow. This guide shows you how to turn repetitive blog post templates into one-keystroke shortcuts.

**What you'll learn:**
- What Sublime Text snippets are and how they work
- How to create a snippet for Jekyll/Chirpy blog posts
- Tab stops and placeholders for efficient navigation
- Real-world example: Full blog post template

**Time saved per post:** ~2-3 minutes of copying, pasting, and formatting

## Prerequisites

- Sublime Text installed
- Basic understanding of XML (we'll walk through it)
- A blog template you want to automate (optional)

## Quick Start (TL;DR)

**Want to try it NOW before reading the details?**

```bash
# 1. Create the snippet file
nano ~/.config/sublime-text/Packages/User/chirpy-post.sublime-snippet

# 2. Paste the full snippet code (see Step 3 below)

# 3. Restart Sublime Text

# 4. Create new file and SAVE AS .md
# Ctrl+N → Ctrl+S → name it "test.md"

# 5. Type: chirpy
# 6. Press: Tab ⭾
# 7. BOOM! Template appears!
```

**Key point:** Must save file as `.md` first, or Tab won't work!

## What Are Sublime Text Snippets?

Snippets are **intelligent shortcuts** that expand into full blocks of text with smart cursor navigation.

**Example workflow:**
```
1. Type: chirpy
2. Press: Tab ⭾
3. Result: Full blog post template appears
4. Press Tab repeatedly to jump between fields
5. Done: Post ready to write in 10 seconds
```

Think of it as autocomplete on steroids - you define the template once, use it forever.

### How Tab Triggers Work

Sublime Text has a **built-in snippet engine** that watches what you type. Here's the magic:

1. **You type a trigger word:** `chirpy`
2. **You press Tab:** ⭾
3. **Sublime checks:** "Is there a snippet with tabTrigger='chirpy'?"
4. **Match found:** Expands the entire `<content>` section
5. **Cursor moves to:** First tab stop (`$1`)
6. **Press Tab again:** Jump to next stop (`$2`, `$3`, etc.)
7. **Final Tab:** Jump to `$0` (end position)

**The Tab key has two modes in Sublime:**
- **No snippet active:** Inserts tab/spaces (normal behavior)
- **After trigger word:** Activates snippet expansion
- **Inside snippet:** Navigates between tab stops

**This works automatically** - no plugins or configuration needed! Just create the `.sublime-snippet` file and Sublime handles the rest.

**Visual example:**
```
You type:  c h i r p y
You press: ⭾ (Tab)
Sublime:   ✨ *EXPANDS TO FULL TEMPLATE* ✨
Cursor:    Positioned at title field
You press: ⭾ (Tab)
Cursor:    Jumps to date field
```

**Cool features:**
- Works in specific file types only (scoped)
- Multiple snippets can exist with different triggers
- Tab stops can have default text
- No limit to snippet length

## Step 1: Understanding Snippet File Location

Sublime Text stores snippets in your User package directory.

```bash
# Find your Sublime Text directory
ls ~/.config/sublime-text*/Packages/User/

# This is where all snippets live
~/.config/sublime-text/Packages/User/
```

**File naming convention:** `descriptive-name.sublime-snippet`

## Step 2: Snippet File Structure

Sublime snippets use XML format with four main components:

```xml
<snippet>
    <content><![CDATA[
        Your template content here
        $1 = first tab stop
        ${2:default text} = second tab stop with default
        $0 = final cursor position
    ]]></content>
    <tabTrigger>keyword</tabTrigger>
    <scope>text.html.markdown</scope>
    <description>What this snippet does</description>
</snippet>
```

### Key Components Explained

| Component | Purpose | Example |
|-----------|---------|---------|
| `<content>` | The template text | Your blog post structure |
| `<tabTrigger>` | Keyword to activate | `chirpy` |
| `<scope>` | Where it works | `text.html.markdown` (markdown files only) |
| `<description>` | Tooltip text | "Chirpy Blog Post Template" |

### Tab Stops Magic

```xml
$1              → First tab position (no default)
${2:Title}      → Second position with "Title" as default
${3:tag1, tag2} → Third position with default tags
$0              → Final cursor position (after all tabs)
```

**How it works:**
- Type trigger word → Press Tab → Cursor jumps to `$1`
- Press Tab again → Cursor jumps to `$2`
- Keep pressing Tab → Navigate through all stops
- Final Tab → Jump to `$0` (end of snippet)

## Step 3: Creating the Chirpy Blog Snippet

Let's create a real snippet for Chirpy/Jekyll blog posts.

### Create the Snippet File

```bash
# Create the snippet file
nano ~/.config/sublime-text/Packages/User/chirpy-post.sublime-snippet
```

### Full Snippet Code

```xml
<snippet>
	<content><![CDATA[
---
title: "${1:Your Post Title Here}"
date: ${2:YYYY-MM-DD} 01:00:00 +0000
categories: [${3:Primary}, ${4:Secondary}]
tags: [${5:tag1, tag2, tag3}]
pin: false
math: false
mermaid: false
---

## Overview

${6:Brief introduction to the topic. What will the reader learn?}

## Prerequisites

- ${7:Requirement 1}
- Requirement 2
- Software/tools needed

## Step 1: First Major Section

Explain the first step or concept.

### Sub-section

Additional details.

\`\`\`bash
# Example command
your-command --with --flags
\`\`\`

**Expected output:**
\`\`\`
Output shown here
\`\`\`

## Step 2: Second Major Section

Continue with next steps.

## Troubleshooting

### Common Issue 1

**Problem:** Description of issue

**Solution:**
\`\`\`bash
fix-command
\`\`\`

## Key Takeaways

1. Important point one
2. Important point two
3. Important point three

## Quick Reference

\`\`\`bash
# Summary of key commands
command-1
command-2
command-3
\`\`\`

## Resources

- [Link Text](https://example.com)
- [Documentation](https://docs.example.com)

---

*${8:Optional footer with metadata}*

$0
]]></content>
	<tabTrigger>chirpy</tabTrigger>
	<scope>text.html.markdown</scope>
	<description>Chirpy Blog Post Template</description>
</snippet>
```

### Breaking Down the Template

**Front Matter (Lines 3-9):**
```yaml
title: "${1:Your Post Title Here}"  ← Tab stop 1
date: ${2:YYYY-MM-DD} 01:00:00      ← Tab stop 2
categories: [${3:Primary}...        ← Tab stops 3-4
tags: [${5:tag1, tag2, tag3}]       ← Tab stop 5
```

**Content Sections:**
- `${6:...}` → Overview placeholder
- `${7:...}` → First prerequisite
- `${8:...}` → Footer metadata
- `$0` → Final cursor position (ready to write)

**Why `01:00:00 +0000`?**
- Jekyll skips posts with future timestamps
- `01:00:00` is always in the past (1 AM UTC)
- Prevents "future date" publish issues

## Step 4: Testing Your Snippet

### Test Procedure

**IMPORTANT:** The file must be saved as `.md` (Markdown) for the snippet to work!

1. **Restart Sublime Text** (to load the new snippet)
2. **Create new file** (Ctrl+N)
3. **SAVE IT FIRST!** (Ctrl+S)
   - Save as: `test.md` or any name ending in `.md`
   - This automatically sets the file to Markdown mode
   - Bottom-right corner should now show "Markdown"
4. **Type:** `chirpy`
5. **Press:** Tab ⭾

**Expected result:** Full template appears with cursor at title field!

**Why save first?**
- The snippet is scoped to `text.html.markdown` (Markdown files only)
- Sublime needs the `.md` extension to recognize it as Markdown
- Without saving, the file is "Plain Text" and the snippet won't trigger

**Alternative method (without saving):**
1. Create new file (Ctrl+N)
2. Manually set syntax: View → Syntax → Markdown
3. Type `chirpy` + Tab

But **saving as .md is faster and more reliable!**

### Navigate Through Fields

```
Tab 1 → Title: "Your Post Title Here"    (type your title)
Tab 2 → Date: YYYY-MM-DD                 (type: 2025-11-17)
Tab 3 → Category 1: Primary              (type: Blogging)
Tab 4 → Category 2: Secondary            (type: Tools)
Tab 5 → Tags: tag1, tag2, tag3           (type: sublime-text, productivity)
Tab 6 → Overview text                    (type your intro)
Tab 7 → First prerequisite               (type: Sublime Text installed)
Tab 8 → Footer                           (type: Time: 30 minutes)
Tab 9 → End of document                  (ready to write!)
```

**Demo workflow:**
```
Type: chirpy → Press: Tab → Full template appears instantly!
```
*Type 'chirpy' → Tab → instant template*

## Troubleshooting

### Snippet Not Triggering

**Problem:** Typing `chirpy` + Tab does nothing

**Most Common Issue:** File not saved as `.md` yet!

**Quick Fix:**
1. Press Ctrl+S (Save)
2. Name it: `anything.md`
3. Look at bottom-right corner → should say "Markdown"
4. Type `chirpy` + Tab again

**Other Solutions:**

1. **Check file is in Markdown mode:**
   - Bottom-right corner must show "Markdown" (not "Plain Text")
   - If it says "Plain Text": View → Syntax → Markdown
   - Or just save as `.md` file (automatic)

2. **Restart Sublime Text:** Close and reopen
   - Snippets only load on startup
   - Or: Tools → Command Palette → "Reload Plugins"

3. **Verify snippet file exists:**
   ```bash
   ls ~/.config/sublime-text/Packages/User/*.sublime-snippet
   ```
   Should show: `chirpy-post.sublime-snippet`

4. **Check file extension:** Must be `.sublime-snippet` (not `.txt` or `.xml`)

### Tab Key Inserts Tabs Instead

**Problem:** Pressing Tab creates spaces/tabs instead of navigating

**Solution:** You're not in a snippet yet. Type the trigger word first (`chirpy`), THEN press Tab.

### XML Parsing Errors

**Problem:** Snippet appears broken or doesn't load

**Solution:** Check for XML syntax errors:
- Ensure `<![CDATA[` and `]]>` are present
- Backticks in code blocks must be escaped: \`\`\`
- All tags properly closed: `<snippet>...</snippet>`

### Scope Not Working

**Problem:** Snippet triggers in all file types

**Solution:** Add proper scope restriction:
```xml
<scope>text.html.markdown</scope>  <!-- Markdown only -->
<scope>source.python</scope>        <!-- Python only -->
<scope>source.shell</scope>         <!-- Bash only -->
```

## Advanced: Create More Snippets

### HTB Writeup Template

```xml
<snippet>
    <content><![CDATA[
---
title: "HTB: ${1:Machine Name}"
date: ${2:YYYY-MM-DD} 01:00:00 +0000
categories: [HackTheBox, ${3:Easy}]
tags: [htb, ${4:linux}, ${5:web}, privesc]
---

## Overview

**Machine:** ${1:Machine Name}
**Difficulty:** ${3:Easy}
**OS:** ${4:Linux}
**IP:** \`${6:10.10.10.x}\`

## Enumeration

\`\`\`bash
# Nmap scan
sudo nmap -sCV -p- ${6:10.10.10.x}
\`\`\`

## User Flag

$0

## Root Flag

]]></content>
    <tabTrigger>htb</tabTrigger>
    <scope>text.html.markdown</scope>
    <description>HackTheBox Writeup Template</description>
</snippet>
```

### Code Block Snippet

```xml
<snippet>
    <content><![CDATA[\`\`\`${1:bash}
${2:# Your code here}
\`\`\`$0]]></content>
    <tabTrigger>code</tabTrigger>
    <scope>text.html.markdown</scope>
    <description>Code Block</description>
</snippet>
```

## Key Takeaways

1. **Snippets save massive time** - One keystroke replaces minutes of copying/pasting
2. **Tab stops are powerful** - Smart navigation makes filling templates fast
3. **Scope restricts where snippets work** - Prevents accidental triggers in wrong file types
4. **XML format is simple** - Once you understand the structure, creating snippets is easy
5. **Customize everything** - Create snippets for any repetitive task

## Quick Reference

```bash
# Snippet file location
~/.config/sublime-text/Packages/User/*.sublime-snippet

# Test snippet
1. Create .md file
2. Type trigger word
3. Press Tab
4. Navigate with Tab

# Common scopes
text.html.markdown     # Markdown files
source.python          # Python files
source.shell           # Bash scripts
source.js              # JavaScript
```

## Real-World Impact

**Before snippets:**
- Copy old post → Delete content → Update metadata → Fix formatting → 3 minutes

**After snippets:**
- Type `chirpy` + Tab → Fill 8 fields → 10 seconds

**Time saved per post:** ~2 minutes 50 seconds
**Posts per week:** 5
**Annual time saved:** ~12 hours 🎉

## Resources

- [Sublime Text Documentation: Snippets](https://docs.sublimetext.io/guide/extensibility/snippets.html)
- [PackageControl: Snippet Manager](https://packagecontrol.io/packages/Snippet%20Manager)
- [My Chirpy Blog Template](https://github.com/YOUR-USERNAME/ranger-chirpy)
- Related post: [Deploying Chirpy to GitHub Pages](/posts/deploying-chirpy-to-github-pages/)

---

*Created with Claude Code | Time: 30 minutes | Tools: Sublime Text, XML*
