---
title: "I Leaked My Own Gmail Passwords For Two Years And Never Noticed"
date: 2026-09-03 01:00:00 +0000
categories: [Security, Incident Response]
tags: [opsec, gmail, github, credentials, forensics, app-passwords, ai-assisted, honesty]
pin: false
math: false
mermaid: false
---

## The bit where I look like an eejit

Two years. That is how long three of my live Gmail app passwords sat in a **public** GitHub repo with my name on it.

Not hidden in some config file I forgot about. Line 166. Near the top. In a script I ran nearly every day.

And here is the part that still makes me laugh — the comment right beside them said:

```python
'pass': 'xxxxxxxxxxxxxxxx'      # Example - REPLACE WITH YOUR ACTUAL PASSWORD
```

**"Example."** I wrote that when it *was* an example. Then I pasted my real password in and never touched the comment. So every single time I opened that file afterwards, my own brain read the word "Example" and moved on.

I had built myself a blind spot and then signed my name to it.

---

## Table of contents

- [The bit where I look like an eejit](#the-bit-where-i-look-like-an-eejit)
- [How it actually got found](#how-it-actually-got-found)
- [What an app password really is](#what-an-app-password-really-is)
- [Ten emails I did not send](#ten-emails-i-did-not-send)
- [Reading the header like a crime scene](#reading-the-header-like-a-crime-scene)
- [The order you do things in](#the-order-you-do-things-in)
- [Fixing the repo properly](#fixing-the-repo-properly)
- [What I would tell myself two years ago](#what-i-would-tell-myself-two-years-ago)
- [The honest bit](#the-honest-bit)

---

## How it actually got found

It was five in the morning. I had been up all night publishing two research datasets and I was tired and happy and not thinking about anything in particular.

I typed something like *"check the alias gmail for me please and then the gmail file and do a scan."*

That was it. That was the whole thing. No hunch, no alarm, no clever instinct. **I was tidying up.**

Ranger — my AI — found the `gmail` command on my PATH, traced it back to the repo, and scanned it. Thirty seconds later the answer came back with the values masked out, which I appreciated, and one line I did not appreciate at all:

> Three Gmail app passwords are public on GitHub.

I said what you would say.

Then it did the thing that turned a bad feeling into a fact. It pulled the raw file down **from GitHub itself** and compared it byte for byte with the copy on my laptop.

Identical.

Not "might be exposed." Not "check this when you get a chance." **Exposed, confirmed, from the public internet, in one command.**

That distinction matters more than anything else in this post. A warning you can argue with is a warning you will argue with. Proof, you act on.

---

## What an app password really is

If you have 2FA switched on — and you should — Google will not let a script log in with your normal password. So it gives you a 16 character **app password** instead.

Here is the part people miss, and I include myself:

> An app password **bypasses your 2FA entirely.** It is not a lesser credential. It is full IMAP and SMTP access to your mailbox, forever, with no second factor, no prompt on your phone, nothing.

Whoever has it can read every email you own. And your email is the reset button for every other account you have.

I had three of them in a public file for two years.

---

## Ten emails I did not send

Once I knew, I went straight to the Sent folder.

**Ten emails. None of them mine.**

The one I pulled the header for was sent on **1 August 2026**. Subject line "hello krish". The entire body was:

```
hi
```

Sent to a throwaway Outlook address.

I will be honest, my first reaction was relief. It is nothing. It is one word.

And then Ranger explained what I was actually looking at, and the relief went away.

> That is a **credential validation test.** It is what automated harvesters do. They scrape a secret out of a public repo, fire one meaningless email to a burner address to confirm it works, and then the working credential goes on a list. To be used later. Or sold.

The "hi" was not the attack.

**The "hi" was the receipt.**

---

## Reading the header like a crime scene

This is the part I genuinely enjoyed, once the panic wore off. I gave the raw header to Gemini as well, because two engines beat one, and between them the whole story fell out of about fifteen lines of text.

```
Received: from [192.168.5.37] ([219.91.170.xxx])
          by smtp.gmail.com with ESMTPSA
Content-Type: multipart/mixed;
          boundary="===============2881746488724291573=="
```

Three things in there, and every one of them tells you something.

| What | What it means |
|---|---|
| `ESMTPSA` | **Authenticated** SMTP. Not a hijacked browser session — something logged in properly, with a valid credential |
| `192.168.5.37` | Their **internal LAN address**, leaked into the header. Someone's own machine on their own home network |
| `===============<19 digits>==` | The MIME boundary format produced by Python's `smtplib`. A **script**, not a person |

The public IP resolved to a residential broadband connection in Pune, India.

**I am masking the last octet on purpose**, and I want to explain why, because it is the more interesting lesson.

That IP might not be the attacker at all. It could easily be some poor soul whose own machine got popped and is now quietly relaying other people's mail. Publishing it in full does nothing for my security and might point a load of angry internet at a victim.

**The forensics are the story. The IP is not.**

---

## The order you do things in

This is the practical bit. If this ever happens to you, the *sequence* matters more than the speed.

**1. Revoke the credentials first.**
Before you delete anything, before you make the repo private, before you tell anyone. Go to `myaccount.google.com/apppasswords` and kill them all. Revocation is instant. A repo made private is still a repo that was scraped six months ago.

**2. Then hunt for what they left behind.**
This is the one nearly everybody skips, and it is the one that actually matters.

> Revoking the password does **not** evict anyone.

An attacker who has had your mailbox does not need the password again if they set up something that survives losing it. Check every one of these:

- **Filters** — one that quietly forwards, or bins anything containing "security" or "password"
- **Forwarding and POP/IMAP** — an address you did not add
- **Accounts and Import → Grant access** — a *delegate* reads your mail with **their own login**. Changing your password does nothing to it
- **Send mail as** — an alias so replies go to them
- **Recovery email and phone** — changed means they can reset you whenever they fancy
- **Third-party apps** and **your devices** — sign out of everything you do not recognise

I said to Ranger that my email was working fine, I had sent and received all day.

It came straight back:

> Mail working normally proves nothing. A delegate or a forwarding rule is completely silent. You would send and receive exactly as usual while a copy goes somewhere else.

That is the sentence I want tattooed somewhere. **Everything looking normal is not evidence.**

**3. Only then, clean the repo.**

**4. Check the other accounts.**
All three of my passwords were in that file. Only one had been used. The other two — including my beloved **Proxy Busterburg**, a name I refuse to apologise for — had nothing in Sent.

Which I was delighted about for roughly four seconds, until:

> No sent mail is not proof of no access. Mail can be read without anything being sent, and sent items can be deleted by whoever sent them.

Absence of evidence. Not evidence of absence. Revoke all of them regardless.

---

## Fixing the repo properly

Here is the sore one.

**Editing the file does not remove the passwords.** They are in every previous commit, in the diffs, in GitHub's cache, in anything anyone cloned in the last two years. Git remembers.

You cannot un-leak. You can only revoke, and then make sure it cannot happen again.

So we rebuilt it the way it should have been from the start:

```python
# Credentials USED to live in this file as a literal dict. They were
# committed to a public repo and stayed there for two years before anyone
# noticed — the placeholder comment still said "REPLACE WITH YOUR ACTUAL
# CREDENTIALS", so every later glance read as "example, nothing to see".
# They have since been revoked. Nothing secret goes in this file again.

from dotenv import load_dotenv
load_dotenv()

def _load_accounts() -> dict:
    accounts = {}
    for n in range(1, 21):
        user = os.environ.get(f"EMAIL_USER_{n}")
        pw   = os.environ.get(f"EMAIL_PASS_{n}")
        if user and pw:
            accounts[str(n)] = {"user": user.strip(),
                                "pass": pw.replace(" ", "").strip()}
    return accounts
```

I left that comment in deliberately. **Someone should trip over the story before they trip over the mistake.**

And then the kicker. When we checked the repo properly, `python-dotenv` was **already sitting in `requirements.txt`**. There was a `.env_example` file in there too, with the right format, waiting.

**Two years earlier I had known exactly how to do it right. I had installed the tool for it. I just never finished the job.**

The rest of the cleanup:

| | |
|---|---|
| `.gitignore` | did not exist. Now it does, with `.env` in it |
| `.env_example` | had password-shaped strings that made you look twice. Now obvious placeholders |
| Help text | listed all three of my real addresses in plain sight. Gone |
| `extra-bonus/` | a **second copy** of the script — checked, clean, but I would never have thought to look |
| `~/bin/gmail` | the same file again, byte for byte. Fixed and verified by hash |

That second copy is why you scan every tracked file and not just the one you are thinking about. I would have fixed the obvious one, felt great, and left a duplicate sitting there.

---

## What I would tell myself two years ago

**Placeholder comments go stale, and your eyes stop reading them.** If a line ever held a secret, change the comment the moment you fill it in. "Example" is the most dangerous word in that file.

**Set up the safe version before you need it.** I had `.env_example` and `python-dotenv` and I still hardcoded it, because hardcoding took four seconds and doing it right took ten minutes. Ten minutes. Two years.

**Scan your own stuff on a boring Tuesday.** Not because you suspect anything. Precisely because you do not. I found this while tidying up, half asleep, on a whim.

**Verify from the outside.** Reading your local file tells you what you think is published. Pulling the raw file from GitHub tells you what *is* published. They were identical for me. One day they will not be for you.

**Check what survives the fix.** Killing the credential feels like winning. Forwarding rules and delegates do not care what your password is.

---

## The honest bit

I nearly did not write this one.

There is a version of this blog where I quietly rotate the keys, force-push over the history, say nothing, and carry on looking like someone who knows what he is doing. Nobody would ever have known.

But I am doing a masters in cyber security. I had just spent the whole night publishing two research datasets — and in one of those, I documented a bug in my *own* analysis code that had inflated a published figure by four times. Shipped the broken output right alongside the fixed one so anyone can see exactly how I got it wrong.

You cannot do that on Monday and hide this on Tuesday.

Everyone leaks something eventually. The interesting question is never whether you made the mistake. It is what you did in the ninety minutes after you found out.

**Revoke. Hunt for persistence. Clean. Tell people.** In that order.

The other thing worth saying: I did not find this because I am sharp. I found it because I asked. One tired sentence — *"do a scan please"* — at five in the morning. The AI did the boring, thorough, unglamorous part, and it insisted on proving the exposure from the public internet instead of just telling me it looked bad.

**Ask more often.** That is genuinely the whole lesson. The scan costs you thirty seconds. The two years cost me a lot more.

---

*Three app passwords revoked. Repo fixed and pushed. Filters, forwarding, delegates and devices all checked and clean. Proxy Busterburg lives to fight another day.*

**Rangers lead the way.** 🎖️
