# Script Comments ---------------------------------------------------------
# this is a script that can be used to regenerate some of datasets used in the
# MGEnrichment app as required whenever they need to be updated
# simply update the spreadsheet that is read in as "masterlist"

library(biomaRt)
library(here)
library(tidyverse)

# get mouse ensemble data
mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")

# query ensemble and entrez ids - this is the dataset with all mouse genes
mouse_genes <- getBM(attributes = c("ensembl_gene_id","mgi_symbol", "hgnc_symbol", "entrezgene_id"),
               mart = mouse)


# read in mg genelists - this is a manually curated dataset containing MG relevant genes
# every time the spreadsheet is updated, it can be reloaded here
masterlist <- read.csv(here("Microglia.Mouse.GeneListDatabase.11.21.2020.csv"))[,-1]


##################################################################################
#add in new genelists - Example
#replace datasets with your own csv files
##################################################################################
#DAM MG

#must have the following columns:
#[1] "ensembl_gene_id" "mgi_symbol"      "hgnc_symbol"     "entrezgene_id"   "listname"        "description"    
#[7] "source"          "groups"          "Species"         "tissue"          "shortname" 

### sample datasets
DAM1 <- read.csv("DAMgreaterHOM.MG.csv")
DAM2 <- read.csv("DAMlessHOM.MG.csv")
DAM3 <- read.csv("DAMstage1greaterDAMstage2.MG.csv")
DAM4 <- read.csv("DAMstage1lessDAMstage2.MG.csv")

DAM <- rbind(DAM1,DAM2,DAM3,DAM4)

DataBasemm10 <- rbind(masterlist,DAM)

write.csv(DataBasemm10,file="Microglia.Mouse.GeneListDatabase.newdatehere.csv")

#make summary file of all gene counts per list
summ.files <- DataBasemm10[,c(1,5:ncol(DataBasemm10))]

summ.files <- summ.files %>% distinct() %>%
  group_by(listname,description,source,groups,Species,tissue,shortname) %>% 
  summarize(ensemble.genes = n())

write.csv(summ.files, file= "Genelists.in.mm10Database.newdatehere.csv")

#--------------------------------
  
#write out new R objects for comparisons for each gene ID type:
mergedGenes <- DataBasemm10
# generate ensembl list
ensemblList <- split(mergedGenes$ensembl_gene_id, mergedGenes$listname)
ensemblList <- sapply(ensemblList, na.omit)
ensemblList <- sapply(ensemblList, unique)


# generate entrez list
entrezList <- split(mergedGenes$entrezgene_id, mergedGenes$listname)
entrezList <- sapply(entrezList, na.omit)
entrezList <- sapply(entrezList, unique)

# generate MGI list
mgiList <- split(mergedGenes$mgi_symbol, mergedGenes$listname)
mgiList <- sapply(mgiList, na.omit)
mgiList <- sapply(mgiList, unique)


# save data output
save(ensemblList, entrezList, mgiList, mouse_genes, masterlist, 
     file = here("GeneLists.RData"))



