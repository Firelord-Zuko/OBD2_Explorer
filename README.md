![Python](https://img.shields.io/badge/Python-3.10%2B-blue)
![Flask](https://img.shields.io/badge/Framework-Flask-green)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![LLM](https://img.shields.io/badge/AI_Model-TinyLlama_1.1B-orange)
![Status](https://img.shields.io/badge/Status-Stable-success)

# 🚗 OBD-II Explorer Project

### Author
**Sanford Janes Witcher III**  
**Version:** v1.3.9  
**Date:** October 27, 2025  

---

## 📘 Overview
**OBD-II Explorer** is a self-hosted, offline-capable AI diagnostic web application that decodes automotive error codes using a local LLM (TinyLlama or Mistral).  
It’s optimized for **speed, privacy, and offline operation**, providing instant summaries, technical explanations, and DIY repair guidance through a lightweight **Flask** interface.

---

## 🧩 Project Structure
```
OBD-II_Explorer/
├── app.py                        # Main Flask application logic
├── Dockerfile                    # Container build instructions
├── requirements.txt              # Python dependencies
├── README.md                     # Project documentation
│
├── data/
│   └── obd2_codes.db             # SQLite database of OBD-II codes
│
├── models/
│   └── tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf   # Local lightweight model
│
├── static/
│   ├── styles.css                # Application styles
│
├── templates/
│   └── index.html                # Web front-end
│
└── scripts/
    ├── build.ps1                 # Docker build script
    ├── rebuild.ps1               # Rebuild + clean options
    ├── start_container.ps1       # Start container
    └── stop_container.ps1        # Stop container
```

---

## ⚙️ Configuration

### Environment Variables
| Variable | Default | Description |
|-----------|----------|-------------|
| `DB_PATH` | `/app/data/obd2_codes.db` | Path to SQLite database |
| `MODEL_PATH` | `/app/models/tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf` | Path to local model |
| `CACHE_PATH` | `/app/cache` | Disk cache for AI results |

---

## 🧠 Release Highlights (v1.3.9)

### 🧩 Backend (Flask)
- Maintains database integrity and ensures schema validation  
- Returns AI last-updated timestamps and code source  
- Supports local model inference (TinyLlama / Mistral via llama.cpp)

---

### 🎨 Front-End (index.html + styles.css)
| Feature | Description |
|----------|-------------|
| 🔍 **Code Normalization** | Automatically fixes user input (e.g., `23 → P0023`) |
| 💡 **Smart Suggestions** | “Did you mean P0123?” prompt for invalid input |
| ⏱️ **Timestamp Tracking** | Displays “Last Checked” date/time for each lookup |
| 🧭 **Local Quick Cache** | Instant results on repeat lookups — even offline |
| 🌙 **Light/Dark Mode** | Smooth transitions, persistent preference |
| 🧰 **DIY Recommendations** | Expanded multi-line list with collapsible tips |
| 🗑️ **Smart Clear Button** | Clears history + input field with fade animation |
| ⚡ **Offline Resilience** | Cached data served instantly if backend unreachable |
| 📜 **Icons Restored** | Visual section markers (📜, 📘, 🧰, 🔗, 🕘) |
| 🧠 **Auto-Focus & Select** | Focuses input box after lookup for fast re-entry |
| 📱 **Responsive Design** | Mobile-first layout with compact toolbar |

---

## 🧮 Local Cache Logic
OBD-II Explorer now includes an intelligent caching layer:

| Function | Behavior |
|-----------|-----------|
| **setCache()** | Stores code result JSON in `localStorage` |
| **getCache()** | Loads cached results if available |
| **fromCache** | Displays “⚡ Loaded from Local Cache” for reused codes |
| **clear** | Removes cache + history from localStorage |

This reduces lookup latency to 0ms for previously searched codes and allows fully offline use once results have been cached.

---

## 🧱 Docker Setup

### Build Image
```bash
docker build -t obd2_explorer .
```

### Run Container
```bash
docker run -d -p 8888:8888 \
  --name obd2_explorer \
  -v "${PWD}/models:/app/models" \
  -v "${PWD}/data:/app/data" \
  obd2_explorer
```

Access the web app at:  
🔗 **http://localhost:8888**

---

## 💾 Requirements
- **Python 3.10+**
- **Flask**
- **Docker Desktop** (Windows/Linux)
- **8GB RAM minimum** for LLM inference  
- **Browser with localStorage support**

---

## 🧡 Credits
- **Author:** Sanford Janes Witcher III  
- **Model:** TinyLlama 1.1B Chat (GGUF)  
- **Backend:** Flask + Gunicorn + llama.cpp  
- **Database:** SQLite3  
- **Frontend:** Bootstrap 5 + Vanilla JS  

---

## 🧭 Version History
| Version | Date | Notes |
|----------|------|-------|
| **v1.3.9** | Oct 28, 2025 | Local Quick Cache, offline-ready, smart validation |
| **v1.3.8** | Oct 28, 2025 | Added timestamps, improved dark mode visibility |
| **v1.3.7** | Oct 27, 2025 | Tier 1 UX: narrower input, smoother transitions |
| **v1.3.6** | Oct 27, 2025 | Fixed regex bug + added Clear button UX fade |
| **v1.3.5** | Oct 27, 2025 | Restored icons, input clear logic, dark toggle fix |
| **v1.3.4** | Oct 27, 2025 | Spinner & gradient fix |
| **v1.3.3** | Oct 27, 2025 | Toolbar repositioned + dark toggle cleanup |
| **v1.3.2** | Oct 26, 2025 | Style refinement, centered toolbar |
| **v1.3.1** | Oct 25, 2025 | Input normalization logic added |
| **v1.3.0** | Oct 24, 2025 | Base stable release |

---

## 🏷️ License
This project is licensed under the **MIT License** — free for personal and commercial use with attribution.

---

## 🗕️ Last Updated
**October 27, 2025**
