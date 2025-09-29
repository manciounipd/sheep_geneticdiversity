setwd("/home/enrico/articolo_elena/analisi/data_modfiy")
setwd("admx")
#setwd("vnt_breed")
system("ls")

require("ggplot2")
sw=theme_minimal()+theme(#axis.line = element_line(),
  strip.text.y = element_text(size = 25,face ="italic",angle=.9),
  strip.text.x = element_text(size = 25,face ="italic",angle=.9),
  panel.grid.major = element_blank(),
 # plot.background = element_rect(fill = "white"),
  panel.grid.minor = element_blank(),
     plot.title = element_text( face="bold",  size=20),
     plot.subtitle = element_text( face="italic",  size=16,element_text(hjust = 0.5)),
    axis.title.y = element_text(face = "italic",size=25),
  axis.title.x = element_text(face = "italic",size=20),
  #axis.line.x = element_line(size = .5, colour = "black"),
  #axis.text.y = element_text(size = 20, face = "italic"),
  #  axis.text.x = element_text(size = 20, face = "italic"),
  #  strip.text.x = element_text(size=24, face="bold"),
   legend.text = element_text(size = 20, face = "italic"),
  panel.background = element_blank(),
  axis.text.x = element_blank(), axis.ticks.x = element_blank(),
  axis.text.y = element_blank(), axis.ticks.y = element_blank(),
  legend.position="none"
   #panel.border = element_rect(colour = "grey10", fill=NA, size=1)
   )
require("data.table")

system("ls")
setwd("admx")
setwd("eu_breed")

file=list.files()
file=file[grep("log",file)]

x=1
cv=list()
for(i in file) {
    cv[[x]]=system(paste0("grep CV ",i),intern=TRUE)[1]
    x=x+1
}

cva=as.data.frame(do.call("rbind",cv))
nrow(cva)
head(cva)
cva$V1=gsub("CV error ","",cva$V1)

df=as.data.frame(do.call("rbind",sapply(cva$V1, function(x) strsplit(x, ":", fixed = TRUE)[[1]])))
df$V1=gsub("[^0-9]", "", df$V1)
df=df[complete.cases(df),]
row.names(df)=1:nrow(df)
names(df) = c("K","values")

require(ggplot2)
df$values=as.double(df$values)
df$K=as.double(df$K)

tmp=df[df$values==min(df$values),]
png(paste0("../../gooddb/plot/Kadmx",5,".png") ,res = 300, width =15, height = 13, units = "in")
ggplot(df,aes(x=as.integer(K),y=as.double(values)))+
geom_point(size=5)+
geom_line()+
geom_vline(xintercept=tmp$K,color="red",linetype=4)+
geom_text(data=tmp,
            aes(x=K+3,y=mean(df$values)+2*sd((df$values)),
                label=paste0("K:",K)),size=10)+
                theme_bw()+ylab("CV error")+xlab("K")
dev.off()

library(data.table)
library(tidyverse)
library(ggpubr)
K=5
K_values <- c(5, 10, 20,42)
AB <- list()

system("ls  eu_*")
library(viridis)
getK <- function(K_values, labs) {
  n = K_values
  smpa <- data.table::fread("../../../data_grezzi/metadati/sheep_map_rf2.txt", sep = ",")[, c("Breed/Species", "Abbreviation", "CountryofOrigin")]
  names(smpa) <- c("FID", "ABR", "Nation")
  
  qmatrix <- fread(paste0("eu_NoprunedDat.", n, ".Q"))
  fam <- read.table("eu_NoprunedDat.fam", header = FALSE)
  admix_data <- cbind(fam[, 1:2], qmatrix)
  colnames(admix_data) <- c("FID", "IID", paste("K", 1:n, sep=""))
  
  # Debugging check
  print(admix_data[admix_data$FID == "Brogna", ])
  
  # Merging metadata with admixture data
  all <- merge(smpa, admix_data, by = "FID", all.x = TRUE)
  
  # Reshape the data into long format
  admix_long <- all %>%
    pivot_longer(cols = starts_with("K"), names_to = "K", values_to = "Proportion") %>%
    mutate(Nation_Breed = paste(Nation, FID, sep = " - "))
  
  # Ordering x-axis by Nation, Breed, then Individuals
  admix_long <- admix_long %>%
    arrange(Nation, FID, IID) %>%
    mutate(IID = factor(IID, levels = unique(IID)))  
  
  nat <- unique(admix_long$Nation)
  lx <- list()
  
  # Create plots by nation
  for (i in nat) {
    ab <- admix_long %>% filter(Nation == i) %>% pull(IID)
    if (length(ab) > 0) {
      pos <- ab[length(ab)]
      print(i)
      
      admix_long_tmp = admix_long %>% filter(Nation == i) %>% filter(!is.na(Proportion))
    colors <- viridis(n)
    lx[[i]] <- ggplot(admix_long_tmp %>% filter(Nation == i), aes(x = IID, y = Proportion, fill = K)) +
      geom_bar(stat = "identity", position = "stack") +
      facet_grid(. ~ ABR, scales = "free_x") +  # Faceting by ABR
      scale_y_continuous(expand = c(0, 0), limits = c(-0.011, 1.0001)) + 
      ylab(i)+sw+xlab("")+scale_fill_manual(values = colors) 
    }
  }
  
  # Adjust the plot for UK
  lx[["UnitedKingdom"]] = lx[["UnitedKingdom"]] + ylab("UK")
  
  # Adjust labels based on `labs` argument
  if (labs == "No") {
    for (i in names(lx)) {
      lx[[i]] = lx[[i]] + ylab("")
    }
  }
  
  # Combine all the plots using ggarrange
  A <- ggarrange(
    lx[["Ireland"]], lx[["UnitedKingdom"]], 
    lx[["Germany"]], lx[["France"]],  # Corrected name from "French" to "France"
    lx[["Italy"]], lx[["Spain"]], lx[["Switzerland"]],
    ncol = 1, common.legend = TRUE, legend = "none"
  )
  
  return(A)
}

# Generate a 30-color palette



K5[[1]]
K5[[1]]
K5=getK(6,"sdf")
K10=getK(10,labs="Nso")
K45=getK(43,labs="Nso")

getK(30,labs="Nso")

plotaa=ggpubr::ggarrange(K5,K10,K45)

getK(20,labs="Nso")

getwd()
system("ls ../../gooddb")
png(paste0("../../gooddb/plot/admx",5,".png") ,res = 300, width =15, height = 13, units = "in")
K5
dev.off()

png(paste0("../../gooddb/plot/admx",10,".png") ,res = 300, width =15, height = 13, units = "in")
K10
dev.off()

png(paste0("../../gooddb/plot/admx",43,".png") ,res = 300, width =15, height = 13, units = "in")
K45
dev.off()

system("ls")
n=2
x=1

A <- list()  # Initialize the list
x <- 1  # Initialize x to start from 1

for (n in c(2, 5)) {
  # Read the data
  qmatrix <- fread(paste0("vnt_admx.", n, ".Q"))
  fam <- read.table("vnt_admx.fam", header = FALSE)
  
  # Combine the data
  admix_data <- cbind(fam[, 1:2], qmatrix)
  colnames(admix_data) <- c("FID", "IID", paste("K", 1:n, sep = ""))
  
  # Transform the data to long format
  admix_long <- admix_data %>%
    pivot_longer(cols = starts_with("K"), names_to = "K", values_to = "Proportion") 
  
  # Ordering x-axis by FID, IID
  admix_long <- admix_long %>%
    arrange(FID, IID) %>%
    mutate(IID = factor(IID, levels = unique(IID)))
  
  # Set colors based on 'n'
  colors <- viridis(n)

admix_long[admix_long$FID=="Foza","Breed"]="FOZ"
admix_long[admix_long$FID=="Alpagota","Breed"]="LPG"
admix_long[admix_long$FID=="Brogna","Breed"]="BRN"
admix_long[admix_long$FID=="Lamon","Breed"]="LMN"
admix_long$Breed=as.factor(admix_long$Breed)
admix_long$Breed=ordered(admix_long$Breed, levels = c("LPG", "BRN", "FOZ","LMN"))  
# Create the plot
A[[x]] <- ggplot(admix_long , aes(x = IID, y = Proportion, fill = K)) +
      geom_bar(stat = "identity", position = "stack") +
      facet_grid(. ~ Breed, scales = "free_x") +  # Faceting by ABR
      scale_y_continuous(expand = c(0, 0), limits = c(-0.011, 1.0001)) + 
      ylab(i)+sw+xlab("")+scale_fill_manual(values = colors) 
  
  x <- x + 1  # Increment x for the next iteration
}

require(ggpubr)

getwd()

F=ggarrange(A[[1]]+ylab(""),A[[2]]+ylab(""),ncol=1)

system("ls *")
neig=10
d=paste0("plink --allow-extra-chr --chr-set 26  --chr 1-26  --bfile vnt_admx --hwe 0.00000001 --maf 0.05 --mind 0.1 --geno 0.1 --pca ",neig,"  --out eu_pca")
system(d)

pca_data <- data.table::fread("eu_pca.eigenvec")
colnames(pca_data) <- c("FID", "IID", paste0("PC", 1:neig))


pca_data[pca_data$FID=="Foza","Breed"]="FOZ"
pca_data[pca_data$FID=="Alpagota","Breed"]="LPG"
pca_data[pca_data$FID=="Brogna","Breed"]="BRN"
pca_data[pca_data$FID=="Lamon","Breed"]="LMN"

mean_data <- pca_data %>%
  group_by(Breed) %>%
  summarise(mean_PCA1 = mean(PC1), mean_PCA2 = mean(PC2),mean_PCA3 = mean(PC3))



pca_ev<- data.table::fread("eu_pca.eigenval")
pca_ev=pca_ev/sum(pca_ev)


# scirvere escluso le inglesi
# Merge the mean data with the original PCA data
merged_data <- merge(pca_data, mean_data, by = "FID")



pca_eu=ggplot(pca_data, aes(x = PC1, y = PC2, label=IID,color = FID)) +
  geom_point(size = 5, alpha = .5) +
  theme_minimal() +
 ggrepel::geom_text_repel(data=mean_data,aes(x=mean_PCA1,y= mean_PCA2,label=Breed),
                            size=7,color="black", max.overlaps =10) +  
  labs( x = paste0("PC1: ",round(100*pca_ev[1]),"%"),
                            y =  paste0("PC2: ",round(100*pca_ev[2]),"%"),) +
 # theme(legend.position = "right")+
  theme(legend.position = "none")+theme_bw()



ggarrange(F,pca_eu,ncol=2)
combined_plot <- ggarrange(F, pca_eu, ncol = 1,labels =c("A","B") ,heights = c(1, 1))


png(paste0("../../gooddb/plot/VNTC.png") ,res = 300, width =10, height = 15, units = "in")
combined_plot
dev.off()
