# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: lookup_code.py
# Description: Provides a simple CLI tool to query the local
#              OBD-II SQLite database for a given diagnostic code.
#              Validates database existence and schema before lookup.
# ===============================================================

import sqlite3
import os

DB_FILE = "obd2_codes.db"

def lookup_code(code):
    """Query the SQLite database for a given OBD-II code."""
    if not os.path.exists(DB_FILE):
        print(f"Error: Database file '{DB_FILE}' not found.")
        return None

    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    # Quick test to ensure the table exists
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='obd_codes';")
    if not cursor.fetchone():
        print("Error: Table 'obd_codes' not found in the database.")
        conn.close()
        return None

    # Perform lookup
    cursor.execute("SELECT code, description FROM obd_codes WHERE code = ?", (code,))
    result = cursor.fetchone()
    conn.close()
    return result


if __name__ == "__main__":
    print("=== OBD-II Code Lookup Test ===")
    sample_code = input("Enter an OBD-II code (e.g., P0301): ").strip().upper()

    if not sample_code:
        print("Please enter a valid code.")
        exit()

    record = lookup_code(sample_code)

    if record:
        print("\n--- Code Details ---")
        print(f"Code: {record[0]}")
        print(f"Description: {record[1]}")
    else:
        print(f"\nNo record found for code {sample_code}.")
