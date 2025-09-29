import os
import pandas as pd

# Specify th
# Identify files in the folder
final_report_file = None
snp_map_file = None

for file in os.listdir("."):
    if "finalreport" in file.lower():
        final_report_file = os.path.join(".", file)
    elif "snpmap" in file.lower():
        snp_map_file = os.path.join(".", file)

# Ensure both files are found
if not final_report_file or not snp_map_file:
    raise FileNotFoundError("Could not find FinalReport or SnpMap files in the folder.")

# Function to detect delimiter
def detect_delimiter(file_path):
    with open(file_path, "r") as f:
        first_line = f.readline()
        if "," in first_line:
            return ","
        elif "\t" in first_line:
            return "\t"
        else:
            return " "  # Assume space if no comma or tab

# Detect separator
separator = detect_delimiter(final_report_file)

# Read the first few lines to identify SNP ID and Individual ID positions
df = pd.read_csv(final_report_file, sep=separator, nrows=5)

# Identify SNP ID and Individual ID columns automatically
snp_id_col = None
ind_id_col = None

for i, col in enumerate(df.columns):
    if "snp" in col.lower():
        snp_id_col = i + 1  # Convert to 1-based index
    if "id" in col.lower() or "sample" in col.lower():
        ind_id_col = i + 1  # Convert to 1-based index

# Ensure we found both columns
if snp_id_col is None or ind_id_col is None:
    raise ValueError("Could not automatically detect SNP ID or Individual ID columns.")

# Define output parameters
config_content = f"""### Final report in ROW format (for matrix format, there is another software!)
finrep='{final_report_file}' 

### SNP map (original from Illumina)
snpmap='{snp_map_file}'      

### Often there are multiple allele codings in the row format files, chose the one you wish on your PED file
### Options allowed: 'top', 'forward','ab'.
allele='top'                                

### Position of the SNP ID in the file (usually is the first field, but may change)                                            
SNPid_pos='{snp_id_col}'                               

### Position of the INDIVIDUAL ID in the file (usually is the second field)
INDid_pos='{ind_id_col}'                               

### Name of output PED and MAP files
outname='test_outputfile'                   

### This will be used on the "Fid" column (first column in the PED)
brdcode='TEST'                              

# Options: ',' (for CSV) / ' ' (for TXT) / '\\t' (for TSV)
sep={repr(separator)}       
"""

# Write to file
with open("config.txt", "w") as f:
    f.write(config_content)

print("Configuration file 'config.txt' generated successfully!")
