# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: Dockerfile
# Description: Builds the OBD-II Explorer offline AI environment
#              using TinyLlama (GGUF via llama.cpp). Provides a
#              lightweight, CPU-friendly Flask API container with
#              local inference and SQLite data support.
# ===============================================================

# =============================================
# 🚗 OBD-II Explorer – Offline GGUF (llama.cpp) Stable Build
# =============================================

FROM python:3.10-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    OMP_NUM_THREADS=4 \
    TOKENIZERS_PARALLELISM=false \
    CACHE_PATH=/app/cache

WORKDIR /app
COPY requirements.txt .

# --- install build deps safely (gcc-12 toolchain) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake git pkg-config \
    && python3 -m pip install --no-cache-dir -U pip setuptools wheel \
    && python3 -m pip install --no-cache-dir -r requirements.txt \
    && find /usr/local/lib/python3.10 -name "*.pyc" -delete \
    && apt-get purge -y build-essential cmake git pkg-config \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*


COPY . .
EXPOSE 8888
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8888", "app:app"]
