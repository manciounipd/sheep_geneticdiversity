#setwd("/media/enrico/Seagate Basic/ongoing/articolo_elena/analisi")
# resultr
getwd()
setwd("data_modfiy")
library(adegenet)
library(StAMPP)

setwd("/home/enrico/articolo_elena/analisi/")
setwd("data_modfiy/")
setwd("gooddb")

# clen and mak fst 

#https://yulab-smu.top/treedata-book/chapter7.html
mktree=function(file){
  tmp=adegenet::read.PLINK(file)
  TMP=StAMPP::stamppConvert(tmp,"genlight")
  tree=StAMPP::stamppFst(TMP, nboots = 100, percent = 95, nclusters = 1)
  a=ape::nj(as.dist(tree$Fsts))
  return(a)
}



getwd()
genind_data <- read.PLINK("vnt_fst.raw")  # Adjust file name

# Convert to genotype matrix
geno_matrix <- as.matrix(StAMPP::stamppConvert(genind_data,"genlight"))
#nei_dist <- stamppNeisD(geno_matrix, pop = TRUE)
nei_dist <- stamppNeisD(genind_data, pop = TRUE)
# Convert to distance matrix
nei_dist_matrix <- as.dist(nei_dist)
#nei_dist_matrix <- as.dist(nei_dist)

# Compute Nei’s genetic distances
nei_dist <- stamppNeisD(genind_data, pop = TRUE)

# Convert to distance matrix
nei_dist_matrix <- as.dist(nei_dist)




system("plink --allow-extra-chr --chr-set 26 --chr 1-26 --hwe 0.000000001 --bfile vnt  --mind 0.1 --geno 0.1 --recode A  --out vnt_fst")
tree=mktree("vnt_fst.raw")

ggtree(tree) +
                      
   #geom_tippoint(aes(color=group),size=15, alpha=.5)+
  geom_tiplab(size = 4, fontface = "italic")   # Label the tips
  theme_minimal()+theme_tree() +
  scale_color_manual(values = dark_palette) +
  # layout_inward_circular()+
   geom_rootpoint(color="black", size=3) +
   labs(color = "Nation")+
   theme(legend.position = "bottom")+
   guides(color = guide_legend(override.aes = list(size = 5)))


# fai una prova con quelli europei
smpa=data.table::fread("../../data_grezzi/metadati/sheep_map_rf2.txt",sep=",")

# fai solo eureopee
eu=smpa[smpa$Continent=="Europe",]$Breed
table(smpa[smpa$Continent=="Europe",]$CountryofOrigin)

data.table::fwrite(data.frame(brd=eu),"eu_brd.txt")



system("plink --allow-extra-chr --chr-set 26 --keep-fam  eu_brd.txt --chr 1-26 --hwe 0.000000001 --bfile wrd --mind 0.1 --geno 0.1 --recode A  --out eu_fst")
system("awk '{print $1}' eu_fst.raw | sort | uniq ")

eu_fst=mktree("eu_fst.raw")
eu_fst$tip.label
table(data.table::fread("eu.fam")$V1)
save(x=eu_fst,file=paste0("eu_fst.RData"))
eu_fst$tip.label

cat("now making words fst..\n")

system("plink --allow-extra-chr --chr-set 26 --chr 1-26  --bfile wrd --mind 0.1 --geno 0.1 --recode A  --out wrd_fst")
wrd_fst=mktree("wrd_fst.raw")
save(x=wrd_fst,file=paste0("wrd_fst.RData"))



stop("finish")

#

   # Add title
   #eu_fst

require("tidyverse")
require("ggtree")
load("eu_fst.RData")
source("../../script/muli_brd.R")
ls()

continet=give_me_contenet()
smpa=data.table::fread("../../data_grezzi/metadati/sheep_map_rf2.txt",sep=",")
# usa le abbreviazioni
x <- as_tibble(eu_fst)
for(i in unique(smpa$Breed)) x[x$label%in%i,]$label=smpa[smpa$Breed==i,]$Abbreviation
breeds_by_country=list()
country=unique(smpa[smpa$Continent=="Europe",]$CountryofOrigin)
for(i in country) breeds_by_country[[i]]=smpa[smpa$CountryofOrigin %in% i,]$Abbreviation

table(smpa$Abbreviation)

tree2 <-  treeio::as.treedata(x)


#p2=groupOTU(eu_fst,result$breeds_by_country)
p3=groupOTU(tree2,breeds_by_country)
#as_tibble(p2)
dark_palette <- c("#1b1b1b", "#4a4a4a", "#a80000", "#cc5500",
                  "#ff7700", "#ccaa00", "#008800", "#0055aa", "#002255",
                  "#550088", "#880055", "#660000")

nodes=as_tibble(p2) %>% filter(label %in% c("Foza","Lamon","Alpagota","Brogna"))


plt=ggtree(p3,layout = "circular",branch.length='none') +
 geom_hilight(mapping=aes(subset = node %in% 63),
                          fill="steelblue", type="rect",
                        alpha = .2) +
#  geom_hilight(mapping=aes(subset = node %in% 20),
  #                      fill="#B8860B", type="rect",
  #                      alpha = .2)+
                      ggnewscale::new_scale_fill()+
   geom_tippoint(aes(color=group),size=15, alpha=.5)+
  geom_tiplab(size = 4, fontface = "italic") +  # Label the tips
  theme_minimal()+theme_tree() +
  #scale_color_manual(values = dark_palette) +
  # layout_inward_circular()+
   geom_rootpoint(color="black", size=3) +
   labs(color = "Nation")+
   theme(legend.position = "bottom")+
   guides(color = guide_legend(override.aes = list(size = 5)))
                        #geom_tiplab()



getwd()

open_tree(plt,180)

dir.create("plot")
ggsave("plot/treev1.png", plot = plt, dpi = 300, width = 8, height = 8.3, units = "in")




#






#####################
plt=ggtree(p3) +
 geom_hilight(mapping=aes(subset = node %in% 63),
                          fill="steelblue", type="rect",
                        alpha = .2) +
#  geom_hilight(mapping=aes(subset = node %in% 20),
  #                      fill="#B8860B", type="rect",
  #                      alpha = .2)+
                      ggnewscale::new_scale_fill()+
   #geom_tippoint(aes(color=group),size=15, alpha=.5)+
  geom_tiplab(aes(color=group),size = 4, fontface = "italic") +  # Label the tips
  theme_minimal()+theme_tree() +
  scale_color_manual(values = dark_palette) +
  # 1layout_inward_circular()+
   geom_rootpoint(color="black", size=3) +
   labs(color = "Nation")+
   theme(legend.position = "bottom")+
   guides(color = guide_legend(override.aes = list(size = 5)))
                        #geom_tiplab()

data=data.frame(
           node = c(65, 50, 63),
           name = c("chicken", "Nordic\nBreed", "VNT")
       )


plt+geom_cladelab(
         data = data,
         mapping = aes(
             node = node, 
             label = name, 
             #color = name
         ),
       #  parse = "emoji",
         fontsize = 2,
         
         align = TRUE,
         show.legend = FALSE
     )


getwd()

dir.create("plot")
ggsave("plot/treev2.png", plot = plt, dpi = 300, width = 8, height = 8.3, units = "in")


####################


continet=give_me_contenet()
continet_and_abrv=brd_and_cnt()
continet_and_abrv[continet_and_abrv$FullName%in% 
   c("Brogna","Foza","Lamon","Alpagota"),"Abbreviation"] = c("BRN","FOZ","LMN","ALP")

breeds_by_continent2=list()
for(i in unique(continet_and_abrv$Continent)) breeds_by_continent2[[i]]=continet_and_abrv[continet_and_abrv$Continent==i,]$Abbreviation 

# abbrevi
x <- as_tibble(wrd_fst)
x$label=continet_and_abrv[match(x$label,continet_and_abrv$FullName),]$Abbreviation
tree2 <-  treeio::as.treedata(x)

for(i in unique(smpa_eu$group))  branches2[[i]]=smpa[smpa$group%in%i,]$ID

p2=groupOTU(wrd_fst,branches)
smpa_tmp[grep("Ara",smpa_tmp$ID),]

p2a=groupOTU(wrd_fst,breeds_by_continent)
p2a=groupOTU(tree2,breeds_by_continent2)

dark_palette <- c("#red", "#4a4a4a", "#a80000", "#cc5500",
                  "#ff7700", "#ccaa00", "#008800")

aa=ggtree(p2a,layout = "circular",branch.length='none') +
   ggnewscale::new_scale_fill()+
   geom_tippoint(aes(color=group),size=10, alpha=.5)+
  geom_tiplab(size = 5, fontface = "italic") +  # Label the tips
  theme_minimal()+theme_tree() +
  #scale_color_manual(values = dark_palette) +
  # layout_inward_circular()+
   geom_rootpoint(color="black", size=3) +
   labs(color = "Nation")+
   theme(legend.position = "bottom")+
   guides(color = guide_legend(override.aes = list(size = 5)))+
geom_hilight(mapping=aes(subset = node %in% 100),
                        fill="steelblue", type="rect",
                        alpha = .5) +
   geom_hilight(mapping=aes(subset = node %in% 140),
                        fill="#B8860B" , type="rect",
                        alpha = .5)                


ggsave("plot/tree_wrd.png", plot = aa, dpi = 300, width = 10, height = 10, units = "in")
