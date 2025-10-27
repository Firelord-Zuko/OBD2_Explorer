# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 27, 2025
# File: app.py
# Description: Main Flask web application for the OBD-II Explorer.
#              Provides a fast, local AI-assisted interface for
#              OBD-II code lookup, summarization, and DIY guidance
#              using TinyLlama (GGUF, llama.cpp) offline inference.
# ===============================================================

import os
import re
import random
import sqlite3
from datetime import datetime, timedelta
from flask import Flask, request, jsonify, render_template
from textwrap import shorten
from diskcache import Cache
from llama_cpp import Llama

# ---------------------------
# Flask Setup
# ---------------------------
app = Flask(
    __name__,
    template_folder=os.path.join(os.path.dirname(os.path.abspath(__file__)), "templates"),
    static_folder=os.path.join(os.path.dirname(os.path.abspath(__file__)), "static")
)

# ---------------------------
# Configuration
# ---------------------------
DB_PATH = os.getenv("DB_PATH", "/app/data/obd2_codes.db")
MODEL_PATH = "/app/models/tinyllama-1.1b-chat-v1.0.Q5_K_M.gguf"
CACHE_PATH = os.getenv("CACHE_PATH", "/app/cache")
CONFIDENCE_NOTE = (
    "\n\n⚠️ These are AI provided DIY suggestions. "
    "Please verify compatibility with your specific vehicle model "
    "and consult a professional if uncertain."
)
REFRESH_DAYS = 30

# ---------------------------
# Initialize Cache
# ---------------------------
cache = Cache(CACHE_PATH)

# ---------------------------
# Lazy Load Model
# ---------------------------
llm = None

def load_llm():
    global llm
    if llm is not None:
        return
    print("⏳ Loading quantized TinyLlama (GGUF model via llama.cpp)...")
    llm = Llama(
        model_path=MODEL_PATH,
        n_ctx=1024,
        n_threads=4,
        n_batch=256,
        verbose=False
    )
    print("✅ GGUF model loaded successfully (offline).")

# ---------------------------
# Database Helpers
# ---------------------------
def get_db():
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

def ensure_columns():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='obd_codes';")
    if not cur.fetchone():
        print("⚠️ Table 'obd_codes' not found.")
        conn.close()
        return
    cur.execute("PRAGMA table_info(obd_codes);")
    existing = [r["name"] for r in cur.fetchall()]
    for col in ["summary", "diy_checks", "source", "ai_last_updated"]:
        if col not in existing:
            cur.execute(f"ALTER TABLE obd_codes ADD COLUMN {col} TEXT;")
            print(f"✅ Added column: {col}")
    conn.commit()
    conn.close()

# ---------------------------
# Text Utilities
# ---------------------------
def summarize_text(text, max_sentences=3):
    if not text:
        return "No summary available."
    sentences = re.split(r"(?<=[.!?]) +", text.strip())
    return shorten(" ".join(sentences[:max_sentences]), width=500, placeholder="...")

# ---------------------------
# Fallback Pool
# ---------------------------
FALLBACK_POOL = [
    "Check and clean the affected sensor connector",
    "Verify wiring continuity with a multimeter",
    "Test sensor output voltage or resistance values",
    "Inspect the condition of the vehicle's windshield wipers and washer system",
]

# ---------------------------
# AI Selection Logic (llama.cpp)
# ---------------------------
def ai_select_from_fallback(description: str):
    """Use llama.cpp to select the most relevant fallback items."""
    cached = cache.get(description)
    if cached:
        print(f"⚡ Cache hit for: {description[:50]}...")
        return cached

    load_llm()

    prompt = f"""
You are a vehicle diagnostics assistant.
Select the 5 most relevant troubleshooting steps from the list below
based on this issue description.

Issue: "{description}"

List of steps:
{chr(10).join(f'- {item}' for item in FALLBACK_POOL)}

Respond with exactly 5 steps from the list, one per line, no extra text.
"""

    try:
        result = llm(
            prompt,
            max_tokens=150,
            temperature=0.1,
            top_p=0.9,
            repeat_penalty=1.05
        )
        text = result["choices"][0]["text"]
        selected = []
        for line in text.splitlines():
            clean = line.strip("•- \t").strip()
            matches = [item for item in FALLBACK_POOL if clean.lower() in item.lower()]
            if matches:
                selected.extend(matches)

        if not selected:
            print("⚠️ No valid AI matches — using random fallback.")
            selected = random.sample(FALLBACK_POOL, k=5)

        selected = list(dict.fromkeys(selected))[:5]
        result_text = "\n".join(f"• {tip}" for tip in selected) + CONFIDENCE_NOTE
        cache.set(description, result_text, expire=60 * 60 * 24 * 7)
        return result_text

    except Exception as e:
        print(f"⚠️ llama.cpp inference error: {e}")
        selected = random.sample(FALLBACK_POOL, k=5)
        result_text = "\n".join(f"• {tip}" for tip in selected) + CONFIDENCE_NOTE
        cache.set(description, result_text)
        return result_text

# ---------------------------
# Flask Routes
# ---------------------------
@app.route("/")
def home():
    return render_template("index.html")

@app.route("/lookup", methods=["POST"])
def lookup():
    ensure_columns()
    data = request.get_json(force=True)
    code = data.get("code", "").strip().upper()
    if not code:
        return jsonify({"error": "No code provided."}), 400

    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT code, description, summary, diy_checks, source, ai_last_updated
        FROM obd_codes
        WHERE code = ?
    """, (code,))
    row = cur.fetchone()

    if not row:
        conn.close()
        return jsonify({
            "code": code,
            "summary": "Code not found.",
            "description": "No data available.",
            "recommendation": "• Try another OBD II code.",
            "source": "N/A",
            "ai_last_updated": None
        }), 404

    description = row["description"]
    summary = row["summary"] or summarize_text(description)
    diy_checks = (row["diy_checks"] or "").strip()
    ai_last_updated = row["ai_last_updated"]

    placeholder_values = ("", "n/a", "none", "diy tips")
    needs_ai = (
        not diy_checks
        or diy_checks.lower() in placeholder_values
        or not ai_last_updated
        or datetime.utcnow() - datetime.fromisoformat(ai_last_updated) > timedelta(days=REFRESH_DAYS)
    )

    if needs_ai:
        print(f"⚙️ Generating recommendations for {code}...")
        diy_output = ai_select_from_fallback(description)
        ai_last_updated = datetime.utcnow().isoformat()
        cur.execute("UPDATE obd_codes SET diy_checks=?, ai_last_updated=? WHERE code=?", (diy_output, ai_last_updated, code))
        conn.commit()
    else:
        diy_output = diy_checks if CONFIDENCE_NOTE in diy_checks else diy_checks + CONFIDENCE_NOTE

    conn.close()
    return jsonify({
        "code": row["code"],
        "summary": summary,
        "description": description,
        "recommendation": diy_output.strip(),
        "source": row["source"] or "OBD-Codes.com",
        "ai_last_updated": ai_last_updated or datetime.utcnow().isoformat()
    })

@app.errorhandler(Exception)
def handle_exception(e):
    import traceback
    print("❌ Unhandled Exception:", e)
    traceback.print_exc()
    return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    ensure_columns()
    app.run(host="0.0.0.0", port=8888, debug=True)
