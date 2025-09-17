#!/usr/bin/env python3
# ============================================================
# Project: China Scientific Leadership
# Script: run_all.py
# Authors: Renli Wu
# Date: 2025-09-09 (UTC)
# Version: v0.3.1
#
# Purpose:
# Execute selected analysis notebooks sequentially.
# Notebooks are read from the current directory, and executed
# versions are saved into the `pics/` folder. After each run,
# the current timestamp is printed.
# ============================================================

import os
import time
import papermill as pm

# --- List of notebooks to execute (adjust as needed) ---
notebooks = [
    "Fig1_ab_China_Scientific_Leadership.ipynb",
    "Fig1_cd_Fig4c_China_parity_trend.ipynb",
    "Fig2_a_China_US_Parity_by_JIF_threshold.ipynb",
    "Fig2_b_China_US_Parity_by_Lead_Pro_threshold.ipynb",
    "Fig3_China_US_parity_in_11_critical_TAs.ipynb",
    "Fig4a_China_International_Student_Budget.ipynb",
    "Fig4b_China_International_Students_Statistics_by_Regions.ipynb",
    # "FigS1_OpenAlex2023_Publication_Statistics_by_Region_Pair.ipynb",
    # "FigS22_China_US_parity_in_6_broad_fields.ipynb",
]

# --- Directory where executed notebooks will be stored ---
OUTPUT_DIR = "pics"
os.makedirs(OUTPUT_DIR, exist_ok=True)
print(time.strftime('%l:%M%p %Z on %b %d, %Y'), "Start -- ")

# --- Run each notebook ---
for nb in notebooks:
    input_path = nb
    output_path = os.path.join(OUTPUT_DIR, f"executed_{nb}")
    print(f"\n>>> Running {nb} ...")
    pm.execute_notebook(input_path, output_path)
    print(time.strftime(f"--- Finished {nb} at %H:%M:%S on %Y-%m-%d ---"))

print(time.strftime('%l:%M%p %Z on %b %d, %Y'), "\nAll selected notebooks executed successfully.")
