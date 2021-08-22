# Script Comments ---------------------------------------------------------
# this is a script that can be used to update/add new lists to the microglia gele list database
# The new list is then used as input into the MGEnrichment app
# simply update the spreadsheet that is read in as "masterlist"

library(biomaRt)
library(here)
library(tidyverse)

##################################################################################
# read in the current mg genelists - this is a manually curated dataset containing MG relevant genes
# loading R object should load the mouse and human databases and the summary files
#mouse.master3 = mouse database
#human.master3 =  human database
#mouse.sum = mouse summary (no gene ids)
#human.sum = human summary (no gene ids)
#mouse_genes = all genes in mm10
#human_genes = all human genes in Hg38
##################################################################################
load("Mouse_Human_GenelistDatabaseAugust2021.RData")


##################################################################################
#Read in your new gene lists to add and format them with the same columns as the masterlist
#then append your new gene lists to the master list and save.
#the master list has the following columns:
#[1] "listname"        "ensembl_gene_id" "hgnc_symbol"     "entrezgene_id"   "source"          "description"     "groups"          "tissue"         
#[9] "Species"         "full.source"    
names(human.master3)

#if your gene list does not have all of these columsn then use biomart to help create them.
##################################################################################
#Example: adding a new mouse gene list to the mouse database:
##################################################################################

#read in gene list from supplemental table of published paper. In this example this list is genes with increased expression
#in microglia from the cerebellum compared to the striatum in mouse
CBgreaterSTR <- read.csv("MoreMousegenes.csv")

#select column with the ensemble gene id
CBgreaterSTR <- CBgreaterSTR %>% select(gene.id)

#use biomart to add in other gene information:
# get mouse ensemble data
mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")

# query ensemble  - this is the dataset with all mouse genes. It is also used for the background genes if all mm10 is selected in the app.
mouse_genes <- getBM(attributes = c("ensembl_gene_id","mgi_symbol",  "entrezgene_id"),
                     mart = mouse)

#combine biormart informtion wtih gene list
ensgenes <- merge(CBgreaterSTR,mouse_genes,by.x="gene.id",by.y="ensembl_gene_id")
colnames(ensgenes)[1] <- c("ensembl_gene_id")


#add in metadata
ensgenes$listname <- c("Cerebellum > Striatum MG")  
ensgenes$description <- c("genes with higher expression in cerebellum microglia compared to stratium microglia, TRAP isolation") 
ensgenes$source <- c("Ataya, et al., 2018")   
ensgenes$groups <- c("Microglia") 
ensgenes$tissue <- c("microglia") 
ensgenes$Species <- c("mouse") 
ensgenes$full.source <- c("Ayata P, Badimon A, Strasburger HJ, et al. Epigenetic regulation of brain region-specific microglia clearance activity. Nat Neurosci. 2018;21(8):1049-1060. doi:10.1038/s41593-018-0192-3") 

#add new list to database
mouse.master3 <- rbind(mouse.master3,ensgenes)

#generate new summary file
mouse.sum <- mouse.master3 %>% distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#save to Rdata file with new date
save(mouse.master3, mouse.sum,file="Microglia.Mouse.GeneListDatabase.newdatehere.Rdata")


##################################################################################
#Example: adding a new mouse gene list to the human database:
##################################################################################
#to add the mouse gene list we just made to the human database we need to convert the mouse gene ids to human gene ids using biomart
human = useMart("ensembl", dataset = "hsapiens_gene_ensembl")

#converte the ensembl gene ids in ensgenes to human
genes = getLDS(attributes = c("ensembl_gene_id"), filters = "ensembl_gene_id", 
               values = ensgenes$ensembl_gene_id,mart = mouse, attributesL = c("ensembl_gene_id","hgnc_symbol", "entrezgene_id"), martL = human, uniqueRows=T)

#merge in human data
tmp <- merge(ensgenes,genes,by.x="ensembl_gene_id", by.y="Gene.stable.ID", all=T)

#fix columns to match database
tmp <- tmp[,c(4,11:13,5:10)]
colnames(tmp)[2:4] <- c("ensembl_gene_id", "hgnc_symbol" ,    "entrezgene_id" )

#add new list to database
human.master3 <- rbind(human.master3,tmp)

#generate new summary file
human.sum <-human.master3 %>% distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#save to Rdata file with new date
save(human,master3, human.sum,file="Microglia.Human.GeneListDatabase.newdatehere.Rdata")


##################################################################################
#to add a new human gene list to the human database
##################################################################################

#read in gene list from supplemental table of published paper. In this example this list is genes with differential expression in microglia 
#between ASD and control samples from human postmortem brain single cell RNAseq
ASDMG <- read.csv("MoreHumangenes.csv")


#use biomart to add in other gene information:
human = useMart("ensembl", dataset = "hsapiens_gene_ensembl")

# query ensemble  - this is the dataset with all human genes. It is also used for the background genes if all hg38 is selected in the app.
human_genes <- getBM(attributes = c("ensembl_gene_id","hgnc_symbol",  "entrezgene_id"),
                     mart = human)

#combine biormart informtion wtih gene list
ensgenes <- merge(ASDMG,human_genes,by.x="gene.ID",by.y="ensembl_gene_id")
colnames(ensgenes)[1] <- c("ensembl_gene_id")


#add in metadata
ensgenes$listname <- c("ASD vs CTRL MG DEGS")  
ensgenes$description <- c("DEGs with different expression in ASD microglia vs. CTRL Microglia from human cortex") 
ensgenes$source <- c("Velmeshev et al., 2019")   
ensgenes$groups <- c("Microglia") 
ensgenes$tissue <- c("microglia") 
ensgenes$Species <- c("human") 
ensgenes$full.source <- c("Velmeshev D, Schirmer L, Jung D, et al. Single-cell genomics identifies cell type-specific molecular changes in autism. Science. 2019;364(6441):685-689. doi:10.1126/science.aav8130")

#select relevant columsn to match database
names(human.master3)
ensgenes <- ensgenes[,c(11,1,9,10,13,12,14:17)]


#add new list to database
human.master3 <- rbind(human.master3,ensgenes)

#generate new summary file
human.sum <- human.master3 %>% distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#save to Rdata file with new date
save(human.master3, human.sum,file="Microglia.Human.GeneListDatabase.newdatehere.Rdata")


##################################################################################
#to add a new human gene list to  mouse database
##################################################################################
#to add the human gene list we just made to the mouse database we need to convert the human gene ids to mouse gene ids using biomart
mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")


#converte the ensembl gene ids in ensgenes to human
genes = getLDS(attributes = c("ensembl_gene_id"), filters = "ensembl_gene_id", 
               values = ensgenes$ensembl_gene_id,mart = human, attributesL = c("ensembl_gene_id","mgi_symbol", "entrezgene_id"), martL = mouse, uniqueRows=T)

#merge in mouse data
tmp <- merge(ensgenes,genes,by.x="ensembl_gene_id", by.y="Gene.stable.ID", all=T)

#fix columns to match database
names(mouse.master3)
tmp <- tmp[,c(2,1,12,13,5:10)]
colnames(tmp)[2:4] <- c("ensembl_gene_id", "mgi_symbol" ,    "entrezgene_id" )

#add new list to database
mouse.master3 <- rbind(mouse.master3,tmp)

#generate new summary file
mouse.sum <- mouse.master3 %>% distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#save to Rdata file with new date
save(mouse.master3, mouse.sum,file="Microglia.Mouse.GeneListDatabase.newdatehere.Rdata")


##################################################################################
#save full mouse and human database for the application
#mouse.master3 = mouse database
#human.master3 =  human database
#mouse.sum = mouse summary (no gene ids)
#human.sum = human summary (no gene ids)
#mouse_genes = all genes in mm10
#human_genes = all human genes in Hg38
##################################################################################

save(mouse.master3, mouse.sum, mouse_genes, human.master3, human.sum, human_genes, file="Mouse_Human_GenelistDatabaseAugust2021.RData")

