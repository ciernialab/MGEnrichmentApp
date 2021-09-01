displayHelp <- HTML('
<p style="font-size:30px">
<b>Welcome to the Ciernia Lab Microglia Enrichment Calculator!</b>
</p>

<p style="font-size:20px">
Here we provide a short guide to using the app. For more detailed documentation, please visit the <u><a href="https://github.com/ciernialab/MGEnrichmentApp">GitHub repository</a>.</u>
</p>
<br>
<br>
<p>
The calculator is quite simple; the user uploads the gene lists they want to test for enrichment. 
The app then runs what is essentially a one-tailed Fishers Exact Test with the user\'s uploaded 
genes for every gene list in the database (against a specified "background 
universe" of genes). If the user\'s uploaded genes have a significant overlap with any particular 
gene list, the gene list is said to be highly represented, or "enriched." Depending on the particular 
gene list that is enriched, this could have important implications for the user\'s gene list.
</p>
<p style="text-align:center;"><img src="venn_diagram.png" style="width:800px;height:400;"> </p>

<h3 style = "font-size: 20px;font-weight: bold"> Tips For Using the App </h3>
<br>
<h5 style = "font-weight: bold">Switching Database Species</h5>
<ul>
<li>Selecting "Mouse" or "Human" switches the gene IDs the database uses, so that users can upload gene IDs for each species.</li>
<li>Switching between the 2 species automatically switches the sample gene IDs that can be loaded by the toy dataset buttons.</li>
</ul>
<h5 style = "font-weight: bold">Uploading Gene lists</h5>
<ul>
<li>The app can take in a gene list via text input in the textbox, or by uploading a dataset (acceptable file formats are csv, tsv and txt, and files should only have one column containing the genes, with no header).</li>
<li>The app can take in Ensembl, Entrez and gene symbol (MGI or HGNC) IDs, but can only parse one type at a time, so all gene IDs need to follow the same ID type, and you must correctly specify which ID type you are using for the matching to work properly.</li>
<li>If possible, it is recommended to use Ensembl IDs, as this is what was originally used to compile our gene lists</li>
<li> If you are pasting in IDs, they can be separated by tabs, spaces or commas.</li>
</ul>

<h5 style = "font-weight: bold">Filtering Genes by Groups</h5>
<ul>
<li>The genes in the database fall into several categories. By default they are all selected, but you can remove genes in certain groups from the database by deselecting them in the checkboxes if they are not of interest.</li>
<li><i>Note that this will affect the number of genes used in the database, and if you are using the "All Genes in the Database" option for the background gene list, this will affect enrichment calculations. </i></li>
</ul>

<h5 style = "font-weight: bold">Selecting Background Gene List</h5>
<ul>
<li>You can either set the background number of genes to be all species genes <i>(All mm10 or hg38 Genes)</i>, or all the genes currently in the database <i>(All Genes in the Database)</i>.</li>
<li> You can also upload a custom list by selecting <i>Custom</i>.</li>
</ul>

<h5 style = "font-weight: bold">Uploading Background Gene Lists</h5>
<ul>
<li>Any custom uploaded background gene lists must be large enough to serve as a background gene list (it should be larger than the largest gene list in the database (7266 genes) + your user uploaded gene list). See <u><a href="https://github.com/ciernialab/MGEnrichmentApp">online documentation</a></u> for more information.</li>
<li>Format for the custom background list follows the user-uploaded gene list format of one column only, with no header.</li>

</ul>
<h5 style = "font-weight: bold">Filtering & Disabling IDs</h5>

<ul>
<li>The p-value slider can be used to filter your results for FDR significance level. </li>
<li>The checkbox options can be used to remove the specified columns from the output, which may be useful if your gene list is very long.
</ul>

<h5 style = "font-weight: bold">Querying Genes</h5>

<ul>
<li>Once you’re done toggling the various settings, you can click <b>Query Genes</b>, and the app will generate the resulting enrichment table,</li>
<li> Results are only generated when the <b>Query Genes</b> button is clicked. If you make any further setting changes after generating results, recalculations will only come into effect when you click the button again to regenerate results.</li>
</ul>

<h5 style = "font-weight: bold">Downloading Results</h5>
<ul>

<li>Click the "Download Results" button to export your results to a csv file.</li>

<li>Note that the results download as is (whatever filtering settings you\'ve used carry over - what you see is what you get).</li>
</ul>

<h5 style = "font-weight: bold">Toy Datasets</h5>
<ul>
<li>There are two toy datasets available to try out the enrichment analysis. Both contain differentially expressed genes from several papers comparing human brain ASD to controls, where expression levels were higher in ASD compared to controls <b>(ASD&gtCtrl DEGs)</b> or lower <b>(ASD&ltCtrl DEGs)</b> .</li>
<li>You can try them out by clicking on the respective buttons, then querying the database. </li>
<li>You can also download a spreadsheet of both datasets and their outputs <u><a href="https://github.com/ciernialab/MGEnrichmentApp/blob/main/Toy_Dataset_Input_and_Output.xlsx">from the GitHub repository</a>.</u></li>
</ul>

<h3 style = "font-size: 20px;font-weight: bold">Interpreting Results</h3>
<ul>
<li><b>listname</b> - name of the gene list that is being compared against.</li>
<li><b>pvalue</b> - p-value of enrichment analysis (as calculated by one-tailed Fisher\'s Exact Test).</li>
<li><b>FDR</b> - false discovery rate correction value.</li>
<li><b>OR</b> - the Odds Ratio.</li>
<li><b>not_in_both_lists</b> - number of genes not in any gene list.</li>

<li><b>in_userlist_only</b> - number of genes in the user\'s uploaded gene list (list A) but not in the current database gene list being analyzed (list B).</li>
<li><b>in_database_only</b> - number of genes in the current database gene list (list B) but not in the user uploaded gene list (list A).</li>
<li><b>in_both_lists</b> - number of genes in both the current database gene list and the user uploaded gene list.</li>
<li><b>intersection_IDs</b> - the direct list of overlapping gene IDs (in_both_lists). This will be in the gene ID type that you have selected, and is the original overlap list, so use this for final results.</li>
<li><b>intersection_ensembl</b> - the intersection_IDs, converted to ensembl, if possible.</li>
<li><b>intersection_gene_symbol</b> - the intersection_IDs, converted to gene symbols, if possible.</li>
<li><b>intersection_entrez</b> - the intersection_IDs, converted to entrez, if possible.</li>
<li><b>description</b> - brief description of gene list.</li>
<li><b>source</b> - literature source of gene lists, if applicable.</li>
<li><b>groups</b> - gene list category grouping.</li>
<li><b>tissue</b> - tissue type or cell type used in the dataset (ie. brain or microglia).</li>
<li><b>species</b> - the species the list was originally collected from (rat, human, mouse).</li>
<li><b>full.source</b> - the full literature source of the gene list.</li>
</ul>
The <b>intersection_ids</b> is the original list of overlapping gene IDs, in the format you uploaded and selected for your genes. The 3 successive columns after try to map the gene ID to its corresponding alternate ID equivalents, if possible (therefore one of the columns will be redundant, as it will be in the same gene ID type as what you uploaded, and due to <u><a href="https://github.com/ciernialab/MGEnrichmentApp#differing-results-based-on-gene-id">mapping problems</a></u>, it is not fully complete). It is provided only for convenience to potentially lookup genes of interest faster. When reporting results, use the intersection_ids column for the most accurate results, and convert to other ID types through other means, if necessary.
<br>
<br>

  <br>
  <br>
')
