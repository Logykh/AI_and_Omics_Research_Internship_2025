classify_gene <- function(logFC, padj) {
  ifelse(padj < 0.05 & logFC > 1, "Upregulated",
  ifelse(padj < 0.05 & logFC < -1, "Downregulated",
  "Not_Significant"))
}

input_dir  <- "raw_data"
output_dir <- "results"
files= c("DEGs_Data_1.csv", "DEGs_Data_2.csv")
list= list()

for (fnames in files) {
  cat("\n processing:", fnames, "\n")
  files_path= file.path(input_dir, fnames)
  
  #import data
  data= read.csv(files_path, header = TRUE)
  cat("\n files imported successfully, ", fnames)
  
  #handle missing values
  if ("padj" %in% names(data)) {
    missing_count= sum(is.na(data))
    cat("\n sum of missing values in padj column is:", missing_count)
    #Replace missing padj values with 1
    data$padj[is.na(data$padj)]= 1
  }
  
  if ("logFC" %in% names(data)) {
    missing_count= sum(is.na(data))
    cat("\n sum of missing values in logFC column is:", missing_count, "\n")
    #Replace missing logFC values with 0
    data$logFC[is.na(data$logFC)]= 0
  }
  
  #Add a new column 'status' & apply classify_gene() 
  data$status= classify_gene(data$logFC, data$padj)
  
  #save results (data after editting) into list
  list[[fnames]]= data
  
  # save results in Results folder
  output_file_path <- file.path(output_dir, paste0("DGE analysis results", fnames))
  write.csv(data, output_file_path, row.names = FALSE)
  cat("\n Results saved to:", output_file_path, "\n")
  
  # Summary counts
  cat("\nSummary for:", fnames)
  print(table(data$status))
  
  # count total significant genes (Up + Down)
  significant_genes <- sum(data$status %in% c("Upregulated", "Downregulated"))
  cat("Total Significant genes:", significant_genes, "\n")
  
}
