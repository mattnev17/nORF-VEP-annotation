#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#Test for an argument. If not, return an error
if (length(args) != 1) {
  stop("Invalid argument. Must give input file name.", call.=FALSE)
}
#Convert BED file to GTF for VEP annotation pipeline
library(tidyverse)

inputFile <- args[1]
outputFile <- str_remove(inputFile,"temp.")
  
gtf <- read_tsv(inputFile, comment = "#", col_names = F, col_types = 'ccciicccc') %>% 
  mutate(X9 = ifelse(X3 == 'transcript', paste0(X9,' transcript_biotype "protein_coding";'),X9))
gtf_Genes <- gtf %>% 
  filter(X3 == 'transcript') %>% 
  mutate(X3 = 'gene') %>% 
  mutate(X9 = gsub('transcript_id.*$','' , X9)) %>% 
  mutate(X9 = paste0(X9,' gene_biotype "protein_coding";'))
gtf_full <- bind_rows(gtf,gtf_Genes) %>% 
  arrange(X1, X4) %>% 
  mutate(X9 = str_replace(X9, 'transcript_id "', 'transcript_id "t_'))
write.table(gtf_full, outputFile, col.names = F, row.names = F, sep = '\t', quote = F) 
