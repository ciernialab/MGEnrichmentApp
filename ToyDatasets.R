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
##################################################################################
load("Mouse_Human_GenelistDatabase2021.RData")


##################################################################################
#Read in your new gene lists to add and format them with the same columns as the masterlist
#then append your new gene lists to the master list and save.
#the master list has the following columns:
#[1] "listname"        "ensembl_gene_id" "hgnc_symbol"     "entrezgene_id"   "source"          "description"     "groups"          "tissue"         
#[9] "Species"         "full.source"    
names(human.master3)
names(mouse.master3)



#remove duplicates in database:
human.master3 <- human.master3 %>% filter(listname != "ASD<Ctrl") %>%
  filter(listname != "ASD>Ctrl") %>%
  filter(listname != "BD<Ctrl") %>%
  filter(listname != "BD>Ctrl") %>%
  filter(listname != "SCZ<Ctrl") %>%
  filter(listname != "SCZ>Ctrl")

mouse.master3 <- mouse.master3 %>% filter(listname != "ASD<Ctrl") %>%
  filter(listname != "ASD>Ctrl") %>%
  filter(listname != "BD<Ctrl") %>%
  filter(listname != "BD>Ctrl") %>%
  filter(listname != "SCZ<Ctrl") %>%
  filter(listname != "SCZ>Ctrl")

#regenerate summaries
mouse.sum <- mouse.master3 %>% 
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#generate new summary file
human.sum <- human.master3 %>% distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

save(human.master3, mouse.master3, mouse.sum, human.sum, file="Mouse_Human_GenelistDatabaseAugust2021.RData")



##################################################################################
#Human Toy ASD datasets. 2/3 gene lists
##################################################################################

#filter for ASD>Ctrl
human.ASDup <- human.master3[grepl("ASD>Ctrl", human.master3$listname), ]

unique(human.ASDup$listname)

human.ASDup.sum <- human.ASDup %>% select(-hgnc_symbol,-entrezgene_id) %>% 
  distinct() %>%
  group_by(ensembl_gene_id) %>% 
  summarize(ensemble.genes = n())

#filter for 2/3 
human.ASDup.2.3 <- human.ASDup.sum %>% filter(ensemble.genes >= 2)  %>% select(ensembl_gene_id)
dim(human.ASDup.2.3)


#filter for ASD<Ctrl
human.ASDdown <- human.master3[grepl("ASD<Ctrl", human.master3$listname), ]

unique(human.ASDdown$listname)

human.ASDdown.sum <- human.ASDdown %>% select(-hgnc_symbol,-entrezgene_id) %>% 
  distinct() %>%
  group_by(ensembl_gene_id) %>% 
  summarize(ensemble.genes = n())

#filter for 2/3 
human.ASDdown.2.3 <- human.ASDdown.sum %>% filter(ensemble.genes >= 2) %>% select(ensembl_gene_id)
dim(human.ASDdown.2.3)


##################################################################################
#mouse Toy ASD datasets. 2/3 gene lists
##################################################################################

#filter for ASD>Ctrl
mouse.ASDup <- mouse.master3[grepl("ASD>Ctrl", mouse.master3$listname), ]

unique(mouse.ASDup$listname)

mouse.ASDup.sum <- mouse.ASDup %>% select(-mgi_symbol,-entrezgene_id) %>% 
  distinct() %>%
  group_by(ensembl_gene_id) %>% 
  summarize(ensemble.genes = n())

#filter for 2/3 
mouse.ASDup.2.3 <- mouse.ASDup.sum %>% filter(ensemble.genes >= 2)  %>% select(ensembl_gene_id)
dim(mouse.ASDup.2.3)


#filter for ASD<Ctrl
mouse.ASDdown <- mouse.master3[grepl("ASD<Ctrl", mouse.master3$listname), ]

unique(mouse.ASDdown$listname)

mouse.ASDdown.sum <- mouse.ASDdown %>% select(-mgi_symbol,-entrezgene_id) %>% 
  distinct() %>%
  group_by(ensembl_gene_id) %>% 
  summarize(ensemble.genes = n())

#filter for 2/3 
mouse.ASDdown.2.3 <- mouse.ASDdown.sum %>% filter(ensemble.genes >= 2) %>% select(ensembl_gene_id)
dim(mouse.ASDdown.2.3)



##################################################################################
#save toy datasets
##################################################################################

save(human.ASDup.2.3, human.ASDdown.2.3, mouse.ASDup.2.3, mouse.ASDdown.2.3, file="ASDvsCtrl_Human.Mouse.ToyDatasets.RData")
