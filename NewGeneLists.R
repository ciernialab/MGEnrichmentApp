# Script Comments ---------------------------------------------------------
# this is a script that can be used to regenerate the datasets used in the
# MGEnrichment app as required whenever they need to be updated
# simply update the spreadsheet that is read in as "masterlist", and the script
# will do the rest

library(biomaRt)
library(here)

# get mouse ensemble data
mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")

# query ensemble and entrez ids - this is the dataset with all mouse genes
mouse_genes <- getBM(attributes = c("ensembl_gene_id","mgi_symbol", "hgnc_symbol", "entrezgene_id"),
               mart = mouse)

# read in mg genelists - this is a manually curated dataset containing MG relevant genes
# every time the spreadsheet is updated, it can be reloaded here
masterlist <- read.csv(here("Microglia.Mouse.GeneListDatabas.withLPSDEGs.8_21.2020.csv"))[,-1]

#removing the MeCP2 targets list here since it is unecessary and excessively large
#if needed, can be commented out to keep the list in
masterlist <- masterlist[masterlist$listname != "MeCP2 targets",]

# merge genes together
mergedGenes <- merge(mouse_genes, masterlist, by = "ensembl_gene_id", all.x = T, all.y = T)


#masterlist[!(masterlist$ensembl_gene_id %in% mergedGenes$ensembl_gene_id),2]

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



