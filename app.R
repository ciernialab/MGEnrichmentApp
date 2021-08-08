# App Description & Comments ----------------------------------------------
# Microglia Enrichment Calculator
# this Shiny app takes in a set of Gene IDs, and runs a enrichment analysis
# (i.e. fisher's exact test) based on the database of microglia-relevant genes
# The database loads data previously generated from another script (NewGeneLists.R)
# so that the only thing described here is the app itself

# If needed, the RStudio Shiny tutorial may be useful in understanding
# how this app was designed:
# https://shiny.rstudio.com/tutorial/

# Load Datasets & Packages ------------------------------------------------

library(shiny)
library(here)
library(tidyverse)
library(GeneOverlap)
library(vroom)
library(DT)
library(shinydashboard)
library(BiocManager)
library(readxl)
options(repos = BiocManager::repositories())
getOption("repos")

#If needed, the datasets can be regenerated using the NewGeneLists.R script

# there are 5 key datasets used in this script
# mouse_genes - contains all the mouse genes
# masterlist - contains all the MG-relevant genes, and their corresponding gene IDs
# ensemblList, entrezList, mgiList - (the MG-relevant genes sorted into gene lists) for each respective gene ID. These are generated in the app

#load in datasets from here:
load(file="GeneLists.RData")

#toydataset with ASD>Ctrl genes and ASD<Ctrl genes:
toyDatasetUp <- read_xlsx(here("Toy_Dataset_Input_and_Output.xlsx"), 
                          sheet = "ASD>CTRL_DEGs_Dataset")
toyDatasetDown <- read_xlsx(here("Toy_Dataset_Input_and_Output.xlsx"), 
                            sheet = "ASD<CTRL_DEGs_Dataset")

#masterlist <- dplyr::select(masterlist, -entrezgene_id, -mgi_symbol, -hgnc_symbol)


# Designing User Interface ---------------------------------------------------------------
# this section describes all the graphical user interface of the app

# load HTML for Help page
source("Help_HTML.R")

ui <- dashboardPage(
    
    
    # Application title
    dashboardHeader(title = "Microglia Gene List Enrichment Calculator", titleWidth = 430),
    
    # Sidebar Layout
    # this contains all the UI for the sidebar
    # the different elements are self-explanatory
    dashboardSidebar(width = 430,
                     tags$style(".skin-blue .sidebar a { color: #444; }"),
                     textAreaInput("txtGeneID", label = "Input your genes of 
                          interest here (must all be the same gene ID format)",
                                   placeholder = "CxCl2, 344521, ENSMUSG00000000202,..."),
                     fileInput("fileGeneID", "or upload your gene list here (or try out our sample datasets below)", accept = c(".csv", ".tsv", ".txt")),
                     strong("Click here for Sample Datasets from Human ASD Brain:"),
                     div(style="display: inline-block;vertical-align:left; height: 20px; width: 120px;",actionButton("upregToy", "ASD>Ctrl DEGs")),
                     div(style="display: inline-block;vertical-align:left; height:20px; width: 120px;",actionButton("downregToy", label = "ASD<Ctrl DEGs")),
                     br(),
                     radioButtons("typeID", "Which gene ID are you using?",
                                  choices = c("Ensembl" = "ensembl_gene_id",
                                              "Entrez" = "entrezgene_id",
                                              "MGI Symbol" = "mgi_symbol")),
                     checkboxGroupInput("groupFilterID", "Which gene list groups are you interested in?", inline = TRUE,
                                        choiceNames = unique(masterlist$groups),
                                        choiceValues = unique(masterlist$groups),
                                        selected = c("Microglia", "Microglia Development", "inflammation")),
                     radioButtons("background", "Set the background query:",
                                  choices = c("All mm10 Genes" = "reference",
                                              "All Genes in the Database" = "intersection",
                                              "Custom" = "custom")),
                     
                     # conditionalPanel uses a javascript expression to only display the background gene
                     # upload inputs when "custom" is selected in the previous radioButton selection
                     conditionalPanel(condition = "input.background == 'custom'",
                                      textAreaInput("txtBackgroundID", label = "Input your background genes of interest here",
                                                    placeholder = "CxCl2, 344521, ENSMUSG00000000202,..."),
                                      fileInput("fileBackgroundID", "or upload your background list here", accept = c(".csv", ".tsv", ".txt"))),
                     checkboxGroupInput("displayID", "Disable Intersection Gene IDs?", inline = TRUE,
                                        choiceNames = c("Intersection IDs","Ensembl", "MGI Symbol", "Entrez"),
                                        choiceValues = c("intersection_IDs", "intersection_ensembl", "intersection_mgi_symbol", "intersection_entrez"), 
                                        selected = NULL),
                     sliderInput("pval", "Change Minimum FDR-value (1.0 means no filtering):", min = 0.01, max = 1.00, value = 0.05, step = 0.01),
                     div(style="display: inline-block;vertical-align:left; height:120px; width: 120px;",actionButton("searchGene", label = "Query Genes")),
                     div(style="display: inline-block;vertical-align:left; height: 120px; width: 120px;",downloadButton("dwnld", "Download Results"))
    ),
    
    
    # displays everything in the center of the page (i.e. the table of results)
    dashboardBody(
        
        
        tabsetPanel(type = "tabs",
                    tabPanel("Table",  DT::dataTableOutput("enrichmentTable")),
                    tabPanel("Help", displayHelp)),
        
        div(style = 'overflow-x: scroll', DT::dataTableOutput('tbl')),
        
        tags$head(tags$style(HTML('
       
       .skin-blue .main-header .logo {
                              background-color: #407f87
                              }
                              .skin-blue .main-header .logo:hover {
                              background-color: #407f87;
                              }

        /* navbar (rest of the header) */
        .skin-blue .main-header .navbar {
                              background-color:#4c969f;
                              }        

        /* main sidebar */
        .skin-blue .main-sidebar {
                              background-color: #253538;
                              }

        /* toggle button when hovered  */                    
         .skin-blue .main-header .navbar .sidebar-toggle:hover{
                              background-color:#4c969f;
                              }
                              ')))
        
        # outputs the entered gene IDs into the console when the app is run
        # can be enabled when needed as useful for troubleshooting any issues with IDs
        # textOutput("geneText")
        
    ) 
)

# Server Functions --------------------------------------------------------
# this section describes all the data underlying how the database is built

# the tutorial on reactivity may be useful in understanding this section:
# https://shiny.rstudio.com/tutorial/written-tutorial/lesson6/

server <- function(input, output, session) {
    # the downregPaste/upregPaste extracts the genes from the xlsx file and pastes it into
    # the textbox for user. The observeEvent function monitors the Toy dataset
    # buttons, and if either is clicked, it calls the corresponding function
    downregPaste <- reactive(
        updateTextInput(session, "txtGeneID", value = toString(paste(unlist(toyDatasetDown)))))
    observeEvent(input$downregToy, downregPaste())
    
    upregPaste <- reactive(
        updateTextInput(session, "txtGeneID", value = toString(paste(unlist(toyDatasetUp)))))
    observeEvent(input$upregToy, upregPaste())

    
    
    # Switch List Function
    # switch function is used to change which list is used, depending on user input
    # https://www.datamentor.io/r-programming/switch-function/
    # input: typeID (user input)
    # output: character (either "ensembl_gene_id", "mgi_symbol", etc)
    # the character output is then used in later functions to determine which ID to use
    switchList <- reactive({
        switch(input$typeID, 
               ensembl_gene_id = "ensembl_gene_id",
               entrezgene_id = "entrezgene_id",
               mgi_symbol = "mgi_symbol")
    })
    
    
    
    # Overlap Function --------------------------------------------------------
    
    # this is the overlap function used to run the analysis
    # targetlist name is the gene list uploaded by user
    # genelists = Lists is the database of MG genes we currently are using
    # genomesize is the size of the list of genes used (which varies based on gene ID type)
    
    Overlap_fxn <- function(targetlistname,genelists = List,genomesize){
        
        #eventual output
        out <- NULL
        
        #rename for ease of use
        target <- targetlistname  
        
        # loops through each gene list in List and generates overlap results
        for (i in 1:length(genelists)) { 
            
            #call gene overlaps
            go.obj <- newGeneOverlap(target,
                                     genelists[[i]],
                                     genome.size=genomesize)
            
            #perform stattistical tests
            go.obj <- testGeneOverlap(go.obj) # returns onetailed pvalue
            #return odds ratio:
            OR <- getOddsRatio(go.obj)
            pvalue <- getPval(go.obj)
            
            #extract contingency table
            CT <- getContbl(go.obj)
            notAnotB <- CT[1,1]
            inAnotB <- CT[1,2]
            inBnotA <- CT[2,1]
            inBinA <- CT[2,2]
            
            #merges results to a table
            CTlist <- cbind(notAnotB,inAnotB,inBnotA,inBinA)
            
            #get list of intersections - this will get different ids based on user input.
            intersection <- go.obj@intersection
            intersection_IDs <- paste(as.character(intersection),collapse=", ",sep="")
            
            # switchList is used to determine which column to pull from the original
            # mouse_genes dataframe for the next few lines of code
            # e.g. if user uploaded entrez IDs, it will pull the overlapping 
            # entrez ID rows in the mouse_genes entrez ID column,
            # then it will look to see if there is a corresponding match of other IDs in the same row
            
            # get Ensembl IDs
            intersection_ensembl <- mouse_genes$ensembl_gene_id[which(pull(mouse_genes, switchList()) %in% intersection)]
            intersection_ensembl <- paste(as.character(intersection_ensembl),collapse=", ",sep="")
            
            #get intersection gene names
            intersection_mgi_symbol <- mouse_genes$mgi_symbol[which(pull(mouse_genes, switchList()) %in% intersection)]
            intersection_mgi_symbol <- paste(as.character(intersection_mgi_symbol),collapse=", ",sep="")
            
            # get entrez IDs
            intersection_entrez <- mouse_genes$entrezgene_id[which(pull(mouse_genes, switchList()) %in% intersection)]
            intersection_entrez <- paste(as.character(intersection_entrez), collapse = ", ", sep ="")
            
            #get listname
            listname <- paste(names(genelists[i]))
            
            #combine results
            results <- cbind(listname,pvalue,OR, CTlist,intersection_IDs, intersection_ensembl,intersection_mgi_symbol, intersection_entrez)
            
            #colnames(results) <- c("listname","pvalue","OR","notAnotB","inAnotB","inBnotA","inBinA","intersection_IDs", "ensembl","MGI", "entrez")
            
            # bind to output
            out <- rbind(out,results) 
        }
        
        #cast to dataframe
        out <- as.data.frame(out)
        
        #cast to numeric (necessary for the sorting feature in the application)
        out$OR <- as.numeric(out$OR)
        out$notAnotB <- as.numeric(out$notAnotB)
        out$inAnotB <- as.numeric(out$inAnotB)
        out$inBnotA <- as.numeric(out$inBnotA)
        out$inBinA <- as.numeric(out$inBinA)
        
        rownames(out) <- NULL
        
        #return results
        return(out)
    }
    
    
    # Running Analysis --------------------------------------------------------
    # The giant reactive function called to calculate results.
    # Could benefit from splitting into smaller helper functions...
    result_calculation <- reactive({
        
        
        # Filter Masterlist by User-Specified Groups ------------------------------
        
        #filterMasterlist <- reactive({
        
        #list of groups that the user wants
        groupsToFilter <- input$groupFilterID
        
        #creates new filtered masterlist based on criteria
        masterlistFiltered <- filter(masterlist, masterlist$groups %in% groupsToFilter)
        
        #mergedGenes <- merge(mouse_genes, masterlist, by = "ensembl_gene_id", all.x = T, all.y = T)
        #assume no need to merge as masterlist will always have the 4 IDs already
        #so deleting for now, but leaving in case this changes in the future
        
        # generate ensembl list
        ensemblList <- split(masterlistFiltered$ensembl_gene_id, masterlistFiltered$listname) %>% 
            sapply(na.omit) %>% 
            sapply(unique)
        
        
        # generate entrez list
        entrezList <- split(masterlistFiltered$entrezgene_id, masterlistFiltered$listname) %>% 
            sapply(na.omit) %>% 
            sapply(unique) 
        
        # generate MGI list
        mgiList <- split(masterlistFiltered$mgi_symbol, masterlistFiltered$listname) %>% 
            sapply(na.omit) %>% 
            sapply(unique)
        
        
        #initializes default mm10 values
        mm10genome <- length(unique(mouse_genes$mgi_symbol))
        mm10genes <- length(unique(masterlistFiltered$ensembl_gene_id))
        
        
        #})
        
        
        
        # Reading in User Input & Matching Lists ---------------------
        # here we define the functions used to interpret user input, and to determine
        # which corresponding type of list (ensembl, entrez, etc) to use
        
        #function which reads the file the user uploads
        geneQueryFile <- reactive({
            
            #when a user uploads a file to the app, the file is given a temporary directory
            #which can be accessed by input$fileGeneID$datapath
            #input$fileGeneID$name can be used to access the file type
            
            #get file type
            ext <- tools::file_ext(input$fileGeneID$name)
            
            #switch is used to determine which read function to use based on filetype
            upldFile <- switch(ext,
                               csv = read.csv(input$fileGeneID$datapath, sep = ",", stringsAsFactors = FALSE),
                               tsv = read_tsv(input$fileGeneID$datapath),
                               txt = read.delim(input$fileGeneID$datapath, sep = "\t", stringsAsFactors = FALSE))
            
            #ensure only one column is read in
            upldFile <- upldFile[,1]
            return(upldFile)
        })
        
        #reads in textbox details. When text is entered, it is registered as one giant string
        #this uses a regex to parse the string (either by comma, space or a new line)
        #and then unlists it (since strsplit outputs a string type)
        geneQueryTxt <- reactive(unlist(strsplit(input$txtGeneID, split = "[, \n]+")))
        
        #if statement to decide whether to use file or textbox input.
        #  Uses textbox input only when file input is null.
        geneQueryDecide <- if (is.null(input$fileGeneID)) {
            geneQueryTxt()
        } else {
            geneQueryFile()
        }
        
        #switch is used to determine which gene List in our database to use,
        # based on the gene ID type specified by the user
        matchList <- if (switchList() == "ensembl_gene_id") {
            List <- ensemblList
        } else if (switchList() == "mgi_symbol") {
            List <- mgiList
        } else {
            List <- entrezList
        }
        
        #switch is used to determine which mm10genome size to use based on which
        # gene ID type is specified by the user. The size varies by gene ID type
        matchMm10Genome <- if (switchList() == "ensembl_gene_id"){
            mm10genome <- length(unique(mouse_genes$ensembl_gene_id))
        } else if (switchList() == "entrezgene_id") {
            mm10genome <- length(unique(mouse_genes$entrezgene_id))
        } else if (switchList() == "mgi_symbol") {
            mm10genome <- length(unique(mouse_genes$mgi_symbol))
        }
        
        #switch is used to determine which mm10gene to use
        matchMm10Genes <- if (switchList() == "ensembl_gene_id"){
            mm10genes <- length(unique(unlist(ensemblList)))
        } else if (switchList() == "entrezgene_id") {
            mm10genes <- length(unique(unlist(entrezList)))
        } else if (switchList() == "mgi_symbol") {
            mm10genes <- length(unique(unlist(mgiList)))
        }
        
        # Reading Custom Uploaded Background Lists -----------
        
        #similar to the user uploaded gene list functions above.
        backgroundQueryFile <- reactive({
            
            ext <- tools::file_ext(input$fileBackgroundID$name)
            upldFile <- switch(ext,
                               csv = read.csv(input$fileBackgroundID$datapath, sep = ",", stringsAsFactors = FALSE),
                               tsv = read_tsv(input$fileBackgroundID$datapath),
                               txt = read.delim(input$fileBackgroundID$datapath, sep = "\t", stringsAsFactors = FALSE))
            
            upldFile <- upldFile[,1]
            return(upldFile)
        })
        
        backgroundQueryTxt <- reactive(unlist(strsplit(input$txtBackgroundID, split = "[, \n]+")))
        
        backgroundQueryDecide <- if (is.null(input$fileBackgroundID)) {
            backgroundQueryTxt()
        } else {
            backgroundQueryFile()
        }
        #browser()
        #counts number of entries in uploaded background list, 
        #to be used in genomesize of overlap function
        backgroundQuerySize <- length(unique(backgroundQueryDecide))
        
        # Calculating Results -----------------------------------------------------
        # the code for actually running the functions
        
        #run overlap function
        results <- Overlap_fxn(targetlistname = unique(geneQueryDecide), genelists = List,
                               genomesize = switch(input$background,
                                                   "reference" = mm10genome,
                                                   "intersection" = mm10genes,
                                                   "custom" = backgroundQuerySize))
        
        #adjust pvalue
        results$pvalue <- as.numeric(formatC(x = as.numeric(as.character(results$pvalue)), format = "E"))
        #calculate FDR adjusted p-value (this column is later dropped)
        results$FDRdrop <- p.adjust(results$pvalue, method='fdr')
        
        #formats FDR value to scientific notation (for some reason, the reformatting only displayed
        # if I reformatted on a second column, which is why I drop the previous column)
        results$FDR <- as.numeric(formatC(x = as.numeric(results$FDRdrop), format = "E"))
        
        #gets gene list information
        geneListInfo <- masterlistFiltered %>%
            dplyr::select(-ensembl_gene_id, -mgi_symbol, -hgnc_symbol, -entrezgene_id) %>% 
            distinct()
        
        #change one of the gene list names to be correct
        #p$description[91] <- "differential gene expression polyI:C MIA on GD14, whole brain microglia P0"
        
        #merge the result dataframe and list information dataframe together
        merged_results <- merge(results, geneListInfo, by=c("listname"), all.x=T)
        merged_results <- unique(merged_results)
        
        #this filters the dataframe to remove any values <= user input p value
        merged_results <- merged_results %>% 
            filter(FDRdrop <= input$pval) %>% 
            #drops the dummy FDR column
            dplyr::select(-FDRdrop) %>% 
            relocate(FDR, .after = pvalue)
        return(merged_results)
    })
    
    # Displaying Output -------------------------------------------------------
    
    # removes the intersection IDs specified by user
    remove_ids <- reactive(dplyr::select(result_calculation(), -input$displayID))
    
    # eventReactive delays any querying until you click "Query Gene", since
    # if we have a lot of genes this could be a hassle if every change of a setting
    # caused a recalculation of results
    run_calc <- eventReactive(input$searchGene, remove_ids())
    
    #renders the table
    output$enrichmentTable <- DT::renderDataTable(datatable(run_calc(), options = list("lengthMenu"=c(10, 25, 50, 100, 200), "scrollX" = TRUE, "order" = list(list(3, "asc"))))) #%>% 
    #formatStyle("intersection", lineHeight='80%'))
    
    # Download Results --------------------------------------------------------
    
    #download results
    output$dwnld <- downloadHandler(
        filename = function() {
            "MG_Enrichment_Results.csv"
        },
        content = function(file) {
            write.csv(remove_ids(), file)
        }
    )
}

#function to run the whole app
shinyApp(ui, server)