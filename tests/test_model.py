from transformers import AutoModelForCausalLM, AutoTokenizer
import torch, time

model_name = "TinyLlama/TinyLlama-1.1B-Chat-v0.6"
print(f"Loading {model_name}...")
t0 = time.time()

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=torch.float16, device_map="cpu")

prompt = "Explain OBD-II code P0301 in one sentence."
inputs = tokenizer(prompt, return_tensors="pt")
outputs = model.generate(**inputs, max_new_tokens=64)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))

print(f"\nResponse time: {time.time() - t0:.2f}s")
