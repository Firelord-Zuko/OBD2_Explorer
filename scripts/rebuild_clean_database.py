# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: rebuild_clean_database.py
# Description: Rebuilds the OBD-II SQLite database from the original
#              JSON source, keeping concise descriptions and summaries.
#              Uses the local Phi-2 model for summarization of
#              "Common Causes" and trims "DIY Checks" text.
# ===============================================================

"""
rebuild_clean_database.py
-------------------------
Rebuilds the OBD-II SQLite database from the original JSON file.

- Reads obd_codes.json
- Keeps the 'Meaning'
- Uses local Phi-2 model to summarize 'Common Causes' to 2–3 concise items
- Keeps only the first 2 sentences of 'DIY Checks'
"""

import json
import sqlite3
import re
from llama_cpp import Llama
import os

# === File paths ===
JSON_FILE = "obd_codes.json"
DB_FILE = "obd2_codes.db"
MODEL_PATH = os.path.join(os.path.dirname(__file__), "models", "phi-2.Q4_K_M.gguf")

# === Load the local model once ===
print("Loading local Phi-2 model (this may take a few seconds)...")
llm = Llama(model_path=MODEL_PATH, n_ctx=1024, n_threads=6, use_mlock=True)


# ---------------------------------------------------------------------
def summarize_diy(text: str) -> str:
    """Return only the first two sentences from the DIY Checks text."""
    if not text:
        return ""
    clean = re.sub(r"\s+", " ", text.strip())
    sentences = re.split(r"(?<=[.!?])\s+", clean)
    return " ".join(sentences[:2]).strip()


def trim_common_causes(text: str) -> str:
    """Use the LLM to shorten a long 'Common Causes' paragraph."""
    if not text or len(text.split()) < 20:
        return text

    prompt = f"""
You are a professional automotive technician.
Given this long list of common causes for an OBD-II code,
return ONLY the two or three most typical causes in concise phrases,
comma-separated, no numbering.

Common Causes text:
{text}
"""
    try:
        result = llm(prompt, max_tokens=80, temperature=0.4)
        summary = result["choices"][0]["text"].strip()
        summary = re.sub(r"^[0-9\.\-\)\s]+", "", summary)
        summary = summary.replace("\n", " ").strip()
        return summary
    except Exception as e:
        print(f"LLM summarization failed: {e}")
        return text


# ---------------------------------------------------------------------
def build_database():
    # Load JSON
    print(f"Loading data from {JSON_FILE} ...")
    with open(JSON_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Connect / recreate DB
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()
    cur.execute("DROP TABLE IF EXISTS obd_codes")
    cur.execute("""
        CREATE TABLE obd_codes (
            code TEXT PRIMARY KEY,
            description TEXT
        )
    """)

    count = 0
    for code, details in data.items():
        meaning = details.get("Meaning", "").strip()
        causes = details.get("Common Causes", "").strip()
        diy = details.get("DIY Checks", "").strip()

        short_causes = trim_common_causes(causes)
        diy_short = summarize_diy(diy)

        description = f"{meaning}\n\nCommon Causes: {short_causes}\n\nDIY Checks: {diy_short}".strip()
        cur.execute("INSERT INTO obd_codes (code, description) VALUES (?, ?)", (code, description))
        count += 1

    conn.commit()
    conn.close()
    print(f"Rebuilt {count} clean records successfully into {DB_FILE}.")


# ---------------------------------------------------------------------
if __name__ == "__main__":
    build_database()
