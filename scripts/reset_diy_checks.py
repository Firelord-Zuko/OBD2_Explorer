# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: reset_diy_checks.py
# Description: Resets all 'diy_checks' fields in the OBD-II database
#              to a default placeholder value ("DIY Tips"). Safely
#              connects to the database under the /data directory.
# ===============================================================

import sqlite3
import os

# Navigate one directory up from the script folder
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "data", "obd2_codes.db")

print(f"🔍 Looking for database at: {DB_PATH}")

if not os.path.exists(DB_PATH):
    print(f"❌ Database not found at {DB_PATH}")
else:
    try:
        conn = sqlite3.connect(DB_PATH)
        cur = conn.cursor()
        cur.execute("UPDATE obd_codes SET diy_checks = 'DIY Tips';")
        conn.commit()
        conn.close()
        print("✅ All diy_checks have been reset to 'DIY Tips'.")
    except Exception as e:
        print(f"⚠️ Error updating database: {e}")
