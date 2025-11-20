---
title: "Setting Up Claude Code with MCP Servers in Kali Linux"
date: 2025-11-19 01:00:00 +0000
categories: [AI-Arsenal, Guides]
tags: [claude, ai, mcp, kali, docker, automation, cli]
pin: false
math: false
mermaid: false
---

## Overview

Getting Claude Code working with Model Context Protocol (MCP) servers in Kali Linux opens up powerful capabilities like database access, web search, and context management directly from your terminal. This guide walks through the complete setup process that works on both Kali VM and Docker containers running on Apple Silicon (M3/M3 Pro).

I'm not claiming to be brilliant here - I just figured this out and thought others might find it useful. This is especially cool because you're running Claude with MCP servers inside a Kali Docker container, inside a Kali UTM VM, all on an M3 chip!

## What I Tested

This setup was successfully tested on:
- **Kali VM on MacBook Pro M3 (18GB RAM)** - UTM virtualization
- **Kali Docker Container on MacBook Pro M3 Pro (18GB RAM)** - Docker with networking

Both setups allowed me to search Brave for "rangersmyth" on GitHub and get back complete results through Claude Code!

## Prerequisites

- Kali Linux (VM or Docker container)
- Claude Code CLI installed and logged in
- Node.js and npm (we'll verify/install)
- Internet connection
- Your MCP server credentials (Supabase, Brave API, etc.)

## Architecture Overview

```
MacBook Pro M3/M3 Pro (ARM64)
├── UTM Kali VM (8GB RAM)
│   ├── Claude Code CLI
│   └── MCP Servers (Supabase, Brave, Context7)
└── Docker Kali Container
    ├── Networking enabled
    ├── Claude Code CLI
    └── MCP Servers
```

## Step 1: Find Claude Code Configuration Location

First, locate where Claude Code stores its configuration:

```bash
# Check for Claude directories
ls -la ~/ | grep -i claude

# Find all claude-related directories
find ~ -name "*claude*" -type d 2>/dev/null
```

**Expected location:**
```
~/.claude/
```

**What you should see:**
```
drwxrwxr-x 10 kali kali  4096 Nov 19 07:58 .claude
-rw-------  1 kali kali 44438 Nov 19 07:55 .claude.json
```

## Step 2: Create MCP Configuration File

Create the MCP configuration at `~/.claude/mcp.json`:

```bash
cat > ~/.claude/mcp.json << 'EOF'
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://postgres:YOUR_PASSWORD@YOUR_HOST.supabase.com:5432/postgres"
      ],
      "apiConfig": {
        "url": "https://YOUR_PROJECT.supabase.co",
        "key": "YOUR_SUPABASE_ANON_KEY"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-brave-search"
      ],
      "env": {
        "BRAVE_API_KEY": "YOUR_BRAVE_API_KEY"
      }
    },
    "context7-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@smithery/cli@latest",
        "run",
        "@upstash/context7-mcp",
        "--key",
        "YOUR_CONTEXT7_API_KEY"
      ]
    }
  }
}
EOF
```

**Important:** Replace the following placeholders:
- `YOUR_PASSWORD` - Your Supabase database password (URL encoded)
- `YOUR_HOST` - Your Supabase database host
- `YOUR_PROJECT` - Your Supabase project ID
- `YOUR_SUPABASE_ANON_KEY` - Your Supabase anonymous key
- `YOUR_BRAVE_API_KEY` - Your Brave Search API key
- `YOUR_CONTEXT7_API_KEY` - Your Context7 API key

### URL Encoding Special Characters

If your password contains special characters, encode them:
- `@` → `%40`
- `?` → `%3F`
- `#` → `%23`
- `!` → `%21`

## Step 3: Verify Node.js and npm

MCP servers require Node.js to run:

```bash
# Check current versions
node --version
npm --version
```

**Expected output:**
```
v20.19.5
9.2.0
```

If Node.js is not installed:

```bash
# Update packages
sudo apt update

# Install Node.js and npm
sudo apt install -y nodejs npm

# Verify installation
node --version
npm --version
```

## Step 4: Validate Configuration

Verify the JSON configuration is valid:

```bash
# Validate JSON syntax
python3 -m json.tool ~/.claude/mcp.json > /dev/null && echo "✓ MCP config JSON is valid"

# Check file permissions
ls -lh ~/.claude/mcp.json

# View configuration (safely)
cat ~/.claude/mcp.json | head -20
```

**Success indicators:**
- ✓ MCP config JSON is valid
- File exists at `~/.claude/mcp.json`
- File is readable (should be 1.1K or similar)

## Step 5: Set Environment Variable

Add the MCP config path to your shell environment:

```bash
# Add to bashrc
echo 'export CLAUDE_CODE_MCP_CONFIG="$HOME/.claude/mcp.json"' >> ~/.bashrc

# Load the new configuration
source ~/.bashrc

# Verify it's set
echo $CLAUDE_CODE_MCP_CONFIG
```

## Step 6: Test MCP Servers

Test each MCP server individually before using with Claude:

### Test Brave Search MCP

```bash
BRAVE_API_KEY="YOUR_BRAVE_API_KEY" timeout 10 npx -y @modelcontextprotocol/server-brave-search
```

**Expected output:**
```
Brave Search MCP Server running on stdio
```

Note: You may see a deprecation warning - this is normal and the server still works.

### Verify PostgreSQL Client (for Supabase)

```bash
which psql
psql --version
```

If not installed:

```bash
sudo apt install -y postgresql-client
```

## Step 7: Restart Claude Code

Exit your current Claude Code session and start a new one:

```bash
# Exit current session
exit

# Start new Claude Code session
claude-code
```

## Step 8: Verify MCP Tools Are Available

In the new Claude Code session, you should now have access to MCP tools with the `mcp__` prefix:

- `mcp__brave_search` - Web search capabilities
- `mcp__postgres` - Database queries
- `mcp__context7` - Context management

### Test Search Functionality

Ask Claude: "Can you search Brave for 'rangersmyth' on GitHub?"

If working correctly, Claude will use the Brave Search MCP server to search and return results!

## Docker Setup Notes

For those running Kali in Docker on M3 chips:

### Create Kali Docker Container

```bash
# Pull Kali Linux image (ARM64 compatible)
docker pull kalilinux/kali-rolling

# Run with networking enabled
docker run -it --name kali-claude \
  --network host \
  kalilinux/kali-rolling /bin/bash

# Inside container: Install required packages
apt update
apt install -y curl nodejs npm git

# Install Claude Code CLI (follow official instructions)
# Log in to your Claude account
# Then follow Steps 1-7 above
```

### Docker Networking

The `--network host` flag ensures MCP servers can make external API calls properly.

## Configuration File Structure

Your final `.claude/` directory should look like:

```
~/.claude/
├── mcp.json                    # MCP server configuration
├── settings.local.json         # Local settings
├── history.jsonl              # Session history
├── projects/                  # Project data
├── session-env/              # Session environment
└── todos/                    # Todo tracking
```

## Troubleshooting

### Issue: MCP tools not appearing after restart

**Problem:** Claude Code doesn't show `mcp__` prefixed tools

**Solution:**
```bash
# Verify config path is set
echo $CLAUDE_CODE_MCP_CONFIG

# Check config file exists and is valid
ls -l ~/.claude/mcp.json
python3 -m json.tool ~/.claude/mcp.json

# Try explicit config path on startup
claude-code --mcp-config ~/.claude/mcp.json
```

### Issue: "command not found: npx"

**Problem:** Node.js/npm not properly installed

**Solution:**
```bash
# Install/reinstall Node.js
sudo apt update
sudo apt install -y nodejs npm

# Verify installation
which npx
npx --version
```

### Issue: Brave Search returns errors

**Problem:** Invalid or missing API key

**Solution:**
1. Verify API key is correct in `~/.claude/mcp.json`
2. Check API key hasn't expired
3. Test API key manually:
```bash
BRAVE_API_KEY="YOUR_KEY" npx -y @modelcontextprotocol/server-brave-search
```

### Issue: Supabase connection fails

**Problem:** Database connection string incorrect

**Solution:**
1. Verify password is URL-encoded properly
2. Check host and port are correct
3. Test connection with psql:
```bash
psql "postgresql://postgres:PASSWORD@HOST:5432/postgres"
```

### Issue: Docker container can't reach external APIs

**Problem:** Network isolation

**Solution:**
```bash
# Restart container with proper networking
docker run -it --name kali-claude --network host kalilinux/kali-rolling
```

## Key Takeaways

1. **MCP enables powerful integrations** - Database access, web search, and context management directly in Claude Code
2. **Works on ARM64 architecture** - Successfully tested on M3/M3 Pro chips via UTM and Docker
3. **Configuration is straightforward** - Single JSON file at `~/.claude/mcp.json`
4. **Nested virtualization works** - Docker container → Kali VM → M3 MacBook all play nicely together
5. **API keys must be protected** - Never commit `mcp.json` to version control

## Quick Reference

```bash
# MCP config location
~/.claude/mcp.json

# Set environment variable
export CLAUDE_CODE_MCP_CONFIG="$HOME/.claude/mcp.json"

# Validate configuration
python3 -m json.tool ~/.claude/mcp.json

# Test Brave Search MCP
BRAVE_API_KEY="YOUR_KEY" npx -y @modelcontextprotocol/server-brave-search

# Restart Claude Code
exit
claude-code
```

## Security Considerations

1. **Never commit API keys** - Add `mcp.json` to `.gitignore`
2. **Use environment variables** - Consider moving keys to env vars
3. **Rotate keys regularly** - Especially if exposed
4. **Restrict permissions** - Keep `mcp.json` readable only by your user

```bash
# Secure the config file
chmod 600 ~/.claude/mcp.json
```

## Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Claude Code CLI Documentation](https://code.claude.com/)
- [Brave Search API](https://brave.com/search/api/)
- [Supabase Documentation](https://supabase.com/docs)
- [Docker Kali Linux](https://www.kali.org/docs/containers/official-kalilinux-docker-images/)

## What's Next?

Now that you have MCP working, you can:
- Create custom MCP servers for your specific needs
- Connect to other databases (MySQL, MongoDB, etc.)
- Build automation workflows with Claude
- Integrate with your internal tools and APIs

---

## Support This Content

If this guide helped you set up Claude Code with MCP servers, consider supporting more tutorials like this!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

Your support helps create more in-depth guides and tutorials!

---

*Testing environment: Kali Linux on MacBook Pro M3/M3 Pro (ARM64), Docker containers, UTM virtualization*
*Time spent: ~2 hours of experimentation and documentation*
