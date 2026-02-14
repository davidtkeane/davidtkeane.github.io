---
layout: post
title: "How to Create an Ollama Model from QLoRA Adapters - The Complete Guide"
date: 2026-02-17 08:00:00 +0000
categories: [AI, Tutorial, Ollama, QLoRA]
tags: [ollama, qlora, fine-tuning, llama-cpp, gguf, tutorial, slm, huggingface]
author: David Keane
---

# How to Create an Ollama Model from QLoRA Adapters

**The step-by-step guide I wish I had before spending 7 hours debugging the wrong problem.**

## The Problem

You've trained a QLoRA adapter on Google Colab. You have these files:
```
adapter_config.json
adapter_model.safetensors
tokenizer.json
tokenizer_config.json
...
```

You try to create an Ollama model:
```bash
ollama create mymodel -f Modelfile
# Error: no Modelfile or safetensors files found
```

**What went wrong?** Ollama can't use adapter files directly. You need to MERGE them with the base model first.

## The Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   TRAIN     │───►│   MERGE     │───►│  CONVERT    │───►│   OLLAMA    │
│   QLoRA     │    │  Adapter +  │    │  to GGUF    │    │   Create    │
│  (Colab)    │    │  Base Model │    │  Format     │    │   Model     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
     ✅                  ❌                  ❌                  ❌
   You did this      MISSING!           MISSING!           Won't work!
```

## Prerequisites

- Python 3.10-3.12 (NOT 3.14 - PyTorch compatibility)
- Homebrew (macOS) with llama.cpp tools
- Your adapter files from Colab
- ~10GB free disk space

## Step 1: Set Up Python Environment

```bash
# Create virtual environment with Python 3.12
python3.12 -m venv ~/.venv-merge
source ~/.venv-merge/bin/activate

# Install dependencies
pip install torch transformers peft accelerate sentencepiece
pip install gguf
```

## Step 2: Clone llama.cpp (for conversion)

```bash
git clone --depth 1 https://github.com/ggerganov/llama.cpp
```

## Step 3: Merge Adapter with Base Model

Create `merge_adapter.py`:

```python
#!/usr/bin/env python3
"""Merge QLoRA adapter with base model"""

from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel
import torch
import os

# === CONFIGURE THESE ===
ADAPTER_PATH = "./my_adapter_folder"  # Your adapter files
BASE_MODEL = "HuggingFaceTB/SmolLM2-1.7B-Instruct"  # Or your base model
OUTPUT_DIR = "./merged_model"
# =======================

print("Loading base model...")
base_model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL,
    torch_dtype=torch.float16,
    device_map="auto",
    trust_remote_code=True
)
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL, trust_remote_code=True)

print("Loading adapter...")
model = PeftModel.from_pretrained(base_model, ADAPTER_PATH)

print("Merging...")
merged_model = model.merge_and_unload()

print(f"Saving to {OUTPUT_DIR}...")
os.makedirs(OUTPUT_DIR, exist_ok=True)
merged_model.save_pretrained(OUTPUT_DIR, safe_serialization=True)
tokenizer.save_pretrained(OUTPUT_DIR)

print("Done!")
```

Run it:
```bash
python merge_adapter.py
```

## Step 4: Convert to GGUF Format

```bash
python llama.cpp/convert_hf_to_gguf.py ./merged_model \
    --outfile my-model-f16.gguf \
    --outtype f16
```

This creates a ~3.5GB file (for 1.7B model).

## Step 5: Quantize (Optional but Recommended)

Quantization reduces file size and speeds up inference:

```bash
# Install llama-quantize if needed (macOS)
brew install llama.cpp

# Quantize to Q4_K_M (good balance of size/quality)
llama-quantize my-model-f16.gguf my-model-q4.gguf q4_k_m
```

| Format | Size (1.7B) | Quality | Speed |
|:---|:---:|:---:|:---:|
| F16 | ~3.5GB | Best | Slower |
| Q8_0 | ~1.8GB | Great | Medium |
| Q4_K_M | ~1.0GB | Good | Fast |
| Q4_0 | ~0.9GB | OK | Fastest |

## Step 6: Create Modelfile for Ollama

Create `Modelfile`:

```
FROM ./my-model-q4.gguf

SYSTEM """Your system prompt here.
This is where personality and instructions go."""

PARAMETER temperature 0.4
PARAMETER top_k 50
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.15
PARAMETER stop "User:"
PARAMETER stop "Assistant:"
```

## Step 7: Create Ollama Model

```bash
ollama create mymodel:v1 -f Modelfile
```

## Step 8: Test It!

```bash
ollama run mymodel:v1
```

## The Complete Script

Here's a one-shot script that does everything:

```bash
#!/bin/bash
# merge_and_create_ollama.sh

set -e

ADAPTER_PATH="$1"
MODEL_NAME="$2"
BASE_MODEL="${3:-HuggingFaceTB/SmolLM2-1.7B-Instruct}"

if [ -z "$ADAPTER_PATH" ] || [ -z "$MODEL_NAME" ]; then
    echo "Usage: $0 <adapter_path> <model_name> [base_model]"
    exit 1
fi

# Setup venv
python3.12 -m venv .venv-merge
source .venv-merge/bin/activate
pip install -q torch transformers peft accelerate sentencepiece gguf

# Merge
python3 << EOF
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel
import torch, os

base = AutoModelForCausalLM.from_pretrained("$BASE_MODEL", torch_dtype=torch.float16, device_map="auto", trust_remote_code=True)
tok = AutoTokenizer.from_pretrained("$BASE_MODEL", trust_remote_code=True)
model = PeftModel.from_pretrained(base, "$ADAPTER_PATH")
merged = model.merge_and_unload()
os.makedirs("./merged", exist_ok=True)
merged.save_pretrained("./merged", safe_serialization=True)
tok.save_pretrained("./merged")
EOF

# Convert to GGUF
python3 llama.cpp/convert_hf_to_gguf.py ./merged --outfile ${MODEL_NAME}-f16.gguf --outtype f16

# Quantize
llama-quantize ${MODEL_NAME}-f16.gguf ${MODEL_NAME}-q4.gguf q4_k_m

# Create Modelfile
cat > Modelfile << MFILE
FROM ./${MODEL_NAME}-q4.gguf
PARAMETER temperature 0.4
MFILE

# Create Ollama model
ollama create ${MODEL_NAME}:latest -f Modelfile

echo "Done! Run with: ollama run ${MODEL_NAME}:latest"
```

## Common Mistakes

### Mistake 1: Using base model in Modelfile
```
# WRONG - no trained weights!
FROM smollm2:1.7b
SYSTEM "..."

# RIGHT - includes your training!
FROM ./my-merged-model.gguf
SYSTEM "..."
```

### Mistake 2: Trying to use adapter directly
```bash
# WRONG - adapters can't be used directly
ollama create mymodel -f Modelfile  # with adapter folder
# Error: no Modelfile or safetensors files found

# RIGHT - merge first, then create
python merge_adapter.py  # Creates merged model
python convert_to_gguf.py  # Creates .gguf
ollama create mymodel -f Modelfile  # Now works!
```

### Mistake 3: Wrong Python version
```bash
# WRONG - Python 3.14 may not have PyTorch wheels
python3 -m pip install torch  # Fails

# RIGHT - Use Python 3.10-3.12
python3.12 -m venv .venv
```

## How I Discovered This

I spent 7 hours iterating from V10 to V18 of my AI model, thinking I was debugging training issues. Turns out, my AI assistant was creating Ollama models with just `FROM smollm2:1.7b` + system prompt - the trained weights were never included!

The "breakthrough" moments I achieved were from **prompt engineering alone**. When I finally merged the weights properly in V19, I realized the entire pipeline had been broken.

**Lesson learned**: Always verify your weights are actually in the model!

## Verification

To check if your Ollama model has custom weights:

```bash
# Check model size
ollama list | grep mymodel

# Compare to base model size
# If sizes are identical, you might just have a system prompt!
```

| Model | Size | Likely Has Weights? |
|:---|:---:|:---:|
| Base smollm2:1.7b | 1.8GB | N/A |
| Your model | 1.8GB | Probably NO |
| Your model | 1.0GB (Q4) | YES (different size) |
| Your model | 3.5GB (F16) | YES |

---

*This guide was born from 7 hours of debugging a problem that didn't exist. May it save you the same fate.*

**Rangers lead the way!** 🎖️💥

---

*David Keane (IR240474 / Seldon)*
*Ranger Labs, Dublin, Ireland*
*February 9, 2026*
