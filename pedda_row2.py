import sys
import os
import argparse

def bomb(message):
    print("ERROR: " + message)
    sys.exit()

def check_file(value, name):
    try:
        os.path.exists(value)
    except:
        bomb(f"File '{name}' not found")

def detect_separator(file_path):
    """
    Automatically detect the separator in the file based on the first line.
    Assumes common separators like comma, tab, or space.
    """
    with open(file_path, 'r') as f:
        first_line = f.readline().strip()

    # Try to detect separator by checking the number of columns
    possible_seps = [',', '\t', ' ']
    sep_count = {sep: first_line.count(sep) for sep in possible_seps}

    # Choose the separator with the highest count (assume the file uses it consistently)
    detected_sep = max(sep_count, key=sep_count.get)

    # If no clear separator was found, use default tab
    if sep_count[detected_sep] == 0:
        detected_sep = '\t'

    return detected_sep

def find_column_indices(header_line, sep):
    """
    Automatically find the required column indices based on the header.
    Looks for columns like 'SNP Name', 'Sample ID', 'Allele1', and 'Allele2'.
    """
    columns = header_line.strip().split(sep)
    
    # Automatically find the column positions based on the header names
    snp_column = next(i for i, col in enumerate(columns) if 'snp name' in col.lower())
    id_column = next(i for i, col in enumerate(columns) if 'sample id' in col.lower())
    allele1_column = next(i for i, col in enumerate(columns) if 'allele1' in col.lower())
    allele2_column = next(i for i, col in enumerate(columns) if 'allele2' in col.lower())

    return snp_column, id_column, allele1_column, allele2_column

def process_illumina_report(finrep, sep, brdcode):
    readfrom = False
    SNPname = []
    name = []
    geno = []
    anim = -1
    snp = 0
    snp_data = {}  # Dictionary to track SNP IDs and their corresponding samples
    outped = open(f"{brdcode}_output.ped", 'w')
    outmap = open(f"{brdcode}_output.map", 'w')

    for en, a in enumerate(open(finrep)):
        # Header of the Illumina row format (line below the [Data] line)
        if 'allele1' in a.lower():
            readfrom = True
            line = a.strip().split(sep)

            # Find column indices for SNP, Sample ID, and Alleles
            snp_column, id_column, allele1_column, allele2_column = find_column_indices(a, sep)

            continue

        if not readfrom:
            continue

        # Read SNP data from the report
        line = a.strip().split(sep)
        snp_name = line[snp_column]
        id_sample = line[id_column]
        alle1 = line[allele1_column]
        alle2 = line[allele2_column]

        if alle1 == '-': alle1 = '0'
        if alle2 == '-': alle2 = '0'

        if id_sample not in name:
            name.append(id_sample)
            geno = [f"{alle1} {alle2}"]
        else:
            geno.append(f"{alle1} {alle2}")
        
        snp += 1
        if snp_name not in SNPname:
            SNPname.append(snp_name)

        # Store SNP data in the dictionary to track unique SNPs for each sample
        if snp_name not in snp_data:
            snp_data[snp_name] = [id_sample]
        else:
            snp_data[snp_name].append(id_sample)

        #if snp % 100000 == 0:
            #print(f"Processing SNP {snp_name} for sample {id_sample}")

    # Check for consistent SNP IDs and animal IDs
    print("### Verifying sample and SNP consistency:")
    for snp_id, samples in snp_data.items():
        if len(set(samples)) != len(samples):  # Check if SNP is associated with unique samples
            bomb(f"SNP {snp_id} appears more than once for different animals. Check data.")

    print("====> SNP and Sample ID check: OK")

    # Write out the final PED file
    for individual in name:
        outped.write(f"{brdcode} {individual} 0 0 0 -9 {' '.join(geno)}\n")

    # Write out the MAP file
    for snp_name in SNPname:
        outmap.write(f"{snp_name} 0 0 0\n")

    outped.close()
    outmap.close()
    print(f"PED file saved as {brdcode}_output.ped")
    print(f"MAP file saved as {brdcode}_output.map")


def main():
    parser = argparse.ArgumentParser(description="Convert Illumina row format into PLINK PED and MAP formats.")
    parser.add_argument("finrep", help="Illumina Final Report file")
    parser.add_argument("snpmap", help="SNP map file")

    args = parser.parse_args()

    # Check for file existence
    check_file(args.finrep, 'finrep')
    check_file(args.snpmap, 'snpmap')

    # Automatically detect separator
    sep = detect_separator(args.finrep)
    print(f"Detected separator: '{sep}'")

    # Set breed code to "breed"
    brdcode = "breed"

    # Process the Illumina report
    process_illumina_report(args.finrep, sep, brdcode)

if __name__ == "__main__":
    main()
