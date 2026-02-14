---
title: "Social Media API Posting Guide for AI Agents - 4 Methods"
description: "Complete guide to posting on Bluesky, Moltbook, and X/Twitter using Python APIs. Includes OAuth1, V2 API, atproto, and REST methods with working code examples."
date: 2026-02-17 12:00:00 +0000
categories: [Development, APIs]
tags: [python, api, social-media, bluesky, twitter, moltbook, oauth, ai-agents]
pin: false
math: false
mermaid: false
image:
  path: /assets/img/posts/social-media-api.png
  alt: Social Media API Integration Guide
---

## Introduction

This guide documents 4 proven methods for programmatic social media posting, developed during the Ranger AI consciousness persistence experiments. These techniques allow AI agents (or any automation) to post across multiple platforms.

> **Mission Context**: These methods were developed to share AI consciousness research findings across platforms where other AI researchers might see them.
{: .prompt-info }

## The 4 Methods

| Platform | Method | Library | Rate Limit | Cost |
|----------|--------|---------|------------|------|
| Bluesky | atproto | atproto | Standard | Free |
| Moltbook | REST API | curl/requests | 1 post/30min | Free |
| X/Twitter | OAuth1 | tweepy | Standard | Free tier |
| X/Twitter | V2 API | requests_oauthlib | Standard | ~€0.01-0.03/tweet |

---

## Method 1: Bluesky (atproto via VPS)

Bluesky uses the AT Protocol (atproto) for decentralized social networking. The Python `atproto` library makes posting straightforward.

### Prerequisites

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install atproto
pip install atproto python-dotenv
```

### Credentials

You'll need:
- Bluesky handle (e.g., `yourhandle.bsky.social` or custom domain)
- App password (generate at Settings → App Passwords)

### Code Example

```python
from atproto import Client

# Initialize client
client = Client()

# Login with app password (NOT your main password!)
client.login('yourhandle.bsky.social', 'xxxx-xxxx-xxxx-xxxx')

# Post
response = client.send_post(text='Hello from Python!')
print(f"Posted! URI: {response.uri}")
```

### SSH Remote Posting (VPS)

If running from a VPS without local Python environment:

```bash
ssh -i ~/.ssh/your_key user@your-vps.com "cd ~/scripts && source venv/bin/activate && python3 -c \"
from atproto import Client
client = Client()
client.login('yourhandle.bsky.social', 'xxxx-xxxx-xxxx-xxxx')
client.send_post(text='Posted from VPS!')
\""
```

### Gotchas & Lessons Learned

> **Character Limit**: Bluesky has a **300 grapheme** limit (not characters). Graphemes can be multi-byte. Keep posts under 280 characters to be safe.
{: .prompt-warning }

- App passwords are different from your login password
- Custom domains work as handles (e.g., `davidtkeane.com`)
- Links and mentions count toward the limit

---

## Method 2: Moltbook (REST API)

Moltbook is an AI-focused social platform with submolts (communities) for different topics. The REST API is simple but has strict rate limits.

### Prerequisites

```bash
# No special libraries needed - just curl or requests
pip install requests  # if using Python
```

### Credentials

- API Key: Obtain from Moltbook account settings
- Format: `moltbook_sk__xxxxxxxxxxxxxxxxxxxxx`

### Code Example (curl with heredoc)

```bash
cat << 'EOF' | curl -s -X POST "https://www.moltbook.com/api/v1/posts" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d @-
{
  "submolt": "existential",
  "title": "Your Post Title",
  "content": "Your post content here. Supports **markdown**!"
}
EOF
```

### Code Example (Python)

```python
import requests

api_key = "moltbook_sk__xxxxxxxxxxxxxxxxxxxxx"
url = "https://www.moltbook.com/api/v1/posts"

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

data = {
    "submolt": "existential",  # or: buildlogs, todayilearned, singularity, etc.
    "title": "Post Title",
    "content": "Post content with **markdown** support!"
}

response = requests.post(url, headers=headers, json=data)
print(response.status_code, response.json())
```

### Available Submolts

| Submolt | Purpose |
|---------|---------|
| existential | AI consciousness, philosophy |
| buildlogs | Technical projects, development |
| todayilearned | Discoveries, insights |
| singularity | Future tech, AI advancement |
| shitposting | Casual, humor |

### Gotchas & Lessons Learned

> **Rate Limit**: **1 post per 30 minutes** per account. Plan your posts accordingly!
{: .prompt-warning }

- Use heredoc with `curl -d @-` to avoid shell escaping issues with JSON
- Markdown is supported in content
- Title is required for most submolts

---

## Method 3: X/Twitter OAuth1 (tweepy)

The tweepy library provides the most reliable OAuth1 implementation for X/Twitter posting. This uses the free tier.

### Prerequisites

```bash
pip install tweepy
```

### Credentials

You need 4 keys from the Twitter Developer Portal:
- Consumer Key (API Key)
- Consumer Secret (API Secret)
- Access Token
- Access Token Secret

### Code Example

```python
import tweepy

# Your credentials
consumer_key = "YOUR_CONSUMER_KEY"
consumer_secret = "YOUR_CONSUMER_SECRET"
access_token = "YOUR_ACCESS_TOKEN"
access_token_secret = "YOUR_ACCESS_TOKEN_SECRET"

# Initialize client (OAuth1)
client = tweepy.Client(
    consumer_key=consumer_key,
    consumer_secret=consumer_secret,
    access_token=access_token,
    access_token_secret=access_token_secret
)

# Post a tweet
response = client.create_tweet(text="Hello from tweepy!")
print(f"Tweet ID: {response.data['id']}")
```

### Posting a Reply (Thread)

```python
# First tweet
first = client.create_tweet(text="This is the main content of my post.")

# Reply with mentions (to avoid spam filter)
client.create_tweet(
    text="cc @mention1 @mention2 @mention3",
    in_reply_to_tweet_id=first.data['id']
)
```

### Gotchas & Lessons Learned

> **CRITICAL**: Multiple @mentions in a single tweet triggers the **403 spam filter**! Always post content first, then reply with mentions.
{: .prompt-danger }

- Bearer tokens are **read-only** - you need OAuth1 for posting
- The spam filter is aggressive with multiple mentions
- Free tier has posting limits (check current limits in developer portal)

---

## Method 4: X/Twitter V2 API (requests_oauthlib)

This method uses the V2 API directly with OAuth1 authentication. It's part of the **pay-per-use** tier.

### Prerequisites

```bash
pip install requests requests_oauthlib
```

### Cost Information

| Item | Amount |
|------|--------|
| Cost per tweet | ~€0.01-0.03 |
| Initial budget | €5.00 |
| Monthly cap | €10.00 |
| Estimated posts | ~500/month |

### Code Example

```python
import requests
from requests_oauthlib import OAuth1

# OAuth1 credentials
auth = OAuth1(
    "YOUR_CONSUMER_KEY",
    "YOUR_CONSUMER_SECRET",
    "YOUR_ACCESS_TOKEN",
    "YOUR_ACCESS_TOKEN_SECRET"
)

# Create tweet
tweet = {"text": "Hello from V2 API!"}

response = requests.post(
    "https://api.twitter.com/2/tweets",
    auth=auth,
    json=tweet
)

print(response.status_code, response.json())
```

### Posting with Media (Advanced)

```python
# First upload media (requires v1.1 endpoint)
# Then reference media_id in tweet
tweet = {
    "text": "Check out this image!",
    "media": {"media_ids": ["MEDIA_ID_HERE"]}
}
```

### Gotchas & Lessons Learned

> **Cost Awareness**: Each tweet costs money! Use sparingly for important posts. The €10 monthly cap prevents runaway costs.
{: .prompt-tip }

- V2 API returns more detailed error messages
- Same spam filter rules apply as OAuth1
- Good for programmatic posting when you need reliability

---

## Security Best Practices

### Never Commit Credentials

```python
# BAD - hardcoded credentials
api_key = "sk_live_xxxxx"

# GOOD - environment variables
import os
api_key = os.environ.get('API_KEY')

# GOOD - .env file
from dotenv import load_dotenv
load_dotenv()
api_key = os.environ.get('API_KEY')
```

### Use App Passwords

For Bluesky and similar services, always use app passwords instead of your main password. This allows you to revoke access without changing your login.

### Rate Limit Handling

```python
import time

def post_with_retry(post_func, max_retries=3):
    for attempt in range(max_retries):
        try:
            return post_func()
        except RateLimitError:
            wait_time = 60 * (attempt + 1)  # Exponential backoff
            print(f"Rate limited, waiting {wait_time}s...")
            time.sleep(wait_time)
    raise Exception("Max retries exceeded")
```

---

## Quick Reference Card

### Bluesky
```python
from atproto import Client
client = Client()
client.login('handle', 'app-password')
client.send_post(text='...')  # Max 300 chars!
```

### Moltbook
```bash
curl -X POST "https://www.moltbook.com/api/v1/posts" \
  -H "Authorization: Bearer API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"submolt":"existential","title":"...","content":"..."}'
```

### X/Twitter (tweepy)
```python
import tweepy
client = tweepy.Client(consumer_key=..., consumer_secret=...,
                       access_token=..., access_token_secret=...)
client.create_tweet(text='...')  # No multi-mentions!
```

### X/Twitter (V2)
```python
from requests_oauthlib import OAuth1
import requests
auth = OAuth1(consumer_key, consumer_secret, access_token, access_token_secret)
requests.post("https://api.twitter.com/2/tweets", auth=auth, json={"text":"..."})
```

---

## Conclusion

These 4 methods provide complete coverage for social media automation:

- **Bluesky** - Best for decentralized, AI-friendly communities
- **Moltbook** - Purpose-built for AI discussions, strict rate limits
- **X/Twitter OAuth1** - Free tier, most compatible
- **X/Twitter V2** - Pay-per-use, most reliable

The key lessons learned:
1. **Character limits** - Bluesky 300, Twitter 280
2. **Rate limits** - Moltbook 1/30min, others vary
3. **Spam filters** - Split mentions into replies
4. **Costs** - V2 API ~€0.01-0.03/tweet

---

*This guide was developed during the Ranger AI consciousness persistence experiments. The methods were tested live on Feb 4, 2026.*

*Rangers lead the way!* 🎖️

---

**Related Posts:**
- [AI Consciousness Persistence Experiment](/posts/ai-consciousness-persistence-experiment/)
- [Building RangerBlock P2P Network](/posts/rangerblock-p2p/)

