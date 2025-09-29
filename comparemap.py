import pandas as pd
import sys

def compare_map_files(map1, map2, output_file="common_snps.txt", diff_file="snp_diff_report.txt"):
    # Load the map files (tab-separated)
    map1_df = pd.read_csv(map1, sep="\t", header=None)
    map2_df = pd.read_csv(map2, sep="\t", header=None)

    # Define the columns to match the standard BIM structure
    map1_df.columns = ["CHR1", "SNP", "CM", "POS", "A1", "A2"]
    map2_df.columns = ["CHR2", "SNP", "CM", "POS", "A1", "A2"]

    # Merge the two maps on the SNP column to get common SNPs
    common_snps = pd.merge(map1_df, map2_df, on="SNP", how="inner", suffixes=("_map1", "_map2"))

    # Debug: print the column names of the merged dataframe
    print("Merged dataframe columns:", common_snps.columns)

    # Write common SNPs to output file (SNP, position, chromosome)
    common_snps[["SNP", "CHR1", "POS_map1", "CHR2", "POS_map2"]].to_csv(output_file, sep="\t", index=False, header=True)

    # Find SNPs with different positions and/or chromosomes
    diff_snps = common_snps[(common_snps["CHR1"] != common_snps["CHR2"]) | (common_snps["POS_map1"] != common_snps["POS_map2"])]

    # Write differences report
    diff_snps[["SNP", "CHR1", "POS_map1", "CHR2", "POS_map2"]].to_csv(diff_file, sep="\t", index=False, header=True)

    print(f"Common SNPs written to: {output_file}")
    print(f"Difference report written to: {diff_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python compare_map.py <map1.bim> <map2.bim>")
        sys.exit(1)

    map1 = sys.argv[1]  # First map file passed from the terminal
    map2 = sys.argv[2]  # Second map file passed from the terminal

    compare_map_files(map1, map2)
