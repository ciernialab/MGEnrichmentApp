# Script Comments ---------------------------------------------------------
# this is a script that can be used to update/add new lists to the microglia gele list database
# The new list is then used as input into the MGEnrichment app
# simply update the spreadsheet that is read in as "masterlist"

library(biomaRt)
library(here)
library(tidyverse)

##################################################################################
# read in the current mg genelists - this is a manually curated dataset containing MG relevant genes
# every time the spreadsheet is updated, it can be reloaded here
##################################################################################
masterlist <- read.csv(here("Microglia.Mouse.GeneListDatabase.11.21.2020.csv"))[,-1]


##################################################################################
#Read in your new gene lists to add and format them with the same columns as the masterlist
#then append your new gene lists to the master list and save.
#the master list has the following columns:
#[1] "ensembl_gene_id" "mgi_symbol"      "hgnc_symbol"     "entrezgene_id"   "listname"        "description"    
#[7] "source"          "groups"          "Species"         "tissue"          "shortname" 

#if your gene list does not have all of these columsn then use biomart to help create them.
##################################################################################
#Example: 

#read in gene list from supplemental table of published paper. In this example this list is genes with increased expression
#in microglia from the cerebellum compared to the striatum
CBgreaterSTR <- read.csv("Moregenes.csv")


#select column with the ensemble gene id
CBgreaterSTR <- CBgreaterSTR %>% select(gene.id)

#use biomart to add in other gene information:
# get mouse ensemble data
mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")

# query ensemble  - this is the dataset with all mouse genes. It is also used for the background genes if all mm10 is selected in the app.
mouse_genes <- getBM(attributes = c("ensembl_gene_id","mgi_symbol", "hgnc_symbol", "entrezgene_id"),
                     mart = mouse)

#combine biormart informtion wtih gene list
ensgenes <- merge(CBgreaterSTR,mouse_genes,by.x="gene.id",by.y="ensembl_gene_id")
colnames(ensgenes)[1] <- c("ensembl_gene_id")


#add in metadata
ensgenes$listname <- c("Cerebellum > Striatum MG")  
ensgenes$description <- c("genes with higher expression in cerebellum microglia compared to stratium microglia, TRAP isolation") 
ensgenes$source <- c("Ataya, et al., 2018")   
ensgenes$groups <- c("Microglia") 
ensgenes$Species <- c("mouse") 
ensgenes$tissue <- c("microglia") 
ensgenes$shortname <- c("Cerebellum > Striatum MG") 



#append new gene list to the database and write out 
DataBasemm10 <- rbind(masterlist,ensgenes)

write.csv(DataBasemm10,file="Microglia.Mouse.GeneListDatabase.newdatehere.csv")

#--------------------------------
#make summary file of all gene counts per list
summ.files <- DataBasemm10[,c(1,5:ncol(DataBasemm10))]

summ.files <- summ.files %>% distinct() %>%
  group_by(listname,description,source,groups,Species,tissue,shortname) %>% 
  summarize(ensemble.genes = n())

write.csv(summ.files, file= "Genelists.in.mm10Database.newdatehere.csv")

masterlist <- DataBasemm10

#--------------------------------
#write out new R objects for the App. Include

# save data output (only masterlist and mouse_genes, the other 3 are generated in app)
save(mouse_genes, masterlist,
    file = here("GeneLists.RData"))



