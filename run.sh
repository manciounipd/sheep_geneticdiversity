#!/bin/bash

path="/media/enrico/Seagate Basic/ongoing/articolo_elena/analisi"
cd "$path"

cd data_modfiy



# converti ped and map
process_files() {
    file_ped1="$1"  # First input argument (PED file)
    file_map1="$2"  # Second input argument (MAP file)
    out="$3"
    echo "$out"
    # convert in pedmap format
    python3 ../script/pedda_row2.py "$file_ped1" "$file_map1"
    python3 ../script/convert_map.py "$file_map1" "prova.map"
    # check and make order file
    plink2 --ped breed_output.ped --map prova.map --make-pgen --sort-vars --out file1
    plink2 --pfile file1 --make-bed --out $out

    # Cleanup unnecessary files
    rm prova.map *.ped *.map *pgen *pvar *log *psam 
    #file1-temporary.bed.smaj file1-temporary.fam.tmp
}

map1="round2v1_merged_round2v2"
map2="round1"

clena_and_merge() {
   echo "input bed output bed "
    # Input arguments
    map1=$1
    map2=$2 
    # Step 1: Run the R script for each dataset
    Rscript ../script/rmdpl.R $map1
    Rscript ../script/rmdpl.R $map2 
    # Step 2: Process map1 with Plink
    plink --allow-extra-chr --chr-set 26  --bfile $map1 --exclude ${map1}_dpl --recode --out a 
    # Step 3: Process map2 with Plink
    plink --allow-extra-chr --chr-set 26  --bfile $map2 --exclude ${map2}_dpl --recode --out b
    # Step 4: Compare maps using the R script by snpnames
    awk '{print $2}' a.map |sort > a.tmp
    awk '{print $2}' b.map |sort > b.tmp
    join -1 1 -2 1 a.tmp b.tmp > keep_snp.txt  # Step 5: Extract common SNPs from the comparison
    # Step 6: Extract common SNPs for both maps using Plink
    # nb se metto recode 12 non mi fa errori ni vari allelei vorrei capire il perche pero
    plink --allow-extra-chr --chr-set 26  --file a --extract keep_snp.txt --recode 12 --out a
    plink --allow-extra-chr --chr-set 26  --file  b --extract keep_snp.txt --recode 12  --out b 
    rm *.tmp
    # Step 7: Create a list of the files to merge
    printf "a.ped a.map\nb.ped a.map" > m.txt #faccio sto trick cosi ho la mappa aggionrate
    # Step 8: Merge the files using Plink
    plink --allow-extra-chr --chr-set 26  --merge-list m.txt    \
                     --make-bed -out $map1"_merged_"$map2 
    # 
    # Step 9: Clean up intermediate files (a, b, m.txt, and any other temporary files)
    rm a.* b.* m.txt keep_snp.txt
    #rm ab.bim ab.fam ab.nosex ab.psam ab.pvar
}


renme_plk(){
    look=$1
    new_prefix=$2
    for file in ${look}*; do
        extension="${file##*.}"
        echo $file "=>" ${new_prefix}.${extension}
        mv $file  ${new_prefix}.${extension}
    done
}


copy_and_convert() {
    dir="$1"
    nome="$2"
    # Copy required files
    cp ../data_grezzi/"$dir"/test_outputfile.ped .
    cp ../data_grezzi/"$dir"/SNP_Map.txt .
    # Convert SNP Map
    python3 ../script/convert_map.py SNP_Map.txt test_outputfile.map
    rm SNP_Map.txt
    renme_plk test_outputfile $nome
    plink --allow-extra-chr --chr-set 26 --file "$nome" --make-bed --out "$nome"
}


source myenv/bin/activate
pip install pandas


copy_and_convert invio1/Univ_of_Padova_Cecchinato_OVNG50V01_20200706  round1
copy_and_convert invio2/Univ_of_Padova_Ayr_OVNG50V02_20220822  round2v1
copy_and_convert invio2/Univ_of_Padova_Ayr_OVNG50V02_20220829  round2v2

clena_and_merge "round2v1" "round2v2" # merge file 1 and file 2
clena_and_merge "round2v1_merged_round2v2" "round1"

# rinomina in plink
renme_plk "round2v1_merged_round2v2_merged_round1" vnt

# update_breed 
python3 ../script/update_breed.py   vnt.fam ../data_grezzi/metadati/id_breed.txt 
mv vnt.famupdt vnt.fam
plink --bfile vnt --allow-extra-chr --chr-set 26  --recode --out vnt
# copi database in good foler

plink --allow-extra-chr --chr-set 26  --bfile a --extract keep_snp.txt --recode 12 --out a

dir_sheep1="../data_grezzi/sheepmap/SNP50_Breedv1/SNP50_Breedv1"
dir_sheep2="../data_grezzi/sheepmap/SNP50_Breedv2/SNP50_Breedv2"

wc -l $dir_sheep1".ped"
wc -l $dir_sheep1".map"

plink --allow-extra-chr --chr-set 26 no-xy no-mt  \
 --file "$dir_sheep1" --make-bed --out sheep1

plink --allow-extra-chr --chr-set 26 no-xy no-mt  \
 --file "$dir_sheep2" --make-bed --out sheep2


clena_and_merge  "vnt" "sheep1"
clena_and_merge  "vnt_merged_sheep1" "sheep2"

renme_plk vnt_merged_sheep1_merged_sheep2 wrd

# copia in delle cartelle
mkdir gooddb

cp wrd* gooddb/
cp vnt* gooddb/

# Fai le varie analisi
# run_go.sh
