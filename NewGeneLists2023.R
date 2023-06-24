# Script Comments ---------------------------------------------------------
# this is a script that can be used to update/add new lists to the microglia gele list database
# The new list is then used as input into the MGEnrichment app
# simply update the spreadsheet that is read in as "masterlist"

library(biomaRt)
library(here)
library(tidyverse)

#new lists added July 2023
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


#use biomart to add in other gene information:
# get mouse ensemble data
mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")

# query ensemble  - this is the dataset with all mouse genes. It is also used for the background genes if all mm10 is selected in the app.
mouse_genes <- getBM(attributes = c("ensembl_gene_id","mgi_symbol",  "entrezgene_id"),
                     mart = mouse)

#read in gene list from supplemental table of published papers to be added in 2023
list1 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Belhocine2022/Gosselin2022.csv")
list1 <- list1 %>% separate(GeneID, into=c("GeneID2"), sep="\\|")
colnames(list1)[1] <- c("GeneID")

list2 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Chiu2013/Table4_ALS.csv")

list3 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Dayananda2023/Dayananda.csv")

list4 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Favuzzi2021/Favuzzi2021.csv")

list5 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Hammond2019/Hammond2019.csv")

list6 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Krasemann2017/TableS1_MGDN_M0genes.csv")

list7 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Lee2023/Lee2023_mouse.csv")

list8 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Li\ 2019/Li2019.csv")

list9 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Stratoulias2023/Stratoulias2023.csv")

list10 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Wahane2021/Wahane2012.csv")

newlist <- rbind(list1, list2, list3, list4, list5,list6,list7,list8,list9,list10)

#remove white space only rows
newlist <- newlist[!(newlist$GeneID==""), ]

#combine biormart informtion wtih gene list
ensgenes <- merge(newlist,mouse_genes,by.x="GeneID",by.y="mgi_symbol")
colnames(ensgenes)[1] <- c("mgi_symbol")

#reorder columns
ensgenes <- ensgenes[,c(2,10,1,11,3:9)]
ensgenes$full.source <- paste(ensgenes$full.source, ensgenes$doi, sep = " ")
ensgenes$doi <- NULL
ensgenes$groups <- gsub("Neuropsychiatric & Neurodevelopmental Disorders human brain","Human Brain Disorders", ensgenes$groups)

#replace missing group data
ensgenes[c("groups")][is.na(ensgenes[c("groups")])] <- c("Microglia")
#ensgenes$groups <- gsub("","Microglia", ensgenes$groups)
ensgenes$groups <- replace(ensgenes$groups, ensgenes$groups=="", c("Microglia"))

#add new list to database
#remove old Krasemann, et al., 2018 list
mouse.master3 <- mouse.master3 %>% filter(source != "Krasemann, et al., 2018")

mouse.master3 <- rbind(mouse.master3,ensgenes)

#change "Neuropsychiatric & Neurodevelopmental Disorders human brain" to "Human Brain Disorders"
mouse.master3$groups <- gsub("Neuropsychiatric & Neurodevelopmental Disorders human brain","Human Brain Disorders", mouse.master3$groups)

#generate new summary file
mouse.sum <- mouse.master3 %>% dplyr::select(listname,description,source,groups,tissue,Species,full.source,ensembl_gene_id) %>%
  distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#new datasets
mouse.new <- ensgenes %>% dplyr::select(listname,description,source,groups,tissue,Species,full.source,ensembl_gene_id) %>%
  distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#save to Rdata file with new date
save(mouse.master3, mouse.sum,file="Microglia.Mouse.GeneListDatabase.July2023.Rdata")
write.csv(mouse.new,"July2023.newmousedatasets.csv")

##################################################################################
#Example: adding a new mouse gene list to the human database:
##################################################################################
#to add the mouse gene list we just made to the human database we need to convert the mouse gene ids to human gene ids using biomart
human = useMart("ensembl", dataset = "hsapiens_gene_ensembl")

#converte the ensembl gene ids in ensgenes to human
human_genes = getBM(attributes = c("ensembl_gene_id","hgnc_symbol",  "entrezgene_id"),
                    mart = human)
  
#  getLDS(attributes = c("ensembl_gene_id"), filters = "ensembl_gene_id", 
   #            values = ensgenes$ensembl_gene_id,mart = mouse, attributesL = c("ensembl_gene_id","hgnc_symbol", "entrezgene_id"), martL = human, uniqueRows=T)

#read in human gene lists
humanlist1 <- read.csv("/Users/aciernia/Sync/CierniaLabMembers/AnnieCiernia/Experiments/IMM/tissueRNAseq/GeneListEnrichments/new\ gene\ lists/Lee2023/Lee2023_human.csv")

#remove white space only rows
humanlist1 <- humanlist1[!(humanlist1$GeneID==""), ]


#merge in human data
tmp <- merge(humanlist1,human_genes,by.x="GeneID", by.y="hgnc_symbol")
tmp$full.source <- paste(tmp$full.source, tmp$doi, sep= " ")
colnames(tmp)[1] <- c("hgnc_symbol")
  
#fix columns to match database
tmp <- tmp[,c(2,10,1,11,3:8)]

#add new list to database
human.master3 <- rbind(human.master3,tmp)

#change "Neuropsychiatric & Neurodevelopmental Disorders human brain" to "Human Brain Disorders"
human.master3$groups <- gsub("Neuropsychiatric & Neurodevelopmental Disorders human brain","Human Brain Disorders", human.master3$groups)

#generate new summary file
human.sum <- human.master3 %>% dplyr::select(listname,description,source,groups,tissue,Species,full.source,ensembl_gene_id) %>%
  distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#new added human lists
human.newlists <- tmp %>% dplyr::select(listname,description,source,groups,tissue,Species,full.source,ensembl_gene_id) %>%
  distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#save to Rdata file with new date
save(human.master3, human.sum,file="Microglia.Human.GeneListDatabase.July2023.Rdata")
write.csv(human.newlists,"newhumanlists.july2023.csv")



##################################################################################
#to add a new human gene list to  mouse database and mouse gene list to human database
##################################################################################
#to add the mouse gene list we just made to the human database we need to convert the mouse gene ids to human gene ids using biomart
#human = useEnsembl("ensembl", dataset = "hsapiens_gene_ensembl" ,mirror = "asia")
#mouse = useEnsembl("ensembl", dataset = "mmusculus_gene_ensembl",mirror = "asia")

#converte the ensembl gene ids in ensgenes to human
#genes = getLDS(attributes = c("ensembl_gene_id"), filters = "ensembl_gene_id", 
#               values = ensgenes$ensembl_gene_id,mart = mouse, attributesL = c("ensembl_gene_id","hgnc_symbol", "entrezgene_id"), martL = human, uniqueRows=T)



# CDB <- read.csv("All_ensemble_mm10_and_hg38genes.csv")
# 
# CDBt <- CDB %>% dplyr::select(MGI.symbol,HGNC.symbol)
# 
# CDB2.1 <- merge(CDBt, human_genes, by.x="HGNC.symbol", by.y= "hgnc_symbol")
# CDB2.1 <- distinct(CDB2.1)
# #remove white space only rows
# CDB2.1 <- CDB2.1[!(CDB2.1$HGNC.symbol==""), ]
# 
# #mouse to human
# MstoHu <- CDB2.1
# 
# MstoHu <- MstoHu[,c(2,1,3,4)]
# #Mouse to human
# CDB3 <- merge(CDBt, mouse_genes, by.x="MGI.symbol", by.y= "mgi_symbol")
# 
# CDB3.1 <- distinct(CDB3)
#remove white space only rows
#CDB3.1 <- CDB3.1[!(CDB3.1$MGI.symbol==""), ]

# #human to mouse
# HutoMs <- CDB3.1
# MstoHu <- HutoMs[,c(2,1,3,4)]

#Save

#save(MstoHu, HutoMs, file="Human_Mouse_database.RData")
load("Human_Mouse_database.RData")

#add the human gene listto the mouse database 
#we need to convert the human gene ids to mouse gene ids 
tmp_genes <- merge(tmp,HutoMs, by.x= "hgnc_symbol", by.y="HGNC.symbol") 
newMs_from_human <- tmp_genes[,c(2,12,11,13,5:10)]
colnames(newMs_from_human)[2:4] <- c("ensembl_gene_id","mgi_symbol",  "entrezgene_id")
newMs_from_human$Species <- c("human")
  
#add in new human (now mouse) to mouse master
mouse.master3 <- rbind(mouse.master3,newMs_from_human)

#add the mouse gene list to the human database 
#we need to convert the mouse gene ids to human gene ids 
tmp_genes <- merge(ensgenes,MstoHu, by.x= "mgi_symbol", by.y="MGI.symbol") 
newHu_from_mouse <- tmp_genes[,c(2,12,11,13,5:10)]
colnames(newHu_from_mouse)[2:4] <- c("ensembl_gene_id","hgnc_symbol",  "entrezgene_id")


#add new mouse (now human) to human master
human.master3 <- rbind(human.master3,newHu_from_mouse)


#regenerate new summary files
mouse.sum <- mouse.master3 %>% select(listname,description,source,groups,tissue,Species,full.source,ensembl_gene_id) %>%
  distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#regenerate new summary file
human.sum <- human.master3 %>% dplyr::select(listname,description,source,groups,tissue,Species,full.source,ensembl_gene_id) %>%
  distinct() %>%
  group_by(listname,description,source,groups,tissue,Species,full.source) %>% 
  summarize(ensemble.genes = n())

#check all mouse gene lists are in human db =0
mouse.sum$listname[!(mouse.sum$listname %in% human.sum$listname)]

#check all human gene lists are in mouse db = 0
human.sum$listname[!(mouse.sum$listname %in% human.sum$listname)]

#save to Rdata file with new date
save(human.master3, human.sum,file="Microglia.Human.GeneListDatabase.July2023.Rdata")
save(mouse.master3, mouse.sum,file="Microglia.Mouse.GeneListDatabase.July2023.Rdata")


##################################################################################
#save full mouse and human database for the application
#mouse.master3 = mouse database
#human.master3 =  human database
#mouse.sum = mouse summary (no gene ids)
#human.sum = human summary (no gene ids)
#mouse_genes = all genes in mm10
#human_genes = all human genes in Hg38
##################################################################################
write.csv(mouse.sum,"MouseMasterSummary.final.csv")
write.csv(human.sum,"HumanMasterSummary.final.csv")

save(mouse.master3, mouse.sum, mouse_genes, human.master3, human.sum, human_genes, file="Mouse_Human_GenelistDatabaseJuly2023.RData")

