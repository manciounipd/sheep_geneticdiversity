cd ~/articolo_elena/analisi/data_modfiy

mkdir SNep; cd SNep
cp ../../program/SNeP1.1 .
chmod 775 SNeP1.1

breed=$(awk  '{print $1}' ../vnt.fam | sort | uniq)
for i in $breed; do
        echo $i
        echo "$i" > brd_l.txt
        plink --allow-extra-chr --chr-set 26 --chr 1-26 --keep-fam  brd_l.txt \
                --bfile ../vnt --chr 1-26 \
                --mind 0.1 --geno 0.1 --recode 12 --out $i"_cln"
       ulimit -s unlimited ; ./SNeP1.1 -ped  $i"_cln.ped" | tee  log_$i
done





R
db=system("ls *NeAll",intern=TRUE)

fx=function(i){
        cat(i,"\n")
        nome=gsub(".NeAll","",db[i])
        nome=gsub("_cln","",nome)
        dbx=data.frame(data.table::fread(db[i]))
        dbx$Breed=nome
        return(dbx)
}

getwd()

db2=do.call("rbind",lapply(1:4,fx))
require(ggplot2)

png("../gooddb/plot/SNeP.png")
ggplot(db2[db2$GenAgo<100,],aes(x=GenAgo,y=Ne,color=Breed))+
geom_line()
dev.off()


