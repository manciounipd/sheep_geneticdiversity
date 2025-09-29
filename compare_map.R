#!/usr/bin/env Rscript

# Carica la libreria necessaria


library(tidyverse)


# Legge gli argomenti della riga di comando
args <- commandArgs(trailingOnly = TRUE)

# Controlla che siano stati forniti due file di input
if (length(args) < 2) {
  stop("Uso: Rscript compare_map.R <file1.bim> <file2.bim>")
}

#setwd("D:/ongoing/articolo_elena/analisi")
#file1 <-"D:/ongoing/articolo_elena/analisi/data_modfiy/round3v2.bim"
#file2 <-"D:/ongoing/articolo_elena/analisi/data_modfiy/round2v1.bim"

file1 <- paste0(args[1],".bim")
file2 <- paste0(args[2],".bim")

clean_filename <- function(filepath) {
  name <- basename(filepath)  # Ottieni solo il nome del file senza percorso
  name <- strsplit(name, "\\.")[[1]][1]  # Rimuovi tutto dopo il primo punto
  return(name)
}

output_file <- paste0(clean_filename (file1),"vs",clean_filename (file2),"common_snps.tsv")
output_diff_file <- paste0(clean_filename (file1),"vs",clean_filename (file2),"diff_pos_or_chr.tsv")

# Funzione per confrontare i file .bim
compare_map_files <- function(file1, file2, output_file, output_diff_file) {
  # Nomi delle colonne del file .bim
  col_names <- c("CHR", "SNP", "CM", "POS", "A1", "A2")
  
  # Legge i file
  map1_df <- read.table(file1, header = FALSE, stringsAsFactors = FALSE, col.names = col_names)
  map2_df <- read.table(file2, header = FALSE, stringsAsFactors = FALSE, col.names = col_names)
  
  # Unisce i due file in base alla colonna SNPGETWD
  common_snps <- merge(map1_df, map2_df, by = "SNP", suffixes = c("_map1", "_map2"))
  
  # Trova le SNPs con differenze di posizione o cromosoma
  common_snps_diff_pos_or_chr <- common_snps %>%
    filter(CHR_map1 != CHR_map2 | POS_map1 != POS_map2)
  
  # Scrive i risultati nei file di output
  write.table(common_snps[, c("SNP", "CHR_map1", "POS_map1")], 
              file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
  
  write.table(common_snps_diff_pos_or_chr, file = output_diff_file, 
              sep = "\t", row.names = FALSE, quote = FALSE)

  return(common_snps[, c("SNP", "CHR_map1", "POS_map1")])
    cat("done\n")
}


# Esegue la funzione con i file forniti
snp=compare_map_files(file1, file2, output_file, output_diff_file)
#snp %>% group_by(SNP) %>% filter(n()>1) %>% 
write.table(file = paste0( output_diff_file,"dpl"), 
              sep = "\t", row.names = FALSE, quote = FALSE)
getwd()
