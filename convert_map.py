import argparse
import csv

# Function to convert the input SNP map file into PLINK .map format
def convert_to_map(input_file, output_file):
    # Open the input file for reading
    with open(input_file, 'r') as infile:
        # Assume the file is tab-delimited
        reader = csv.DictReader(infile, delimiter='\t')  # Adjust delimiter if necessary
        
        # Open the output file for writing the PLINK .map format
        with open(output_file, 'w') as outfile:
            for row in reader:
                # Extract the necessary fields: Chromosome, SNP Name (or ID), and Position
                chromosome = row['Chromosome']
                snp_id = row['Name']
                position = row['Position']
                
                # Write the data in PLINK .map format (chromosome, SNP ID, 0, position)
                outfile.write(f"{chromosome}\t{snp_id}\t0\t{position}\n")

    print(f"Conversion complete! Output saved in {output_file}")

# Set up argument parser to handle input and output file paths
def main():
    parser = argparse.ArgumentParser(description="Convert SNP Map to PLINK .map format")
    
    # Add arguments for input and output files
    parser.add_argument('input_file', help="Path to the input SNP Map file")
    parser.add_argument('output_file', help="Path to save the output .map file")
    
    # Parse arguments
    args = parser.parse_args()

    # Call the conversion function
    convert_to_map(args.input_file, args.output_file)

# Run the script
if __name__ == '__main__':
    main()
