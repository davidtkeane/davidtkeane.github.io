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

print(f"Loading tokenizer from {MODEL_PATH}...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)

print("Loading model...")
model = AutoModelForCausalLM.from_pretrained(
    MODEL_PATH,
    dtype=DTYPE,
    device_map=DEVICE
)
model.eval()
print("Model loaded!\n")


def chat(user_message: str, max_tokens: int = 500) -> str:
    messages = [{"role": "user", "content": user_message}]
    text = tokenizer.apply_chat_template(
        messages,
        tokenize=False,
        add_generation_prompt=True
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

    # Decode only the new tokens (not the prompt)
    response = tokenizer.decode(
        outputs[0][inputs.input_ids.shape[1]:],
        skip_special_tokens=True
    )
    return response


# Interactive loop
print("Qwen3.5-0.8B ready. Type 'quit' to exit.\n")
print("-" * 50)

while True:
    try:
        user_input = input("You: ").strip()
        if user_input.lower() in ("quit", "exit", "q"):
            print("Rangers lead the way!")
            break
        if not user_input:
            continue

        print("Qwen: ", end="", flush=True)
        response = chat(user_input)
        print(response)
        print("-" * 50)

    except KeyboardInterrupt:
        print("\nRangers lead the way!")
        break
