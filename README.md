# 🚗 OBD-II Explorer Project

### Author
**Sanford Janes Witcher III**  
**Date:** October 26, 2025

---

## 📘 Overview
The **OBD-II Explorer** is an offline, containerized Flask-based web application that uses a **local GGUF LLM (TinyLlama)** via `llama.cpp` for fast, privacy-focused automotive diagnostics. It connects to a local SQLite database of OBD-II codes and provides concise summaries, probable causes, and AI-curated DIY recommendations.

---

## 🧩 Project Structure
```
OBD-II_Explorer/
├── app.py                   # Main Flask application logic
├── Dockerfile               # Container build instructions
├── requirements.txt         # Python dependencies
├── menu.ps1                 # Main PowerShell control dashboard (root)
├── README.md                # Project documentation (this file)
│
├── data/
│   └── obd2_codes.db        # SQLite database file
│
├── models/
│   └── tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf  # Offline model file
│
├── scripts/
│   ├── build.ps1            # Cached build process
│   ├── rebuild.ps1          # Full rebuild (optional no-cache mode)
│   ├── start_container.ps1  # Container startup script
│   ├── stop_container.ps1   # Container shutdown script
│   ├── cleanup.ps1          # Prunes Docker artifacts safely
│   └── rebuild_clean_database.py  # Rebuilds and cleans SQLite DB
│
├── static/
│   ├── styles.css           # Web interface styling
│   └── assets/              # Future image or JS assets
│
├── templates/
│   └── index.html           # Flask HTML front-end
│
└── .dockerignore            # Excludes unnecessary build artifacts
```

---

## ⚙️ Configuration
### Environment Variables
| Variable | Default | Description |
|-----------|----------|-------------|
| `DB_PATH` | `/app/data/obd2_codes.db` | Path to SQLite database |
| `CACHE_PATH` | `/app/cache` | Disk cache location for AI results |

---

## 🐳 Docker Setup
### Build Cached Image
```bash
# From PowerShell Dashboard (menu.ps1)
> 1  # or run manually
> docker build -t obd2_explorer .
```

### Force Rebuild (No Cache)
```bash
> 3  # inside menu.ps1, or manually:
> docker build --no-cache -t obd2_explorer .
```

### Run Container
```bash
docker run -d -p 8888:8888 ^
  --name obd2_explorer ^
  -v "${PWD}/models:/app/models" ^
  -v "${PWD}/data:/app/data" ^
  obd2_explorer
```
Then open **http://localhost:8888** in your browser.

### Prune Old Artifacts
```bash
docker system prune -a -f --volumes
```

---

## 🧠 AI Configuration
- **Model:** `tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf`
- **Backend:** `llama-cpp-python` (runs entirely offline)
- **Threads:** 4 (`n_threads=4`)
- **Context Size:** 1024 tokens
- **Temperature:** 0.1–0.4 depending on module

---

## ⚡ Performance Tips
- Run on SSD storage for faster model loading.
- Keep `models/` and `data/` mounted outside the container.
- Use `diskcache` to reuse AI results between lookups.
- Avoid large base images — `python:3.10-slim-bookworm` used for efficiency.

---

## 🧮 Scripts Summary
| Script | Purpose |
|---------|----------|
| `menu.ps1` | Interactive management dashboard for build, run, stop, logs, and maintenance |
| `build.ps1` | Cached build workflow, runs automatically after changes |
| `rebuild.ps1` | Full rebuild logic, accepts `-NoCache` switch |
| `start_container.ps1` | Starts container with mounted model and DB |
| `stop_container.ps1` | Stops and removes running container |
| `cleanup.ps1` | Safely prunes images, volumes, and cache |
| `rebuild_clean_database.py` | Rebuilds DB from JSON using Phi-2 summarization |

---

## 🧱 PowerShell Menu (menu.ps1)
### Options
| # | Description |
|---|--------------|
| 1 | Build (cached) |
| 2 | Rebuild (cached) |
| 3 | Force rebuild (no cache) |
| 4 | Start container |
| 5 | Stop container |
| 6 | Remove container |
| 7 | View container logs (live) |
| 8 | View container logs (snapshot) |
| 9 | View build log |
| 10 | Export system info |
| 11 | Monitor Docker system stats |
| 12 | Backup SQLite database |
| 13 | Clean old logs |
| 0 | Exit dashboard |

---

## 🛠️ Common Commands
```powershell
# Full prune
.\scripts\cleanup.ps1

# Force rebuild
.\scripts\rebuild.ps1 -NoCache

# Start container
.\scripts\start_container.ps1

# Stop container
.\scripts\stop_container.ps1
```

---

## 🧰 Troubleshooting
| Problem | Cause | Fix |
|----------|--------|-----|
| `bad marshal data (unknown type code)` | Python’s pip/setuptools upgrade mid-build | Rebuild cleanly using `docker builder prune -a -f` before next build |
| `param not recognized` | `param()` not at top of PS1 script | Move `param()` to line 1 below header |
| `Variable reference not valid ':'` | PowerShell misreads colon in path | Use `${Variable}` syntax in `docker run` mounts |
| `Execution policy disabled` | PowerShell policy blocks scripts | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |

---

## 💾 Requirements
- **Windows 10+ or Linux** with Docker Desktop installed
- **Python 3.10+** (used in container)
- **PowerShell 7+** for running management scripts

---

## 🧡 Credits
- Author: **Sanford Janes Witcher III**  
- Offline AI Model: **TinyLlama 1.1B GGUF**  
- Base Runtime: **Flask + Gunicorn + llama.cpp**  
- Database: **SQLite3 (OBD-II Codes)**
