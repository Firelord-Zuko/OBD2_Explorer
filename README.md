# 🚗 OBD-II Explorer Project

### Author
**Sanford Janes Witcher III**  
**Version:** v1.3.0  
**Date:** October 27, 2025

---

## 📘 Overview
The **OBD-II Explorer** is an offline, containerized Flask-based web application that uses a **local GGUF LLM (TinyLlama)** via `llama.cpp` for ultra-fast, privacy-focused automotive diagnostics. It connects to a local SQLite database of OBD-II codes and provides concise summaries, descriptions, and AI-curated DIY repair recommendations — even when offline.

---

## 🧩 Project Structure
```
OBD-II_Explorer/
├── app.py                   # Main Flask application logic
├── Dockerfile               # Container build instructions
├── requirements.txt          # Python dependencies
├── menu.ps1                 # Interactive PowerShell control dashboard
├── README.md                # Project documentation
│
├── data/
│   └── obd2_codes.db        # SQLite database file
│
├── models/
│   └── tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf  # Offline model file
│
├── scripts/
│   ├── build.ps1            # Cached build process
│   ├── rebuild.ps1          # Supports cached, rebuild, and clean modes
│   ├── start_container.ps1  # Container startup script
│   ├── stop_container.ps1   # Container shutdown script
│   ├── cleanup.ps1          # Prunes Docker artifacts safely
│   └── rebuild_clean_database.py  # Rebuilds and cleans SQLite DB
│
├── static/
│   ├── styles.css           # Web interface styling
│
├── templates/
│   └── index.html           # Web interface (Flask front-end)
│
└── .dockerignore            # Excludes unnecessary build artifacts
```

---

## ⚙️ Configuration

### Environment Variables
| Variable | Default | Description |
|-----------|----------|-------------|
| `DB_PATH` | `/app/data/obd2_codes.db` | Path to SQLite database |
| `CACHE_PATH` | `/app/cache` | Disk cache for AI results |
| `MODEL_PATH` | `/app/models/tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf` | Local model path |

---

## 🧠 Release Highlights (v1.3.0)

### 🧩 Backend (app.py)
- Added `ai_last_updated` field to API JSON response  
- Ensures timestamp is always returned, falling back to UTC ISO format if missing  
- Automatic database schema validation at runtime (`ensure_columns()`)  
- Improved AI refresh logic for DIY recommendations  

---

### 🎨 Frontend (index.html)
- Introduced **blue gradient background** (`rgb(173,216,255 → rgb(43,151,251)`) for light mode  
- Added **smooth fade-in animation** on page load  
- Improved **dark mode contrast** for text visibility  
- **Description** field now appears directly below the **Summary** section for clarity  
- Mobile-friendly and fully responsive  

---

### ⚙️ Scripts (PowerShell)
#### `rebuild.ps1` Logic
Enhanced with clearly defined build modes:
| Mode | Behavior |
|------|-----------|
| `cached` | Deletes old image before rebuild (keeps container) |
| `rebuild` | Stops container, rebuilds without deletion, restarts container |
| `clean` | Deletes both image and container, performs full rebuild |

#### `menu.ps1` Integration
Refactored to properly invoke rebuild modes:
```powershell
1 → & "$PSScriptRoot\rebuild.ps1" -Mode "cached"
2 → & "$PSScriptRoot\rebuild.ps1" -Mode "rebuild"
3 → & "$PSScriptRoot\rebuild.ps1" -Mode "clean"
```

---

## 🐳 Docker Setup

### Build Cached Image
```bash
docker build -t obd2_explorer .
```

### Rebuild (Cached)
```bash
docker compose build --no-cache
```

### Run Container
```bash
docker run -d -p 8888:8888 ^
  --name obd2_explorer ^
  -v "${PWD}/models:/app/models" ^
  -v "${PWD}/data:/app/data" ^
  obd2_explorer
```

Access the web interface at:  
🔗 **http://localhost:8888**

---

## 🧠 AI Model Configuration
| Parameter | Value |
|------------|--------|
| Model | TinyLlama 1.1B Chat (Q5_K_M) |
| Backend | llama.cpp (via `llama-cpp-python`) |
| Context | 1024 tokens |
| Threads | 4 |
| Temperature | 0.1 |
| Cache | Disk-based (7-day expiry) |

---

## 🧮 Front-End Features
| Feature | Description |
|----------|-------------|
| 🔍 Instant lookups | Code search via lightweight Flask endpoint |
| 🦾 Summary + Description | Combined human-readable explanation |
| 🧰 DIY Fixes | 5–8 AI-curated repair suggestions |
| 🌙 Light/Dark Mode | Persistent user theme setting |
| 🦭 Recent History | LocalStorage-based lookup history |
| 🔗 Forum Links | Auto-generated resource references |

---

## 🧱 PowerShell Menu (menu.ps1)
| # | Description |
|---|--------------|
| 1 | Build (cached) |
| 2 | Rebuild (cached, no deletion) |
| 3 | Force rebuild (no cache) |
| 4 | Start container |
| 5 | Stop container |
| 6 | Remove container |
| 7 | View container logs (live) |
| 8 | View container logs (snapshot) |
| 9 | View build log |
| 10 | Export system info |
| 11 | Monitor Docker system stats |
| 12 | Backup database |
| 13 | Clean logs |
| 0 | Exit dashboard |

---

## 🧰 Troubleshooting
| Problem | Cause | Fix |
|----------|--------|-----|
| AI timestamp shows “Unknown” | Old app.py missing timestamp field | Update to v1.3.0 |
| Slow response | Model cold-start | First request warms up TinyLlama |
| Dark mode text unreadable | Old index.html styles | Replace with latest v1.3.0 file |
| PowerShell errors | Incorrect rebuild flags | Update menu.ps1 to v1.3.0 version |

---

## 💾 Requirements
- **Windows 10+ / Linux** with Docker Desktop  
- **PowerShell 7+** for management scripts  
- **Python 3.10+** (inside container)  
- **8GB+ RAM** recommended for smooth inference  

---

## 🧡 Credits
- **Author:** Sanford Janes Witcher III  
- **Model:** TinyLlama 1.1B Chat (GGUF)  
- **Backend:** Flask + Gunicorn + llama.cpp  
- **Database:** SQLite3  
- **Frontend:** Bootstrap 5 + Vanilla JS  

---

## 🏷️ Version History
- **v1.3.0** — AI timestamp integration, UI improvements, and script refinements  
- **v1.2.0** — Offline model integration and caching system  
- **v1.1.0** — Docker build and PowerShell automation  
- **v1.0.0** — Initial Flask + HTML application setup  

---

## 🗕️ Last Updated
**October 27, 2025**