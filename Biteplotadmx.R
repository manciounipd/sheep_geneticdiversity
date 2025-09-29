if(FALSE) {
# install BITE V2 from source
#install.packages("devtools").
#BiocManager::install("SNPRelate")
#devtools::install_local("BITEV2_2.1.2.tar.gz")
}



require("BITEV2")


getwd()
dir.create("bite");setwd("bite")
getwd()


library(RCircos)
require(data.table)


system("cp  ../data_modfiy/admx/eu_breed/* .")


info1=data.table::fread("../data_grezzi/metadati/sheep_map_rf2.txt")
system("plink --allow-extra-chr --chr-set 26 --bfile eu_NoprunedDat --recode 12 --out eu_NoprunedDat")

fam=fread("eu_NoprunedDat.fam")
info1=info1[,c("Abbreviation","Breed/Species","CountryofOrigin","Continent")]
names(info1)[1:2]=c("Abbr","Breed")
fam=merge(fam,info1,by.y="Breed",by.x="V1")
fam=as.data.frame(fam)
head(fam)

fam=fam[,c("Abbr",paste0("V",1:6))] # %>% fwrite("all_file_ok_merged_cln.fam",sep= " ",quote=FALSE,col.names=FALSE)

fwrite(fam,"eu_NoprunedDat.fam",sep= " ",quote=FALSE,col.names=FALSE)

system("awk '{print $1,$2}' eu_NoprunedDat.ped > fam_id.txt")
info=readr::read_delim("fam_id.txt",delim=" ",col_names=c("Breed","id"))

head(info)
head(info1)

info=merge(info,info1,by="Breed")
head(info)

require("tidyverse")
o=info %>% arrange(Continent,CountryofOrigin) #%>% select(,id) #%>% fwrite("breed.txt",sep=" ")
o %>% select(Continent,CountryofOrigin,Abbr) %>% distinct() %>% select(Abbr) %>% as.data.frame() %>% View()
fwrite("breed.txt",sep=" ",col.names=FALSE)

#system("less -S eu_NoprunedDat.fam")

system("awk '{ $2=\"\"; print $0 }' eu_NoprunedDat.fam > tmp")
system("rm eu_NoprunedDat.fam")
system("mv tmp eu_NoprunedDat.fam")

membercoeff.circos(in.file = "eu_NoprunedDat", out.file = "As" ,K.to.plot = c(2,5,10,20,30,40,43),
pop.order.file = "breed.txt", 
software = "Admixture", maxK = "43",minK="42" 
                   , halfmoon = F, plot.format = "png", 
                   plot.cex = 5, plot.width = 100, plot.height = 100 )



