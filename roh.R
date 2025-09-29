require("detectRUNS")
require("ggpubr")
library("ggpmisc")

#https://onlinelibrary.wiley.com/doi/epdf/10.1111/age.12634
"✅ Minimum ROH length set to 1 Mb (1,000,000 bp)
 ✅ Minimum SNPs per ROH set to 30 
 ✅ SNP density set to 1 SNP per 100 kb 
 ✅ Maximum gap between SNPs set to 250 kb
 ✅ Allowed heterozygous and missing SNPs set to 1"

getwd()
setwd("data_modfiy/")
setwd("gooddb")

# clen and mak fst 
system("plink --allow-extra-chr --chr-set 26  --chr 1-26 --bfile vnt --recode --out vnt")
genotypeFilePath = "vnt.ped" 
mapFilePath= "vnt.map"
require(tidyverse)

slidingRuns <- slidingRUNS.run(
  genotypeFile = genotypeFilePath, 
  mapFile = mapFilePath ,
  windowSize = 50,        # Sliding window size
  #threshold = 0.05,       # Significance threshold
  minSNP = 30,           # Minimum number of SNPs in ROH
  ROHet = FALSE,          # Only consider homozygous runs
  maxOppWindow = 1,       # Maximum heterozygous SNPs per window
  maxMissWindow = 1,      # Maximum missing SNPs per window
  maxGap = 250000,        # Max gap between SNPs in ROH (250 kb)
  minLengthBps = 1e4,     # Minimum ROH length (1 Mb)
  minDensity = 1/100000,  # Minimum SNP density (1 SNP per 100 kb)
  maxOppRun = 1,          # Maximum heterozygous SNPs allowed in a run
  maxMissRun = 1          # Maximum missing SNPs allowed in a run
)


consecutiveRuns <- consecutiveRUNS.run(
  genotypeFile = genotypeFilePath, 
  mapFile = mapFilePath ,
  minSNP = 25,           # Minimum number of SNPs in ROH
  ROHet = FALSE,         # Only consider homozygous runs
  maxGap = 250000,       # Max gap between SNPs in ROH (250 kb)
  minLengthBps = 1e3,    # Minimum ROH length (1 Mb)
  maxOppRun = 1,         # Maximum heterozygous SNPs allowed in a run
# minDensity = 1/100000, 
  maxMissRun = 1         # Maximum missing SNPs allowed in a run
)


# supllementary material
png("plot/run.png")
plot_manhattanRuns(runs = consecutiveRuns,#[consecutiveRuns$group=="Foza",], 
  genotypeFile = genotypeFilePath, mapFile = mapFilePath)
dev.off()


df=detectRUNS::Froh_inbreeding(consecutiveRuns, mapFile = mapFilePath)  
df[df$group=="Foza","Breed"]="FOZ"
df[df$group=="Alpagota","Breed"]="LPG"
df[df$group=="Brogna","Breed"]="BRO"
df[df$group=="Lamon","Breed"]="LMN"

df %>% group_by(Breed) %>% summarize(m=mean(Froh_genome),sd=sd(Froh_genome))

# correlation with inbreedinf
ggviolin(df, y = "Froh_genome", x = "Breed", fill = "Breed",
         palette = c("#00AFBB", "#E7B800", "#FC4E07", "#7E57C2"),
         add = "boxplot", add.params = list(fill = "white"))+
          sw+theme( legend.position = "none")



system("plink --bfile vnt --allow-extra-chr --chr-set 26   --het --out vnt_inbreeding")
inbr=detectRUNS::Froh_inbreeding(consecutiveRuns, mapFile = mapFilePath)[,-3]
db=data.table::fread("vnt_inbreeding.het")

names(db)[1:2]=names(inbr)[2:1]
db=db[,c(1,2,6)]

df=merge(db,inbr) 

tmp=df %>% reshape2::melt(id=c("group","id"))
tmp[tmp$group=="Foza","Breed"]="FOZ"
tmp[tmp$group=="Alpagota","Breed"]="LPG"
tmp[tmp$group=="Brogna","Breed"]="BRO"
tmp[tmp$group=="Lamon","Breed"]="LMN"

tmp$variable=as.character(tmp$variable)
tmp[tmp$variable=="Froh_genome","variable"]="Froh"
tmp[tmp$variable=="F","variable"]="Fhet"
tmp[tmp$group=="Foza","Breed"]="FOZ"
tmp[tmp$group=="Alpagota","Breed"]="LPG"
tmp[tmp$group=="Brogna","Breed"]="BRN"
tmp[tmp$group=="Lamon","Breed"]="LMN"



tmp %>% group_by(Breed,variable) %>% summarize(m=mean(value),sd=sd(value))


plot1=ggviolin( tmp,y = "value", x = "Breed", fill = "group",
         palette = c("#00AFBB", "#E7B800", "#FC4E07", "#7E57C2"),
         add = "boxplot", add.params = list(fill = "white"))+
          sw+theme( legend.position = "none")+
          facet_grid((variable)~.)


df[df$group=="Foza","Breed"]="FOZ"
df[df$group=="Alpagota","Breed"]="LPG"
df[df$group=="Brogna","Breed"]="BRN"
df[df$group=="Lamon","Breed"]="LMN"


plot2=ggplot(data = df, aes(x=as.double(F),y=as.double(Froh_genome))) +
  stat_poly_line() +
  stat_poly_eq(size=7) +
  geom_point()+xlab("Fhet")+ylab("Froh")+
  facet_grid(vars(Breed))+sw


Fin=ggpubr::ggarrange(plot1,plot2,labels=c("A","B"),ncol=2)
png("plot/Fvnt.png", res = 300, width = 13, height = 13, units = "in")
  Fin
dev.off()




# Summarize data per individual

roh_summary <- consecutiveRuns %>%
  group_by(id, group) %>%
  summarise(TotalROH = n(),
            ROHLengthMb = sum(lengthBps) / 1e6)  # Convert to Mb


# Plot
ggplot(roh_summary, aes(x = ROHLengthMb, y = TotalROH, color = group)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(title = "Total ROHs vs. Genome Length Covered by ROHs",
       x = "Total Genome Covered by ROH (Mb)",
       y = "Total Number of ROHs",
       color = "Breed") +
  theme_minimal() +
  theme(legend.position = "top")



png("plot/roh_class.png", res = 300, width = 5, height = 5, units = "in")
ggplot(tmp, aes(x =type, y = as.double(value), fill = variable)) + geom_col(position = "dodge2")
dev.off()

#0.5–5 Mb, 5–10 Mb, 10–15 Mb, 15–20 Mb and > 20 Mb

summaryList <- summaryRuns(
  runs = consecutiveRuns, mapFile = mapFilePath, genotypeFile = genotypeFilePath, 
  Class = c(2.5), snpInRuns = TRUE)
  
df=summaryList$summary_ROH_percentage
df$type=row.names(df)

tmp=df %>% reshape2::melt(id=c("type"))
head(tmp)
tmp[tmp$variable=="Foza","Breed"]="FOZ"
tmp[tmp$variable=="Alpagota","Breed"]="LPG"
tmp[tmp$variable=="Brogna","Breed"]="BRN"
tmp[tmp$variable=="Lamon","Breed"]="LMN"
tmp=tmp[complete.cases(tmp),]

tmp$type=as.factor(tmp$type)
tmp$type=as.factor(tmp$type)

tmp$type <- factor(tmp$type, levels=c("0-2.5","2.5-5" ,"5-10","10-20"))

tmp$type <- factor(tmp$type, levels=c("0-1","1-2" ,"2-4","4-8",">8"))


as=ggplot(tmp, aes(x =type, y = as.double(value),group=Breed,color=Breed, fill = Breed)) + 
geom_point(size=5)+geom_line()+ylab("% ROH")+
xlab("Lenght Class")


png("plot/roh_class.png", res = 300, width =7, height = 10, units = "in")
as+theme_bw()
dev.off()

db=summaryList$summary_ROH_count
db$type=row.names(db)
tmp=db %>% reshape2::melt(id=c("type"))
head(tmp)

