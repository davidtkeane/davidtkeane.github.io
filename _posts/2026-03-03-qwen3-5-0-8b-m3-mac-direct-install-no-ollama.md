---
layout: post
title: "Running Qwen3.5-0.8B on M3 Mac — Direct Install Without Ollama (All Errors & Fixes)"
date: 2026-03-03 01:00:00 +0000
categories: [AI, LLM, Homelab]
tags: [qwen, llm, transformers, pytorch, conda, m3mac, local-ai, huggingface, apple-silicon, tutorial]
author: David Keane
description: "A complete honest walkthrough of getting Qwen3.5-0.8B running on M3 Mac using HuggingFace Transformers directly — no Ollama, no shortcuts. Every error hit, every fix applied, model running at the end."
---

# Running Qwen3.5-0.8B on M3 Mac — Direct Install Without Ollama

This is a **real** install log — not a cleaned-up tutorial where everything works first time. I wanted to learn how to run LLMs directly using HuggingFace Transformers, bypassing Ollama completely. Here's every command I ran, every error I hit, and exactly how I fixed each one.

**What you'll have at the end:**
- ✅ Qwen3.5-0.8B running directly via HuggingFace Transformers
- ✅ Apple Metal (MPS) GPU acceleration on M3 Mac
- ✅ Interactive chat loop with no Ollama dependency
- ✅ Understanding of what's actually happening under the hood

**Model:** [Qwen/Qwen3.5-0.8B](https://huggingface.co/Qwen/Qwen3.5-0.8B)
**Size:** ~1.77GB
**License:** Apache 2.0
**Machine:** M3 MacBook Pro (18GB RAM)
**Python:** 3.11 via Miniconda

---

## Why Not Ollama?

Ollama is a great tool but it's a black box. I wanted to understand the actual stack:

```
HuggingFace Hub → SafeTensors weights → Transformers library → PyTorch MPS → M3 GPU
```

Once you understand this, you can swap any model, change any parameter, and build real applications on top.

---

## The Final Working Script

Download: [run_qwen.py](/assets/code/run_qwen.py)

```python
"""
Run Qwen3.5-0.8B locally on M3 Mac using HuggingFace Transformers
No Ollama — direct PyTorch + Metal (MPS) inference
"""

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

MODEL_PATH = "Qwen/Qwen3.5-0.8B"

# Detect best device
if torch.backends.mps.is_available():
    DEVICE = "mps"
    DTYPE = torch.float16
    print("Using Apple Metal (MPS) GPU")
elif torch.cuda.is_available():
    DEVICE = "cuda"
    DTYPE = torch.float16
    print("Using CUDA GPU")
else:
    DEVICE = "cpu"
    DTYPE = torch.float32
    print("Using CPU (slower)")

tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
model = AutoModelForCausalLM.from_pretrained(
    MODEL_PATH,
    dtype=DTYPE,
    device_map=DEVICE
)
model.eval()


def chat(user_message: str, max_tokens: int = 500) -> str:
    messages = [{"role": "user", "content": user_message}]
    text = tokenizer.apply_chat_template(
        messages, tokenize=False, add_generation_prompt=True
    )
    inputs = tokenizer(text, return_tensors="pt").to(DEVICE)

    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=max_tokens,
            temperature=0.7,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id
        )

    return tokenizer.decode(
        outputs[0][inputs.input_ids.shape[1]:], skip_special_tokens=True
    )


print("Qwen3.5-0.8B ready. Type 'quit' to exit.\n")
while True:
    try:
        user_input = input("You: ").strip()
        if user_input.lower() in ("quit", "exit", "q"):
            break
        if not user_input:
            continue
        print("Qwen:", chat(user_input))
        print("-" * 50)
    except KeyboardInterrupt:
        break
```

---

## Step 1 — Set Up Conda Environment

I use a conda env called `ranger` for AI/ML work. First problem: the env had a broken Python path because it was originally created when an external drive (`/Volumes/KaliPro`) was mounted.

**Error:**
```
zsh: bad interpreter: /Volumes/KaliPro/Applications/miniconda3/envs/ranger/bin/python3: no such file or directory
```

**Fix — Recreate the env with local Python:**
```bash
conda remove -n ranger --all -y
conda create -n ranger python=3.11 -y
conda activate ranger
```

---

## Step 2 — Install Dependencies

```bash
pip install transformers torch accelerate huggingface_hub
```

---

## Step 3 — Download and Run the Model

```bash
python3 ~/models/run_qwen.py
```

What followed was a chain of 6 errors, each one teaching something new.

---

## Error 1 — huggingface-cli: bad interpreter

**Command:**
```bash
huggingface-cli download Qwen/Qwen3.5-0.8B --local-dir ~/models/Qwen3.5-0.8B
```

**Error:**
```
zsh: bad interpreter: /Volumes/KaliPro/Applications/miniconda3/envs/ranger/bin/python3: no such file or directory
Fetching 0 files: 0it [00:00, ?it/s]
```

**What happened:** The CLI script was installed when KaliPro external drive was mounted. Shebang line points to a path that no longer exists. The download silently failed — it printed the cache path as if it worked, but fetched 0 files.

**Fix:** Recreate the conda env (done above), then use the model ID directly in Python — let Transformers handle the download automatically:

```python
MODEL_PATH = "Qwen/Qwen3.5-0.8B"  # Transformers downloads and caches this
```

---

## Error 2 — OSError: Incorrect path_or_model_id

**Error:**
```
OSError: Incorrect path_or_model_id: '/Users/ranger/.cache/huggingface/hub/models--Qwen--Qwen3.5-0.8B/snapshots/2fc06364...'
Please provide either the path to a local folder or the repo_id of a model on the Hub.
```

**What happened:** I pointed the script at the HuggingFace cache snapshot directory, thinking the model was there. But since the download failed (Error 1), the directory was empty. Transformers couldn't find `tokenizer_config.json` and threw an error.

**Fix:** Use the HuggingFace repo ID directly:
```python
MODEL_PATH = "Qwen/Qwen3.5-0.8B"
```
Transformers downloads from HuggingFace and caches automatically. No manual download needed.

---

## Error 3 — KeyError: 'qwen3_5' (Transformers too old)

**Error:**
```
KeyError: 'qwen3_5'
ValueError: The checkpoint you are trying to load has model type `qwen3_5`
but Transformers does not recognize this architecture.
```

**What happened:** Transformers was too old — didn't know about the `qwen3_5` architecture. Qwen3.5 is a recent model (2026) that needs a newer Transformers version.

**Fix:**
```bash
pip install --upgrade transformers
```

After upgrade: `transformers==5.2.0` ✅

---

## Error 4 — PyTorch too old (< 2.4 required)

**Error:**
```
Disabling PyTorch because PyTorch >= 2.4 is required but found 2.3.0
ImportError: AutoModelForCausalLM requires the PyTorch library but it was not found in your environment.
```

**What happened:** Transformers 5.2.0 requires PyTorch 2.4+. I had 2.3.0.

**Fix:**
```bash
pip install "torch>=2.4" torchvision torchaudio --upgrade
```

After upgrade: `PyTorch 2.10.0` ✅

Verify Metal GPU works:
```bash
python3 -c "import torch; print('PyTorch:', torch.__version__); print('MPS:', torch.backends.mps.is_available())"
# PyTorch: 2.10.0
# MPS: True
```

---

## Error 5 — NumPy version conflict / soxr crash

This was the persistent enemy. Hit it three times.

**Error:**
```
A module that was compiled using NumPy 1.x cannot be run in NumPy 2.x as it may crash.
ImportError: numpy.core.multiarray failed to import
  File "src/soxr/cysoxr.pyx", line 1, in init soxr.cysoxr
```

**What happened:** `soxr` (an audio resampling library, pulled in by Transformers for audio model support) was compiled against NumPy 1.x. NumPy 2.x was installed. The Cython extension couldn't load.

**Why it kept coming back:** Every `pip install` of a new package pulled in a newer NumPy, overriding any downgrade:
- First run: NumPy 2.3.1
- After `pip install accelerate`: NumPy 2.4.2 (accelerate pulled it in as a dependency)

**Things that didn't fully work:**
```bash
pip install "numpy<2.0"              # Overridden by next install
pip install "numpy==1.26.4" --force-reinstall  # Overridden by accelerate
```

**Fix that actually worked — rebuild soxr from source:**
```bash
pip install soxr --no-binary :all: --force-reinstall
```

This compiles `soxr` fresh against whatever NumPy version is currently installed, so there's no version mismatch. If this fails:
```bash
pip install cython
brew install libsoxr
pip install soxr --no-binary :all: --force-reinstall
```

---

## Error 6 — Missing accelerate

**Error:**
```
ValueError: Using a `device_map`, `tp_plan`, `torch.device` context manager or setting
`torch.set_default_device(device)` requires `accelerate`.
You can install it with `pip install accelerate`
```

**What happened:** `device_map='mps'` in the model loading call requires the `accelerate` library. It wasn't installed yet.

**Fix:**
```bash
pip install accelerate
```

---

## Final Working Install Sequence

After all the above, here's the clean install sequence that works:

```bash
# 1. Create fresh conda env
conda create -n ranger python=3.11 -y
conda activate ranger

# 2. Install PyTorch for Apple Silicon
pip install "torch>=2.4" torchvision torchaudio

# 3. Install Transformers and accelerate
pip install transformers accelerate huggingface_hub

# 4. Fix soxr NumPy conflict (build from source)
pip install soxr --no-binary :all: --force-reinstall

# 5. Run
python3 ~/models/run_qwen.py
```

---

## What It Looks Like Running

```
Using Apple Metal (MPS) GPU
Loading tokenizer from Qwen/Qwen3.5-0.8B...
Loading model...
Qwen3.5-0.8B ready. Type 'quit' to exit.

--------------------------------------------------
You: Tell me about cybersecurity
Qwen: Cybersecurity is the practice of protecting systems, networks,
and programs from digital attacks...
--------------------------------------------------
You: quit
Rangers lead the way!
```

First run downloads ~1.77GB of model weights. Every run after that uses the local cache — instant load.

---

## What Each Part Does (Learning Notes)

| Component | What it does |
|-----------|-------------|
| `AutoTokenizer` | Converts text → token IDs the model understands |
| `AutoModelForCausalLM` | Loads the neural network weights from SafeTensors files |
| `device_map='mps'` | Routes computation to M3 GPU via Apple Metal |
| `torch.float16` | Half precision — 2x memory saving, minimal quality loss |
| `apply_chat_template` | Formats messages in Qwen's expected `<|im_start|>user...` format |
| `max_new_tokens=500` | Maximum tokens to generate (~375 words) |
| `temperature=0.7` | Creativity level (0=deterministic, 1=more random) |
| `do_sample=True` | Use sampling — needed when temperature > 0 |

---

## Ollama vs Direct Transformers

| | Ollama | Direct (Transformers) |
|--|--------|----------------------|
| Setup | `ollama pull model` | 5 steps + fix dependencies |
| Model format | GGUF (quantised, smaller) | SafeTensors (full precision) |
| RAM usage | Lower | Higher (full weights) |
| Speed | Fast (optimised) | Good on MPS |
| Control | Limited CLI flags | Full Python — change everything |
| Learning value | Black box | You see the entire stack |
| Best for | Quick use | Building, learning, customising |

---

## Errors Summary Table

| Error | Cause | Fix |
|-------|-------|-----|
| `bad interpreter: /Volumes/KaliPro/...` | Conda env built on external drive, now unmounted | Recreate env: `conda remove -n ranger --all -y && conda create -n ranger python=3.11` |
| `OSError: Incorrect path_or_model_id` | Empty cache dir (download failed silently) | Use repo ID `"Qwen/Qwen3.5-0.8B"` directly |
| `KeyError: 'qwen3_5'` | Transformers too old for this architecture | `pip install --upgrade transformers` |
| `PyTorch >= 2.4 required but found 2.3.0` | PyTorch too old | `pip install "torch>=2.4" --upgrade` |
| `soxr cysoxr ImportError (numpy mismatch)` | soxr compiled against NumPy 1.x, NumPy 2.x installed | `pip install soxr --no-binary :all: --force-reinstall` |
| `ValueError: requires accelerate` | Missing library for device_map | `pip install accelerate` |

---

## Resources

- [Qwen3.5-0.8B on HuggingFace](https://huggingface.co/Qwen/Qwen3.5-0.8B)
- [run_qwen.py script (this site)](/assets/code/run_qwen.py)
- [HuggingFace Transformers docs](https://huggingface.co/docs/transformers)
- [PyTorch MPS Backend](https://pytorch.org/docs/stable/notes/mps.html)
- [Apple Metal Performance Shaders](https://developer.apple.com/metal/)

---

## Next Steps

- Learn llama.cpp for GGUF quantised models (smaller, faster)
- Try Qwen3.5-9B on M4 Max (128GB RAM — beast mode)
- Build an n8n workflow using this as a local AI backend
- Try vLLM for high-throughput batch inference

---

## Support This Content

If this saved you time (and frustration), consider buying me a coffee!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

---

*Written 2026-03-03 — every error in this post was real, hit during a live session on M3 MacBook Pro. Model confirmed working after 6 errors and 1 hour of dependency battles.*

*Rangers lead the way!* 🎖️
