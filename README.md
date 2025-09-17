# China Scientific Leadership
Code and reproducible workflows for the PNAS paper “Shifting Power Asymmetries in Scientific Teams Reveal China’s Rising Leadership in Global Science.” (Sep 2025)

**Authors:** Renli Wu, Christopher Esposito, James A. Evans  
**Affiliations:** School of Information Management, Wuhan University / Knowledge Lab, University of Chicago / University of California, Los Angeles  
**Version:** v0.3.0
**Last Updated:** 2025-09-19 (UTC)

---

## Overview
This repository provides code and notebooks to reproduce figures and supplementary analyses for a study of **China–US scientific leadership and parity**. We quantify leadership through author-level roles and related indicators, and examine temporal and field-level patterns as well as budgetary and international student contexts.

The workflow is notebook-centric for transparency and replicability. Each notebook contains a structured header describing **Purpose, Inputs, Outputs**, and **Notes**. A lightweight driver script (`run_all.py`) can execute a selected subset of notebooks in sequence.

---

## Data Sources

1. **OpenAlex leadership dataset**  
   - `data/OpenAlex2023_Paper_Author_Lead_Pro_dataset.csv.gz`  
   - Preprocessed author–paper roles used to compute “Lead Share” and “Lead Premium”.

2. **Chinese Ministry of Education (MOE) departmental budgets**  
   - `data/China_Budget_for_International_Students.csv.gz`  
   - Annual budget allocations for international students.

3. **International student statistics for China (2006–2018)**  
   - `data/China_international_student_statistics_by_regions.csv`  
   - Concise time series by region.

> **Note:** Due to the large size of the raw data files, they are not tracked in Git.  
> All datasets can be downloaded from [Zenodo](https://zenodo.org/records/17138189) and should be placed under the `data/` directory using the exact filenames specified above.


---

## Repository Structure

```

.
├── Fig1\_ab\_China\_Scientific\_Leadership.ipynb
├── Fig1\_cd\_Fig4c\_China\_parity\_trend.ipynb
├── Fig2\_a\_China\_US\_Parity\_by\_JIF\_threshold.ipynb
├── Fig2\_b\_China\_US\_Parity\_by\_Lead\_Pro\_threshold.ipynb
├── Fig3\_China\_US\_parity\_in\_11\_critical\_TAs.ipynb
├── Fig4a\_China\_International\_Student\_Budget.ipynb
├── Fig4b\_China\_International\_Students\_Statistics\_by\_Regions.ipynb
├── FigS1\_OpenAlex2023\_Publication\_Statistics\_by\_Region\_Pair.ipynb
├── FigS22\_China\_US\_parity\_in\_6\_broad\_fields.ipynb
├── run\_all.py
├── data/              # place input datasets here (not versioned)
└── pics/              # figure outputs and executed notebooks (*.svg, executed\_*.ipynb)

````

---

## Figure Map (Notebook → Outputs)

| Notebook | Main Output(s) | Notes |
|---|---|---|
| `Fig1_ab_China_Scientific_Leadership.ipynb` | `pics/fig_1_a.png`, `pics/fig_1_b.png` | China–US leadership distributions. |
| `Fig1_cd_Fig4c_China_parity_trend.ipynb` | `pics/fig_1_cd.png`, `pics/fig_4_c.png` | Parity trends; also SI: S12, S15, S16, S17, S30. |
| `Fig2_a_China_US_Parity_by_JIF_threshold.ipynb` | `pics/fig_2_a_lead_share.svg`, `pics/fig_2_a_lead_premium.svg` | Lead Share (main), Lead Premium (SI S3a); also SI S31. |
| `Fig2_b_China_US_Parity_by_Lead_Pro_threshold.ipynb` | `pics/fig_2_b_lead_share.svg`, `pics/fig_2_b_lead_premium.svg` | Lead Share (main), Lead Premium (SI S3b); also SI S31. |
| `Fig3_China_US_parity_in_11_critical_TAs.ipynb` | `pics/fig_3_lead_share.svg`, `pics/fig_3_lead_premium.svg` | Main Fig. 3; Lead Premium in SI (S4); also SI S32. |
| `Fig4a_China_International_Student_Budget.ipynb` | `pics/fig_4a.svg` | MOE departmental budget series. |
| `Fig4b_China_International_Students_Statistics_by_Regions.ipynb` | `pics/fig_4_b.svg` | International students (2006–2018). |
| `FigS1_OpenAlex2023_Publication_Statistics_by_Region_Pair.ipynb` | `pics/fig_S1.svg`, `pics/fig_S1_extra.svg` | Regional publication statistics and variant view. |
| `FigS22_China_US_parity_in_6_broad_fields.ipynb` | `pics/fig_S22_lead_share.svg`, `pics/fig_S22_lead_premium.svg` | SI S22; also SI S21 (publication statistics by fields). |

> Filenames reflect the manuscript figure numbering. Supplementary items use `Fig. S#` and, where relevant, an `extra` variant rather than a/b subpanels.



## Environment & Installation

We recommend running the code in a clean Python environment (e.g., conda or venv).  

### Option A: `pip`
```bash
pip install papermill notebook pandas numpy matplotlib pyarrow
````

### Option B: `conda` (via conda-forge)

```bash
conda install -c conda-forge papermill notebook pandas numpy matplotlib pyarrow
```

### Verify installation

```bash
papermill --version
jupyter --version
```

### Tested environment

The repository has been tested with the following configuration:

* Python version: 3.11.5 (main, Sep 11 2023, 13:54:46) \[GCC 11.2.0]
* Platform: Linux-4.18.0-305.3.1.el8.x86\_64-x86\_64-with-glibc2.28
* papermill version: 2.6.0
* notebook version: 7.3.2
* pandas version: 2.2.3
* numpy version: 1.24.4
* matplotlib version: 3.7.5
* pyarrow version: 19.0.1


## Reproducibility & Execution

Each notebook can be run interactively in Jupyter **or** executed non-interactively via `papermill`.

### Run a Single Notebook (command line)

```bash
papermill Fig2_a_China_US_Parity_by_JIF_threshold.ipynb pics/executed_Fig2_a_China_US_Parity_by_JIF_threshold.ipynb
```

### Run a Selected Set (driver script)

`run_all.py` reads notebooks from the **current directory** and writes executed copies to `pics/` as `executed_*.ipynb`. Adjust the `notebooks` list in the script to control which files run and in what order.

```bash
python run_all.py
```

Executed notebooks preserve cell outputs (figures, logs) for auditability and debugging.

---

## File-Naming Conventions

* Main-text figures: `pics/fig_<number>_<panel>.svg` (e.g., `fig_2_b_lead_share.svg`).
* Supplementary figures: `pics/fig_S<number>.svg` and, when a single-figure variant is needed, `pics/fig_S<number>_extra.svg`.
* Executed notebooks: `pics/executed_<original>.ipynb`.

These conventions ensure one-to-one traceability between code, outputs, and manuscript references.

---

## Ethical Use & Data Availability

* Analyses use publicly available or institutionally published data (OpenAlex; MOE budgets; national statistics).
* Users are responsible for complying with the terms of use of each data source.
* This repository distributes **code only**; no proprietary or personal data are included.

---

## Citation
If you use this code or reproduce figures, please cite:
> Wu, R., Esposito, C., & Evans, J. A. (2025). *Shifting Power Asymmetries in Scientific Teams Reveal China’s Rising Leadership in Global Science* (code repository).  
> URL: [https://github.com/RenlyWu/china-scientific-leadership](https://github.com/RenlyWu/china-scientific-leadership)

A `CITATION.cff` file is recommended for formal citation metadata.

---

## Contact
For questions or collaboration inquiries, please contact:  

- **Renli Wu**: wurenli@whu.edu.cn or renly@uchicago.edu  
- **Christopher Esposito**: Christopher.Esposito@anderson.ucla.edu  
- **James Evans** (corresponding author): jevans@uchicago.edu  

Issues and pull requests are welcome.


