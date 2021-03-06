#!/usr/bin/env Rscript

arg <-  commandArgs(trailingOnly = T)
rawCounts <- arg[1]
#rawCounts <- "/1006.rawCounts/1006/tables"
library(dplyr)


fileNames <- list.files( arg[1], pattern = ".complete")
filePath <- paste0(arg[1], fileNames)

# import SAR tool files as objects 

for (i in 1:length(fileNames)) {
      
      assign(strsplit(fileNames[i], "\\.")[[1]][1],
      value = read.table(filePath[i], header = TRUE),
      envir = .GlobalEnv)
}


for (i in 1:length(objects(pattern = "vs"))) {

 z <- c("dispGeneEst","dispFit","dispMAP","dispersion","betaConv","maxCooks" )
 pattern <- as.data.frame(mget(ls(pattern = "vs")[1]), col.names = NULL)
 assign(paste0(strsplit(fileNames[i], "\\.")[[1]][1], ".rmLast6"),
          value = select(pattern, -z),
          envir = .GlobalEnv)
 
}

obj <- objects(pattern = ".rmLast6")

for (i in 1:length(obj)) {
  assign(x = paste0(obj[i],".Annotated"),
        value = as.data.frame(mget(obj[i]),col.names = NULL) %>% 
          rename(!!paste0(strsplit(obj[i], "\\.")[[1]][1],".FoldChange") := FoldChange,
                 !!paste0(strsplit(obj[i], "\\.")[[1]][1],".log2FoldChange") := log2FoldChange,
                 !!paste0(strsplit(obj[i], "\\.")[[1]][1],".stat") := stat,
                 !!paste0(strsplit(obj[i], "\\.")[[1]][1],".pvalue") := pvalue,
                 !!paste0(strsplit(obj[i], "\\.")[[1]][1],".padj") := padj),
           envir = .GlobalEnv
        
          )
}


obj2 <- objects(pattern = "Annotated")

new.data.frame <- as.data.frame(mget(obj2[1]),col.names = NULL)

for (i in 2:length(obj2)){
  
  new.data.frame <- full_join(new.data.frame, 
  select(as.data.frame(mget(obj2[i]),col.names = NULL), Id, matches("vs")), 
  by = "Id")
  
}

write.table(new.data.frame, "final.txt", sep = "\t", quote = F, row.names = F)




