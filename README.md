![Python](https://img.shields.io/badge/Python-3.10%2B-blue)
![Flask](https://img.shields.io/badge/Framework-Flask-green)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![LLM](https://img.shields.io/badge/AI_Model-TinyLlama_1.1B-orange)
![Status](https://img.shields.io/badge/Status-Stable-success)

# 🚗 OBD-II Explorer v1.4.0

### Author
**Sanford Janes Witcher III**  
**Version:** v1.4.0  
**Date:** October 27, 2025  

---

## 📘 Overview
**OBD-II Explorer** is a self-hosted, offline-capable AI diagnostic web application that decodes automotive error codes using a local quantized LLM (TinyLlama GGUF).  
It’s optimized for **speed, privacy, and offline operation**, providing instant summaries, code explanations, and DIY repair guidance through a lightweight **Flask** interface.

---

## 🧩 Project Structure
```
OBD-II_Explorer/
├── app.py                        # Main Flask backend
├── Dockerfile                    # Container build file
├── requirements.txt              # Python dependencies
├── README.md                     # Project documentation
│
├── data/
│   └── obd2_codes.db             # SQLite database of OBD-II codes
│
├── models/
│   └── tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf   # Local quantized LLM
│
├── static/
│   └── styles.css
│
└── templates/
    └── index.html
```

---

## ⚙️ Configuration

### Environment Variables
| Variable | Default | Description |
|-----------|----------|-------------|
| `DB_PATH` | `/app/data/obd2_codes.db` | SQLite database path |
| `MODEL_PATH` | `/app/models/tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf` | Local model file |
| `CACHE_PATH` | `/app/cache` | Disk cache for AI outputs |

---

## 🧠 Key Features

### Backend (Flask + SQLite)
- 🧩 **Automatic Schema Validation** — Ensures required columns exist.  
- ⚙️ **SQLite WAL Mode** — Write-ahead logging for faster reads & concurrent access.  
- 📇 **Auto-Index Creation** — Builds index on `code` column for instant lookups.  
- ⚡ **In-Memory Cache (15 min)** — Caches recent lookups for zero-latency responses.  
- 🧹 **Background Cleaner** — Removes expired cache entries hourly with live logging.  
- 🤖 **Offline LLM Support** — Uses TinyLlama (GGUF, llama.cpp) for DIY suggestions.  

### Front-End (HTML + JS)
| Feature | Description |
|----------|-------------|
| 🔍 **Smart Code Normalization** | Automatically formats input (e.g., `23 → P0023`) |
| ⚡ **Local Cache** | Saves prior results to browser `localStorage` |
| 🧠 **Dark/Light Mode** | Persistent theme toggle |
| 🕘 **History Section** | Displays 10 most recent lookups |
| 📱 **Responsive Layout** | Scales perfectly for mobile and desktop |
| 💬 **DIY Guidance** | AI-generated repair suggestions with confidence note |

---

## ⚡ Performance Enhancements (v1.4.0)
| Optimization | Description | Result |
|---------------|-------------|--------|
| WAL Mode | Enables concurrent reads & writes | +300–400% DB speed |
| Cache Pragmas | Memory store, tuned page cache | Lower I/O load |
| Auto Index | Instant lookups by code | <3 ms query time |
| In-Memory LRU Cache | 15-minute RAM cache | Zero DB hits for repeats |
| Auto Cleanup Thread | Hourly pruning & stats logging | No memory bloat |
| DiskCache Layer | 7-day persistent AI cache | Fast fallback |

---

## 🧱 Docker Setup

### Build
```bash
docker build -t obd2_explorer .
```

### Run
```bash
docker run -d -p 8888:8888 ^
  -v "${PWD}/models:/app/models" ^
  -v "${PWD}/data:/app/data" ^
  --name obd2_explorer ^
  obd2_explorer
```

**Access the app:**  
🔗 [http://localhost:8888](http://localhost:8888)

---

## 💾 Requirements
- **Python 3.10+**
- **Flask 3.0+**
- **Docker Desktop** (Windows/Linux)
- **8 GB RAM minimum** for local LLM inference
- **Browser with localStorage support**

---

## 🧡 Credits
- **Author:** Sanford Janes Witcher III  
- **Model:** TinyLlama 1.1B Chat (GGUF)  
- **Backend:** Flask + SQLite + llama.cpp  
- **Frontend:** Bootstrap 5 + Vanilla JS  

---

## 🧭 Version History
| Version | Date | Notes |
|----------|------|-------|
| **v1.4.0** | Oct 27 2025 | Added WAL, in-memory caching, auto index, cleanup thread |
| **v1.3.9** | Oct 26 2025 | Local quick cache, dark mode updates |
| **v1.3.0** | Oct 24 2025 | Stable base release |

---

## 🏷️ License
Licensed under the **MIT License** — free for personal and commercial use with attribution.

---

## 🗕️ Last Updated
**October 27, 2025**
