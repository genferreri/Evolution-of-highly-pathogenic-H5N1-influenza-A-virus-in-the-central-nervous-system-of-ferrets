#!/usr/local/bin/Rscript
#This script was made by LMF - 2019
file1 <- list.files(path = ".", pattern = "\\.tsv")

library(readr)
AF.Cov.clean.temp <- read_delim(file1, "\t", col_names = FALSE, trim_ws = TRUE)
colnames(AF.Cov.clean.temp) <- c("Segment", "Position", "Coverage", "length", "REF", "ALT", "AF", "Sample")
write.tsv(AF.Cov.clean.temp, file='AF.Cov.clean.temp.tsv', sep="\t", row.names = F, quote = F)
