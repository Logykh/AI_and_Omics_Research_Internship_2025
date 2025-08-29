# Differential Gene Expression (DGE) Analysis

This repository contains an R script for processing differential gene expression (DGE) results and classifying genes into **Upregulated**, **Downregulated**, or **Not\_Significant** categories.

## Usage

### Load the Data

The script reads input CSV files from the `raw_data/` folder. Each file must contain the following columns:

* `gene_id`
* `logFC` (log2 fold change)
* `padj` (adjusted p-value)

### Classify Genes

The script defines a function `classify_gene()` that:

* Returns **Upregulated** if `logFC > 1` and `padj < 0.05`.
* Returns **Downregulated** if `logFC < -1` and `padj < 0.05`.
* Returns **Not\_Significant** otherwise.

### Handle Missing Values

* Missing `padj` values are replaced with **1**.
* Missing `logFC` values are replaced with **0**.

### Process Datasets

* Each dataset is processed in a loop.
* A new column `status` is added with the classification.
* Processed results are saved into the `results/` folder.

### Generate Summaries

The script prints summary counts including:

* Number of **Upregulated genes**.
* Number of **Downregulated genes**.
* Number of **Not Significant genes**.
* **Total significant genes** (Upregulated + Downregulated).

## Files

* `raw_data/DEGs_Data_1.csv` : Example input dataset.
* `raw_data/DEGs_Data_2.csv` : Example input dataset.
* `results/DGE_analysis_results_DEGs_Data_1.csv` : Processed results for dataset 1.
* `results/DGE_analysis_results_DEGs_Data_2.csv` : Processed results for dataset 2.

## Instructions

1. Place input CSV files in the `raw_data/` directory.
2. Run the R script.
3. Processed results will be saved automatically in the `results/` directory.

