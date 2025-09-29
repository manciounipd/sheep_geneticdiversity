#install.packages(c("ggplot2", "data.table"))  # Install if needed

library(ggplot2)
library(data.table)

setwd("../")

setwd("data_modfiy/")
system("plink --allow-extra-chr --chr-set 26 --chr 2 --bfile vnt --make-grm-gz --pca  --out pca_dc_vnt")

# Read the PCA results
pca_data <- fread("pca_dc_vnt.eigenvec")
f=fread("pca_dc_vnt.eigenval")
plot(1:nrow(f),f$V1,"o")

# Rename columns (PLINK format: FID, IID, PC1, PC2, ..., PC10)
colnames(pca_data) <- c("FID", "IID", paste0("PC", 1:20))

# Plot PCA (PC1 vs PC2)
q0=ggplot(pca_data, aes(x = PC1, y = PC2, label=IID,color = FID)) +
  geom_text(size = 3, alpha = 0.8) +
  theme_minimal() +
  labs(title = "PCA Plot", x = "Principal Component 1", y = "Principal Component 2") +
  theme(legend.position = "right")

png("pca.png",width=15, height=15, res=300,units="in")
q0
dev.off()



setwd("../")

setwd("/home/enrico/articolo_elena/analisi/data_grezzi/invio1/Univ_of_Padova_Cecchinato_OVNG50V01_20200706")
system("plink  --allow-extra-chr --chr-set 26 --file test_outputfile --ibs-matrix --out grm_output")

# Load IBS matrix
ibs_matrix <- as.matrix(read.table("grm_output.mibs"))
image(ibs_matrix)

getwd()
setwd("/home/enrico/articolo_elena/analisi/data_modfiy/")
getwd()

system("cp /home/enrico/articolo_elena/analisi/data_grezzi/invio1/Univ_of_Padova_Cecchinato_OVNG50V01_20200706/test_outputfile.ped .")
system("cp /home/enrico/articolo_elena/analisi/data_grezzi/invio1/Univ_of_Padova_Cecchinato_OVNG50V01_20200706/test_outputfile.map .")

system("plink  --allow-extra-chr --chr-set 26 --file test_outputfile  --ibs-matrix --out grm_output")



# Load IBS matrix
ibs_matrix <- as.matrix(read.table("grm_output.mibs"))
image(ibs_matrix)

