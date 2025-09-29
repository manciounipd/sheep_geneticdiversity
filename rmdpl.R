#!/usr/bin/env Rscript

# Legge gli argomenti dalla riga di comando
args <- commandArgs(trailingOnly = TRUE)

# Controlla che sia stato fornito un file di input
if (length(args) < 1) {
  stop("Errore: Devi specificare un file .bim in input.\nUso: Rscript script.R input.bim output.bim")
}

# File di input e output
input_file <- paste0(args[1],".bim")
output_file <- ifelse(length(args) > 1, args[2], sub("\\.bim$", "_dpl", input_file))

# Carica il file .bim
bim <- read.table(input_file, header = FALSE, stringsAsFactors = FALSE)

# Assegna nomi alle colonne
colnames(bim) <- c("CHR", "SNP", "CM", "POS", "A1", "A2")

# Trova duplicati basati su CHR e POS ma con nomi diversi
duplicates <- duplicated(bim[, c("CHR", "POS")]) | duplicated(bim[, c("CHR", "POS")], fromLast = TRUE)


# Salva il file pulito
write.table(bim[duplicates,] , output_file, quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")

cat("SNP duplicati per stessa posizione e cromosoma rimossi. Output salvato in:", output_file, "\n")




