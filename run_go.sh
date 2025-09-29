
rm vnt*

cd program/gone_55$
cp ../../data_modfiy/gooddb/vnt.* .

breed=$(awk  '{print $1}' vnt.fam | sort | uniq)
for i in $breed; do
        echo $i
        echo "$i" > brd_l.txt
        plink --allow-extra-chr --chr-set 26  --keep-fam  brd_l.txt \
                --bfile vnt --chr 1-26 \
                --mind 0.1 --geno 0.1 --recode 12 --out $i"_cln"
        ./script_GONE.sh $i"_cln" > log_$i
done

###################

rm vnt_cln*
