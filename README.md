# Genetic diversity Analisys

## FIRST STEP 
## Genotype processing & merging pipeline
Script `runs.sh`
## Overview
This pipeline converts raw PED/MAP genotype files into PLINK binary format, cleans and harmonizes SNP sets across multiple rounds/datasets, merges them into a single reference panel, updates sample metadata (breed IDs) and copies the final cleaned database to `gooddb/` for downstream analyses.

> The script lives in `data_modfiy/` and calls helper Python and R scripts from `../script/` as well as PLINK/PLINK2.

---

## Requirements
- GNU/Linux (tested on Ubuntu)
- `bash` (script is a bash script)
- `python3` (with `pandas`)
- `Rscript` (for `rmdpl.R`)
- `plink` and `plink2` available in `PATH` (versions that support `--allow-extra-chr` and `--chr-set`)
- Helper scripts present in `../script/`:
  - `pedda_row2.py`
  - `convert_map.py`
  - `rmdpl.R`
  - `update_breed.py`
- Raw data in `../data_grezzi/` (structure expected by the script)

Quick setup example:
```bash
cd data_modfiy
python3 -m venv myenv
source myenv/bin/activate
pip install pandas
```

---

## Inputs (expected files / locations)
- Raw genotype folders under `../data_grezzi/` (e.g. `invio1/...`, `invio2/...`) containing:
  - `test_outputfile.ped` (or other PED-like file expected by `copy_and_convert`)
  - `SNP_Map.txt` (map file used by `convert_map.py`)
- Prebuilt sheep maps used later: `../data_grezzi/sheepmap/SNP50_Breedv1/SNP50_Breedv1` and `...Breedv2/...`
- `../data_grezzi/metadati/id_breed.txt` for updating breed IDs

---

## Outputs
- Intermediate PLINK binary files for each dataset (e.g. `round1.*`, `round2v1.*`, `round2v2.*`)
- Merged PLINK files: e.g. `round2v1_merged_round2v2_merged_round1.*` (renamed later to `vnt.*`, then merged with `sheep` to `wrd.*`)
- Final database files copied into `gooddb/` (prefix `wrd*` and `vnt*`)
- Temporary files and logs are removed during the run; check script for what is deleted.

---

## Quick start (one-liner)
Save the pipeline as `run_pipeline.sh` inside `data_modfiy/`, make it executable and run it:
```bash
cd data_modfiy
chmod +x run_pipeline.sh
./run_pipeline.sh
```

(If you prefer, run step-by-step as described below.)

---

## Detailed step-by-step description (what each block does)

### 1) Environment & prerequisites
- Activate Python virtualenv and install `pandas` (script already contains `source myenv/bin/activate` and `pip install pandas`).

### 2) `copy_and_convert(dir, nome)` — convert raw PED/MAP to plink bed
- Purpose: copy raw files from `../data_grezzi/<dir>/`, convert SNP map to PLINK `.map` format, rename intermediate PLINK files and create binary files with `plink --make-bed`.
- Commands executed (inside function):
  ```bash
  cp ../data_grezzi/<dir>/test_outputfile.ped .
  cp ../data_grezzi/<dir>/SNP_Map.txt .
  python3 ../script/convert_map.py SNP_Map.txt test_outputfile.map
  rm SNP_Map.txt
  renme_plk test_outputfile <nome>
  plink --allow-extra-chr --chr-set 26 --file <nome> --make-bed --out <nome>
  ```
- Output: `<nome>.bed/.bim/.fam`

### 3) `process_files(file_ped1, file_map1, out)` — (not used by main flow) convert ped/map using helper scripts
- Runs `pedda_row2.py` and `convert_map.py`, then `plink2 --ped ... --map ... --make-pgen` and `plink2 --pfile file1 --make-bed --out $out`, then cleans temporary files.

### 4) `clena_and_merge(map1, map2)` (note: function name has a typo; intended: `clean_and_merge`)
- Purpose: clean each dataset (remove duplicated/problem SNPs via the R script `rmdpl.R`), find common SNPs between two datasets, restrict both datasets to the common SNP set and merge them into a single PLINK binary.
- Steps inside the function:
  1. Run `Rscript ../script/rmdpl.R $map1` and same for `$map2` — this script should create `${map}_dpl` lists of SNPs to exclude.
  2. Convert `bfile` to `--recode` text form (`a` and `b`) while excluding `${map}_dpl` lists.
  3. Extract SNP IDs (column 2 of `.map`) from `a.map` and `b.map`, sort and join to get `keep_snp.txt` (common SNPs).
  4. Run `plink --extract keep_snp.txt --recode 12` to ensure consistent allele coding across datasets.
  5. Create `m.txt` containing lines `a.ped a.map` and `b.ped a.map` (this trick uses the updated map) and run `plink --merge-list m.txt --make-bed -out ${map1}_merged_${map2}`.
  6. Clean up temporary files.
- Output: `${map1}_merged_${map2}.*`

**Important notes:**
- The script uses `--recode 12` in some steps to avoid allele recoding errors; if you see errors during merge, inspect the `.log` and `.missnp` files PLINK produces and consider harmonizing strand or allele coding.
- `--allow-extra-chr --chr-set 26` are used to allow non-standard chromosome numbering (adjust if you have different chromosome sets).

### 5) `renme_plk(look, new_prefix)` — rename PLINK-related files
- Simple renaming helper that moves `look.*` to `new_prefix.*` for all file extensions present.

### 6) Updating breed metadata
- After merging and renaming to prefix `vnt`, the pipeline calls:
  ```bash
  python3 ../script/update_breed.py vnt.fam ../data_grezzi/metadati/id_breed.txt
  mv vnt.famupdt vnt.fam
  plink --bfile vnt --allow-extra-chr --chr-set 26 --recode --out vnt
  ```
- This updates the `.fam` with correct breed/sample metadata used downstream.

### 7) Merge with sheep maps and final merging
- The script builds PLINK binary files for `sheep1` and `sheep2` from existing `dir_sheep1` and `dir_sheep2` and merges them with the `vnt` dataset using `clena_and_merge`.
- Final merged prefix is renamed (e.g. `wrd`) and files copied to `gooddb/`.

### 8) Final copy
- The cleaned merged files are copied into `gooddb/` for later use:
  ```bash
  mkdir -p gooddb
  cp wrd* gooddb/
  cp vnt* gooddb/
  ```

---

## Typical issues & troubleshooting
- **`command not found: plink` or `plink2`**: ensure PLINK binaries are in your `PATH` or call with full path.
- **Missing helper scripts (`../script/*.py`, `rmdpl.R`)**: make sure these files exist and are executable.
- **Merge errors (allele mismatches)**: inspect PLINK `.log` and `.missnp` files. Use `--recode 12` to harmonize allele coding or preprocess strand flips if needed.
- **`keep_snp.txt` empty or too small**: check that the `.map` extraction succeeded and the datasets truly share SNP IDs (consistent naming required).
- **Files removed unexpectedly**: the script runs `rm` on various temporary files; if you want to keep them for debugging, comment out the `rm` lines.
- **Typos in function names**: the script contains typos like `clena_and_merge` and `renme_plk`. You may want to rename them to `clean_and_merge` and `rename_plk` respectively for readability.

---

## What to change for your dataset
- Edit the `copy_and_convert` calls to point to the raw folders you have under `../data_grezzi/`.
- Confirm the `map1`/`map2` variables and the `clena_and_merge` calls match the actual prefixes created earlier.
- Adjust `--chr-set` if your species/chromosome numbering differs.

---

## Example invocation sequence (as in the script)
```bash
# convert three raw inputs into PLINK files
copy_and_convert invio1/Univ_of_Padova_Cecchinato_OVNG50V01_20200706  round1
copy_and_convert invio2/Univ_of_Padova_Ayr_OVNG50V02_20220822  round2v1
copy_and_convert invio2/Univ_of_Padova_Ayr_OVNG50V02_20220829  round2v2

# merge the two round2 files first, then merge with round1
clena_and_merge "round2v1" "round2v2"
clena_and_merge "round2v1_merged_round2v2" "round1"

renme_plk "round2v1_merged_round2v2_merged_round1" vnt

# update breed metadata and merge with sheep maps
python3 ../script/update_breed.py vnt.fam ../data_grezzi/metadati/id_breed.txt
mv vnt.famupdt vnt.fam
plink --bfile vnt --allow-extra-chr --chr-set 26 --recode --out vnt

# final merges with sheep maps and copy
clena_and_merge  "vnt" "sheep1"
clena_and_merge  "vnt_merged_sheep1" "sheep2"
renme_plk vnt_merged_sheep1_merged_sheep2 wrd
mkdir -p gooddb
cp wrd* gooddb/
cp vnt* gooddb/
```



Tell me which one and I’ll update the document.

