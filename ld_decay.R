# resultr
getwd()
setwd("data_modfiy/")
setwd("gooddb")
require(tidyverse)
all=list()

for(i in unique(data.table::fread("vnt.fam")$V1))  {
    data.table::fwrite(as.data.frame(i),"brd")
    system(paste0("plink --bfile vnt --allow-extra-chr --keep-fam brd --chr-set 26 --chr 1-26  --r2 --ld-window 99999 --ld-window-kb 1000 --ld-window-r2 0 --out ",i))

  system(paste0(
    "cat ", i, ".ld | sed '1d' | awk -F ' ' '{print ($5>$2 ? $5-$2 : $2-$5), $7}' ",
    "| sort -k1,1n > ",i,"snp-thin.ld.summary"
))

dfr <- data.table::fread(paste0(i,"snp-thin.ld.summary"),sep=" ",header=F,check.names=F,stringsAsFactors=F)
colnames(dfr) <- c("dist","rsq")

dfr$distc <- cut(dfr$dist,breaks=seq(from=min(dfr$dist)-1,to=max(dfr$dist)+1,by=100000))
#Then compute mean and/or median r2 within the blocks
dfr1 <- dfr %>% group_by(distc) %>% summarise(mean=mean(rsq),median=median(rsq))
#A helper step to get mid points of our distance intervals for plotting.
dfr1 <- dfr1 %>% mutate(start=as.integer(str_extract(str_replace_all(distc,"[\\(\\)\\[\\]]",""),"^[0-9-e+.]+")),
                        end=as.integer(str_extract(str_replace_all(distc,"[\\(\\)\\[\\]]",""),"[0-9-e+.]+$")),
                        mid=start+((end-start)/2))

dfr1$breed=i
all[[i]]=dfr1

}

all=do.call("rbind",all)

all[all$breed=="Foza","Breed"]="FOZ"
all[all$breed=="Alpagota","Breed"]="LPG"
all[all$breed=="Brogna","Breed"]="BRN"
all[all$breed=="Lamon","Breed"]="LMN"

# SAVE 

LD=ggplot(data=all,aes(x=start/10^6,y=mean,color=Breed))+
  geom_point()+
  geom_line()+
  labs(x="Distance (Megabases)",y=expression(LD~(r^{2})))+
  #scale_x_continuous(breaks=c(0,2*10^6,4*10^6,6*10^6,8*10^6),labels=c("0","2","4","6","8"))+
  theme_bw()
  

getwd()
ggsave("plot/LvD_wrd.png", plot = LD, dpi = 300, width = 5, height = 5, units = "in")


