displayHelp <- HTML('
<p style="font-size:30px">
<b>Welcome to the Ciernia Lab Microglia Enrichment Calculator!</b>
</p>
<p>
The calculator is quite simple; the user uploads the gene sets they want to test for enrichment. 
The app then runs what is essentially a one-tailed Fishers Exact Test with the user\'s uploaded 
genes for every gene set in the database (against a specified "background 
universe" of genes). If the user\'s uploaded genes have a significant overlap with any particular 
gene set, the gene set is said to be highly represented, or "enriched." Depending on the particular 
gene set that is enriched, this could have important implications for the user\'s gene set.
</p>
<img src="venn_diagram.png" style="width:800px;height:400;" class="center">

<h3 style = "font-size: 20px;font-weight: bold"> Tips For Using the App </h3>
<br>
<h5 style = "font-weight: bold">Uploading Gene Sets</h5>
<ul>
<li>The app can take in a gene set via text input in the textbox, or by uploading a dataset (acceptable file formats are csv, tsv and txt)</li>
<li>The app can take in Ensembl, Entrez and MGI symbol gene IDs, but can only parse one type at a time, so all gene IDs need to follow the same ID type, and you must correctly specify which ID type you are using for the matching to work properly.</li>
<li>If possible, it is recommended to use Ensembl IDs, as this is what was originally used to compile our gene set lists</li>
<li> If you are pasting in IDs, they can be separated by tabs, spaces or commas.</li>
</ul>

<h5 style = "font-weight: bold">Filtering Genes by Groups</h5>
<ul>
<li>The genes in the database fall into several categories. By default they are all selected, but you can remove genes in certain groups from the database by delecting them in the checkboxes if they are not of interest.</li>
<li><i>Note that this will affect the number of genes used in the database, and if you are using the "All Genes in the Database" option for the background gene set, this will affect enrichment calculations. Certain gene lists may also be removed depending on which groups are deselected.</i></li>
</ul>

<h5 style = "font-weight: bold">Selecting Background Gene Set</h5>
<ul>
<li>You can either set the background number of genes to be all mouse genes <i>(All mm10 Genes)</i>, or all the genes currently in the database <i>(All Genes in the Database)</i>.</li>
<li> You can also upload a custom set by selecting <i>Custom</i>. Format for the custom background set follows the user-uploaded gene set format.</li>
</ul>

<h5 style = "font-weight: bold">Uploading Background Gene Set</h5>
<ul>
<li>Any custom uploaded background gene sets must be large enough to serve as a background gene set (it should be larger than the largest gene set in the database (7266 genes) + your user uploaded gene set). See online documentation for more information. </li>

</ul>
<h5 style = "font-weight: bold">Filtering & Disabling IDs</h5>

<ul>
<li>The p-value slider can be used to filter your results for FDR significance level. </li>
<li>The checkbox options can be used to remove the specified columns from the output, which may be useful if your gene set is very long.
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

<h3 style = "font-size: 20px;font-weight: bold">Interpreting Results</h3>
<ul>
<li><b>listname</b> - name of the gene set that is being compared against.</li>
<li><b>pvalue</b> - p-value of enrichment analysis (as calculated by one-tailed Fisher\'s Exact Test).</li>
<li><b>OR</b> - the Odds Ratio.</li>
<li><b>notAnotB</b> - number of genes not in any gene set.</li>

<li><b>inAnotB</b> - number of genes in the user\'s uploaded gene set (set A) but not in the current database gene set being analyzed (set B).</li>
<li><b>inBnotA</b> - number of genes in the current database gene set (set B) but not in the user uploaded gene set (set A).</li>
<li><b>inBinA</b> - number of genes in both the current database gene set and the user uploaded gene set.</li>
<li><b>intersection_IDs</b> - the direct list of overlapping gene IDs (inBinA). This will be in the gene ID type that you have selected, and is the original overlap list, so use this for final results.</li>
<li><b>intersection_ensembl</b> - the intersection_IDs, converted to ensembl, if possible.</li>
<li><b>intersection_mgi_symbol</b> - the intersection_IDs, converted to MGI symbols, if possible.</li>
<li><b>intersection_entrez</b> - the intersection_IDs, converted to entrez, if possible.</li>
<li><b>FDR</b> - false discovery rate correction value.</li>
<li><b>description</b> - brief description of gene set.</li>
<li><b>source</b> - literature source of gene sets, if applicable.</li>
<li><b>groups</b> - gene set category grouping.</li>
<li><b>species</b> - the species the list was originally collected from (rat, human, mouse). All genes are converted to Mouse IDs.</li>
<li><b>tissue</b> - tissue type or cell type used in the dataset (ie. brain or microglia).</li>
</ul>
The <b>intersection_ids</b> is the original list of overlapping gene IDs, in the format you uploaded and selected for your genes. The 3 successive columns after try to map the gene ID to its corresponding alternate ID equivalents, if possible (therefore one of the columns will be redundant, as it will be in the same gene ID type as what you uploaded, and due to [mapping](#differing-results-based-on-gene-id) problems, it is not fully complete). It is provided only for convenience to potentially lookup genes of interest faster. When reporting results, use the intersection_ids column for the most accurate results, and convert to other ID types through other means, if necessary.
<br>
<br>
  For more details, please visit the online documentation on the GitHub <a href="https://github.com/ciernialab/MGEnrichmentApp">repository</a>.
  <br>
  <br>
')
