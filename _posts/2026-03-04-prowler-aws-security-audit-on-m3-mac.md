---
title: "Running Prowler AWS Security Audit on M3 Mac with Docker - The Real Journey"
date: 2026-03-04 04:00:00 +0000
categories: [Security, AWS]
tags: [prowler, aws, docker, security, penetration-testing, cloud-security, m3-mac]
pin: false
math: false
mermaid: false
---

## Overview

This is the honest, unfiltered journey of setting up Prowler — the AWS security auditing tool — on an M3 Mac using Docker. It wasn't a straight line. There were broken aliases, SSH configs pointing to missing volumes, wrong command syntax, and a version change that nobody warned about. This post documents every wall we hit and how we got through it.

If you want the clean version, skip to the Quick Reference at the bottom. If you want to learn what can go wrong, read everything.

---

## What is Prowler?

Prowler is an open-source security tool that audits your AWS account against hundreds of security checks — CIS benchmarks, NIST, HIPAA, GDPR, PCI-DSS and more. It finds misconfigurations, open ports, exposed secrets, overly permissive IAM roles, and anything else that shouldn't be there.

Running it takes maybe 10 minutes to set up. Getting it to run correctly takes longer if your machine has baggage — which ours did.

---

## Prerequisites

- Docker Desktop installed and running
- An AWS account with IAM credentials
- M3 Mac (applies to M1/M2/M4 too)
- Basic terminal comfort

---

## Step 1: Pull the Docker Image

Simple enough:

```bash
docker pull toniblyx/prowler:latest
```

This works fine on M3. The image supports ARM64 natively so no architecture headaches here.

---

## Step 2: Get AWS Credentials

### Option A — IAM User (Personal account)

1. Go to **AWS Console** → search `IAM`
2. **Users** → your username → **Security credentials** tab
3. **Access keys** → **Create access key** → choose **CLI**
4. Copy both keys — shown once only

### Option B — SSO/Company Account

1. Go to your SSO portal (e.g. `https://yourcompany.awsapps.com/start`)
2. Click the account → **Command line or programmatic access**
3. Copy the full export block including the session token

### Export them:

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
# Only needed for temporary/SSO credentials:
export AWS_SESSION_TOKEN="..."
```

---

## Step 3: The `aws` Command Wasn't What We Thought

First attempt at verifying credentials:

```bash
aws sts get-caller-identity
```

Got this instead:

```
Warning: Identity file rangerblock.pem not accessible: No such file or directory.
```

Then it hung. Had to Ctrl+C.

**Root cause — two problems:**

### Problem 1: Broken SSH config include

`~/.ssh/config` had this at the top:

```
Include /Volumes/KaliPro/.colima/ssh_config
```

The Kali drive wasn't mounted. SSH was trying to include a config from a missing volume and throwing the warning on every command that touched SSH — including `aws`.

**Fix:**

```bash
# Comment out the missing include in ~/.ssh/config
# Include /Volumes/KaliPro/.colima/ssh_config
```

### Problem 2: `aws` was aliased to SSH

Running `type aws` revealed the real issue:

```
aws: aliased to ssh -i /Users/ranger/.claude/ranger -i rangerblock.pem admin@ec2-44-222-101-125.compute-1.amazonaws.com
```

Someone (me, months ago) had aliased `aws` to SSH into an EC2 instance. Every time `aws` was typed, it tried to open an SSH tunnel to that server. The alias was buried in `~/.zshrc_aliases_folder/ranger_aliases.zsh`.

**Fix:** Commented out the alias and renamed it to `aws-ec2` so the SSH shortcut still works but doesn't hijack the `aws` command:

```bash
# In ~/.zshrc_aliases_folder/ranger_aliases.zsh
# alias aws="ssh -i ..."   ← commented out
alias aws-ec2="ssh -i ~/.ssh/rangerblock.pem admin@ec2-44-222-101-125.compute-1.amazonaws.com"
```

Then reload:

```bash
source ~/.zshrc
```

---

## Step 4: Running Prowler — Wrong Syntax Attempts

Once the AWS CLI was actually reachable, we tried to verify credentials via Docker:

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws sts get-caller-identity
```

**Error:**
```
prowler: error: unrecognized arguments: sts get-caller-identity
```

The Prowler container entrypoint is `prowler` itself — not a shell with `aws` CLI available. So `aws sts get-caller-identity` was being passed as Prowler arguments, not as an AWS CLI command.

**Lesson:** In the Prowler Docker container, `aws` means "scan AWS" (the cloud provider argument), not the AWS CLI binary.

---

## Step 5: Wrong Check Name

Tried a quick single check:

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws -c iam_account_maintain_current_contact_details
```

**Error:**
```
CRITICAL: Invalid check(s) specified: iam_account_maintain_current_contact_details
```

That check name was from an older version of Prowler. Check names change between major versions.

**To get valid check names:**

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws --list-checks
```

---

## Step 6: Wrong Output Format Flag

Tried running a full scan with HTML output:

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -v ~/Desktop/prowler-output:/home/prowler/output \
  toniblyx/prowler:latest \
  aws -M html,json
```

**Error:**
```
error: argument --output-formats/-M: invalid choice: 'html,json'
```

Prowler v5 changed the flag from `-M` accepting comma-separated values to `--output-formats` accepting space-separated values. Also `json` is no longer a valid format — it's now `json-ocsf` or `json-asff`.

**Valid formats in Prowler v5:** `csv` `html` `json-asff` `json-ocsf`

---

## Step 7: The Results

After 1 hour and 8 minutes scanning all 572 checks across all AWS regions:

```
-> Scan completed! |▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉| 572/572 [100%] in 1:08:02.6

There are no findings in Account 133422693592
```

**Zero findings. Clean account.**

572 checks across IAM, S3, EC2, CloudTrail, GuardDuty, KMS, CloudWatch, RDS, Lambda and more — all passed. This is the result you want to see. Either the account is well-configured or minimal in resources, either way it means no low-hanging fruit for an attacker.

---

## Step 8: The Working Command

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -v ~/Desktop/prowler-output:/home/prowler/output \
  toniblyx/prowler:latest \
  aws --output-formats html json-ocsf
```

Prowler starts, connects to AWS, runs all checks, and saves results to `~/Desktop/prowler-output/`.

### What success looks like

```
 _ __  _ __ _____      _| | ___ _ __
| '_ \| '__/ _ \ \ /\ / / |/ _ \ '__|
| |_) | | | (_) \ V  V /| |  __/ |
| .__/|_|  \___/ \_/\_/ |_|\___|_|v5.19.0
|_| Get the most at https://cloud.prowler.com

Date: 2026-03-04 05:33:31

-> Using the AWS credentials below:
  · AWS-CLI Profile: default
  · AWS Regions: all
  · AWS Account: XXXXXXXXXXXX
  · User Id: AIDAR...
  · Caller Identity ARN: arn:aws:iam::XXXXXXXXXXXX:user/ranger

-> Using the following configuration:
  · Config File: /home/prowler/prowler/config/config.yaml
  · Mutelist File: /home/prowler/prowler/config/aws_mutelist.yaml
  · Scanning unused services and resources: False

Executing 572 checks, please wait...
```

When you see **"Executing 572 checks"** — you're in. Prowler has authenticated to AWS and is scanning your entire account across all regions. This takes several minutes depending on how many resources you have.

---

## Troubleshooting Reference

### `aws` command hangs or shows SSH warning

```bash
# Check for broken alias
type aws

# Check for missing SSH includes
head -5 ~/.ssh/config

# Unset any rogue env vars
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE
```

### Credentials not being picked up

Make sure you exported them in the **same terminal session** where you run Docker:

```bash
echo $AWS_ACCESS_KEY_ID   # should show your key
```

### Architecture error on M3

```bash
docker run --rm --platform linux/amd64 \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws --output-formats html
```

### List available checks

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws --list-checks
```

---

## Key Takeaways

1. **Aliases can silently break things.** `aws` aliased to SSH caused every credential check to fail with no obvious error message. Always run `type aws` before troubleshooting further.
2. **SSH config includes must point to real files.** A missing mounted volume caused SSH warnings on every command that touched the network stack.
3. **Prowler v5 changed syntax.** `-M html,json` is dead. Use `--output-formats html json-ocsf` with spaces.
4. **The Prowler container is not a shell.** You can't run `aws sts get-caller-identity` inside it. The `aws` argument tells Prowler which cloud to scan.
5. **Check names change between major versions.** Use `--list-checks` to get current valid check names.

---

## Quick Reference

```bash
# Pull image
docker pull toniblyx/prowler:latest

# Export credentials
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."

# List available checks
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws --list-checks

# Full scan with HTML output
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -v ~/Desktop/prowler-output:/home/prowler/output \
  toniblyx/prowler:latest \
  aws --output-formats html json-ocsf

# Specific region
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws --region eu-west-1 --output-formats html

# CIS Level 1 only
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  toniblyx/prowler:latest \
  aws --compliance cis_1.5_aws --output-formats html
```

---

## Resources

- [Prowler GitHub](https://github.com/prowler-cloud/prowler)
- [Prowler Documentation](https://docs.prowler.com)
- [AWS IAM Security Credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

---

## Support This Content

If this guide saved you time debugging the same walls, consider supporting more content like this!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

---

*Time spent: ~45 minutes. Tools used: Docker, Prowler v5.19.0, AWS IAM, zsh. Platform: M3 Mac, macOS.*
