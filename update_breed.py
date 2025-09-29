import pandas as pd
import sys

def update_fam_with_breed(fam_file, breed_file):
    # Load the original .fam file
    fam_df = pd.read_csv(fam_file, delim_whitespace=True, header=None, names=["FID", "IID", "PID", "MID", "Sex", "Phenotype"])
    breed_df = pd.read_csv(breed_file, header=0,names=["Breed","IID"])
    
    fam_df['IID'] = fam_df['IID'].astype(str)  # Convert to string
    breed_df['IID'] = breed_df['IID'].astype(str)  # Convert to string
    # Merge the two DataFrames based on "IID" (individual ID)
    merged_df = pd.merge(fam_df, breed_df, on="IID", how="left")


    # Optionally, update the breed column or add it as a new one
    merged_df["Breed"] = merged_df["Breed"].fillna("Unknown")  # If there are missing breeds, replace with "Unknown"

    # Save the updated .fam file with breed information
    merged_df[["Breed", "IID", "PID", "MID", "Sex", "Phenotype"]].to_csv(fam_file+"updt", sep=" ", index=False, header=False)

    print(f"Updated .fam file saved as '{fam_file}'.")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python update_fam_with_breed.py <fam_file> <breed_file>")
        sys.exit(1)

    # Get input files from command line arguments
    fam_file = sys.argv[1]
    breed_file = sys.argv[2]
    
    # Call the function to update .fam file
    update_fam_with_breed(fam_file, breed_file)
