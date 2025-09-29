setwd("data_modfiy/")
setwd("gooddb")

require(tidyverse)

sw=theme_minimal()+theme(#axis.line = element_line(),
  strip.text.y = element_text(size = 25,face ="italic",angle=.9),
  strip.text.x = element_text(size = 25,face ="italic",angle=.9),
  panel.grid.major = element_blank(),
  plot.background = element_rect(fill = "white"),
  panel.grid.minor = element_blank(),
     plot.title = element_text( face="bold",  size=20),
     plot.subtitle = element_text( face="italic",  size=16,element_text(hjust = 0.5)),
    axis.title.y = element_text(face = "italic",size=20),
  axis.title.x = element_text(face = "italic",size=20),
  #axis.line.x = element_line(size = .5, colour = "black"),
  axis.text.y = element_text(size = 20, face = "italic"),
    axis.text.x = element_text(size = 20, face = "italic"),
  #  strip.text.x = element_text(size=24, face="bold"),
   legend.text = element_text(size = 20, face = "italic"),
  panel.background = element_blank(),
  legend.position="none",
   panel.border = element_rect(colour = "grey10", fill=NA, size=1))

# fai una prova con quelli europei
smpa=data.table::fread("../../data_grezzi/metadati/sheep_map_rf2.txt",sep=",")

eu=smpa[smpa$Continent=="Europe" & !smpa$Abbreviation %in% c("BOR","SOA"),]$Breed
eu=smpa[smpa$Continent=="Europe" ,]$Breed


data.table::fwrite(data.frame(brd=eu),"eu_brd.txt")

neig=9
system(paste0("plink --allow-extra-chr --chr-set 26 --keep-fam  eu_brd.txt --chr 1-26  --bfile wrd --maf 0.05 --mind 0.1 --geno 0.1 --pca ",neig,"  --out eu_pca"))
pca_data <- data.table::fread("eu_pca.eigenvec")
colnames(pca_data) <- c("FID", "IID", paste0("PC", 1:neig))

pca_ev<- data.table::fread("eu_pca.eigenval")
pca_ev=pca_ev/sum(pca_ev)




# scirvere escluso le inglesi
# Merge the mean data with the original PCA data
merged_data <- merge(pca_data, mean_data, by = "FID")

# MERGE WITH ACRONOMIC
names(smpa)[1]="Breed"
pca_data=merge(pca_data,smpa[,c("Breed","Abbreviation","CountryofOrigin")],by.x="FID",by.y="Breed")


mean_data <- pca_data %>%
  group_by(Abbreviation) %>%
  summarise(mean_PCA1 = mean(PC1), mean_PCA2 = mean(PC2),mean_PCA3 = mean(PC3))


# Plot PCA (PC1 vs PC2)
pca_eu=ggplot(pca_data, aes(x = PC1, y = PC2, label=IID,color = FID)) +
  geom_point(size = 5, alpha = .5) +
  theme_minimal() +
 ggrepel::geom_text_repel(data=mean_data,aes(x=mean_PCA1,y= mean_PCA2,label=Abbreviation),
                            size=7,color="black", max.overlaps =10) +  
  labs( x = paste0("PC1: ",round(100*pca_ev[1]),"%"),
                            y =  paste0("PC2: ",round(100*pca_ev[2]),"%"),) +
 # theme(legend.position = "right")+
  theme(legend.position = "none")+sw



# Plot PCA (PC1 vs PC2)
pca_eu2=ggplot(pca_data, aes(x = PC2, y = PC3, label=IID,color = FID)) +
  geom_point(size = 5, alpha = .5) +
  theme_minimal() +
 ggrepel::geom_text_repel(data=mean_data,aes(x=mean_PCA2,y= mean_PCA3,label=FID),
                            size=7,color="black", max.overlaps =30) +  
  labs( x = paste0("PC2: ",round(100*pca_ev[2]),"%"),
                            y =  paste0("PC3: ",round(100*pca_ev[3]),"%"),) +
 # theme(legend.position = "right")+
  theme(legend.position = "none")+sw



#q0
ggsave("plot/pca_eu.png", plot = pca_eu, dpi = 300, width = 15, height = 15, units = "in")

ggsave("plot/pca_eu2.png", plot = pca_eu2, dpi = 300, width = 10, height = 10, units = "in")

pca_ev$pc=1:nrow(pca_ev)

names(pca_ev) <- c("var_percent", "PC")  
VARP=ggplot(data = pca_ev, aes(x = PC, y = var_percent)) +
  geom_point(size = 3) +
  geom_line()


ggsave("plot/eig.png", plot = VARP, dpi = 300, width = 4, height = 4, units = "in")






