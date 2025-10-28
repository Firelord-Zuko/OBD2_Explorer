# 🚗 OBD-II Explorer v1.5.0

### Author
**Sanford Janes Witcher III**  
**Version:** v1.5.0  
**Date:** October 28, 2025  

---

## 🆕 New in v1.5.0
- Default dark mode with OS preference detection  
- Fade-in animation for diagnostic results  
- Blue-accented section headers  
- Unified layout spacing and typography  
- Persistent last-code memory and input focus enhancements  
- White footer override for dark mode  
- Final stable release build

---

## 📘 Overview
**OBD-II Explorer** is a self-hosted, offline AI-powered diagnostic web app that decodes automotive error codes using a local quantized LLM (TinyLlama GGUF).  
It’s optimized for **speed, privacy, and reliability**, delivering instant OBD-II definitions and AI repair suggestions without internet dependency.

---

## 🧠 Features
- Lightweight local inference (Mistral / TinyLlama GGUF models)  
- Instant OBD-II code lookup via offline SQLite RAG database  
- Dark/light mode with remembered preference  
- Intelligent formatting for AI-generated repair recommendations  
- Persistent recent lookup history  
- Full offline cache system for speed and redundancy  

---

## 🧰 Installation
### Requirements
- Python 3.10+  
- Flask  
- `llama-cpp-python`  
- `sqlite3` database with enriched OBD-II codes

### Setup
```bash
git clone https://github.com/Firelord-Zuko/OBD2_Explorer.git
cd OBD2_Explorer
pip install -r requirements.txt
python app.py
```
Then open [http://localhost:8888](http://localhost:8888) in your browser.

---

## 🧩 Docker Deployment (Synology / Container Manager)
- Mount `/app` → your project folder  
- Mount `/models` → local `.gguf` model directory  
- Expose **port 8888**  
- Run container with `--device /dev/kfd` and `--device /dev/dri` if GPU acceleration available.  

---

## 🧮 Local Model Example
```bash
llama.cpp --model ./models/tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf --port 8888
```

---

## 📦 Data
`data/obd2_codes.db` contains code definitions, causes, and repair recommendations.  
You can enrich it manually or auto-merge with CSV imports using the included RAG preprocessor script.

---

## 🧾 License
MIT License © 2025 Sanford Janes Witcher III

---

## ⚙️ Version History
- **v1.5.0** – Stable release, dark mode default, UI refinements, persistent cache
- **v1.4.0** – Added enriched code database and offline AI explanations
- **v1.3.x** – Initial functional releases
