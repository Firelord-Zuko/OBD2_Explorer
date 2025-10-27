# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: clean_database.py
# Description: Cleans and normalizes OBD-II error code descriptions
#              by flattening nested JSON data, trimming verbose text,
#              and updating records in the local SQLite database.
# ===============================================================

import sqlite3
import json
import ast
import re

DB_FILE = "obd2_codes.db"

def summarize_diy(text):
    """Return only the first two sentences from the DIY Checks text."""
    if not text:
        return ""
    clean = re.sub(r"\s+", " ", text.strip())
    sentences = re.split(r"(?<=[.!?])\s+", clean)
    return " ".join(sentences[:2]).strip()


def parse_nested_json(s):
    """Handle JSON, dicts, or double-encoded JSON."""
    if not s:
        return None
    text = s.strip()

    # Step 1: try to decode JSON directly
    try:
        data = json.loads(text)
        # Some rows are JSON strings containing another JSON object
        if isinstance(data, str) and (data.strip().startswith("{") or data.strip().startswith("[")):
            data = json.loads(data)
        return data
    except Exception:
        pass

    # Step 2: try Python literal dict
    try:
        data = ast.literal_eval(text)
        if isinstance(data, str) and (data.strip().startswith("{") or data.strip().startswith("[")):
            data = ast.literal_eval(data)
        return data
    except Exception:
        return None


def flatten_description(desc_str):
    """Convert JSON or dict-like strings into readable text with trimmed DIY Checks."""
    data = parse_nested_json(desc_str)
    if not isinstance(data, dict):
        return desc_str

    output_parts = []
    if "Meaning" in data:
        output_parts.append(data["Meaning"])

    for key, val in data.items():
        if key == "DIY Checks":
            val = summarize_diy(val)
        if key != "Meaning":
            clean_val = re.sub(r"\s+", " ", str(val).strip())
            output_parts.append(f"{key}: {clean_val}")

    return "\n\n".join(output_parts).strip()


def clean_database():
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()
    cur.execute("SELECT code, description FROM obd_codes")
    rows = cur.fetchall()
    total = len(rows)
    updated = 0

    for code, desc in rows:
        new_desc = flatten_description(desc)
        if new_desc and new_desc != desc:
            cur.execute("UPDATE obd_codes SET description = ? WHERE code = ?", (new_desc, code))
            updated += 1

    conn.commit()
    conn.close()
    print(f"Cleaned {updated} of {total} records successfully.")


if __name__ == "__main__":
    clean_database()
