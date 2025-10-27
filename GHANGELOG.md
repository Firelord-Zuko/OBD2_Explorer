# 🗾️ Changelog
All notable changes to **OBD-II Explorer** are documented here.  
This project follows [Semantic Versioning](https://semver.org/).

---

## [v1.3.0] - 2025-10-27
### 🚀 Added
- `ai_last_updated` field now included in `/lookup` JSON response (Flask API)
- "Description" field displayed below "Summary" in the results section
- Linear gradient blue background for light mode
- Smooth fade-in animation for main content
- Automatic fallback timestamp generation for missing AI data

### 🧩 Changed
- Improved dark mode text color and readability
- Refined PowerShell rebuild scripts:
  - `rebuild.ps1` now supports **cached**, **rebuild**, and **clean** modes
  - `menu.ps1` updated to call correct parameters per mode
- README.md fully rewritten for GitHub clarity and updated architecture

---

## [v1.2.0] - 2025-10-26
### 🚀 Added
- Local SQLite database (`obd2_codes.db`) integration
- Full TinyLlama 1.1B (GGUF) offline model integration with `llama.cpp`
- DIY recommendations generated from fallback checklist via AI logic
- HTML front-end linked to Flask backend for interactive OBD-II lookups

### 🧩 Changed
- Updated `menu.ps1` dashboard with ASCII banner and 13-option control layout
- Added safety checks for missing database columns

---

## [v1.1.0] - 2025-10-24
### 🚀 Added
- Initial PowerShell automation scripts:
  - `build.ps1`, `rebuild.ps1`, and `menu.ps1`
- Docker image and container lifecycle management
- Volume mounting for `/data` and `/models` paths

### 🧩 Changed
- `Dockerfile` optimized for smaller image footprint using Python 3.10-slim
- Added `.dockerignore` for build cache efficiency

---

## [v1.0.0] - 2025-10-23
### 🎉 Initial Release
- Core Flask application (`app.py`)
- Bootstrap 5 web interface
- OBD-II code lookup, summary, and DIY recommendation pipeline
- Basic dark/light theme toggle
- Local JSON response generation with example codes

---

### 🧠 Contributors
**Sanford Janes Witcher III** — Project Author & Chief Architect  

---

### 🧮 Project Links
- **Repository:** [github.com/Firelord-Zuko/OBD2_Explorer](https://github.com/Firelord-Zuko/OBD2_Explorer)
- **Model:** TinyLlama-1.1B-Chat-v1.0.Q5_K_M.gguf  
- **License:** MIT