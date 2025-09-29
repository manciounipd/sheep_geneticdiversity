pwd

cd data_modfiy

#mkdir admx
cd admx

prg="../../program/dist/admixture_linux-1.3.0/admixture"
cp ../gooddb/wrd* .
ln -f $prg .

plink --bfile wrd --allow-extra-chr --chr-set 26  #--indep-pairwise 50 10 0.1
plink --bfile wrd --allow-extra-chr --chr-set 26 --chr 1-26  \
     --extract plink.prune.in --make-bed --maf 0.05 --mind 0.1 --geno 0.1 --out prunedDat

nohup bash -c 'for K in $(seq 2 50); do ./admixture --cv wrd.bed $K | tee log${K}.out; done' > admixture.log 2>&1 &


#mkdir eu_breed
cd eu_breed

cp ../../gooddb/eu_brd.txt .

plink --allow-extra-chr --chr-set 26 --keep-fam  eu_brd.txt --chr 1-26  --bfile ../../wrd --mind 0.1 --geno 0.1 --recode 12 --out eu_admx
plink --file eu_admx --allow-extra-chr --chr-set 26  #--indep-pairwise 50 10 0.1
plink --file eu_admx --allow-extra-chr --chr-set 26 --chr 1-26  \
     --extract plink.prune.in --make-bed --mind 0.1 --geno 0.1 --out eu_NoprunedDat

prg="../../../program/dist/admixture_linux-1.3.0/admixture"
cp $prg .
nohup bash -c 'for K in $(seq 2 50); do ./admixture --cv eu_NoprunedDat.bed  $K | tee log${K}.out; done' > admixture.log 2>&1 &



mkdir vnt_breed
cd vnt_breed

cp ../../gooddb/eu_brd.txt .

plink --allow-extra-chr --chr-set 26  --chr 1-26  --bfile ../../vnt --mind 0.1 --geno 0.1 --recode 12 --out vnt_admx
plink --allow-extra-chr --chr-set 26  --chr 1-26  --bfile ../../vnt --mind 0.1 --geno 0.1 --make-bed  --out vnt_admx
plink --file eu_admx --allow-extra-chr --chr-set 26  #--indep-pairwise 50 10 0.1
plink --file eu_admx --allow-extra-chr --chr-set 26 --chr 1-26  \

     --make-bed --mind 0.1 --geno 0.1 --out eu_NoprunedDat

prg="../../../program/dist/admixture_linux-1.3.0/admixture"
cp $prg .
nohup bash -c 'for K in $(seq 2 50); do ./admixture --cv  vnt_admx.bed  $K | tee log${K}.out; done' > admixture.log 2>&1 &