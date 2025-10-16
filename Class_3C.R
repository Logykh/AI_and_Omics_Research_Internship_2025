# Load Bioconductor packages
library(AnnotationDbi)   
library(hgu133plus2.db)  
library(limma)
library(dplyr)
library(tibble)
library(ggplot2)
library(pheatmap)
# Load preprocessed expression and phenotype data
load("GSE16515.RData")
# check annotation
annotation(raw_data)
# Display objects available in the annotation package
ls("package:hgu133plus2.db")
columns(hgu133plus2.db)
keytypes(hgu133plus2.db)

# Extract probe IDs from processed microarray data
# -------------------------------------------------------------
probe_ids <- rownames(processed_data)

# Map probe IDs to gene symbols using the platform annotation database
gene_symbols <- mapIds(
  hgu133plus2.db,          # Database used for mapping
  keys = probe_ids,        # Input probe IDs
  keytype = "PROBEID",     # Probe ID key type
  column = "SYMBOL",       # Desired annotation column (gene symbols)
  multiVals = "first"      # Return first match if multiple exist
)
# Convert mapping to a data frame and rename columns
gene_map_df <- gene_symbols %>%
  as.data.frame() %>%
  tibble::rownames_to_column("PROBEID") %>%
  dplyr::rename(SYMBOL = 2)

# Summarize number of probes per gene symbol
duplicate_summary <- gene_map_df %>%
  group_by(SYMBOL) %>%
  summarise(probes_per_gene = n()) %>%
  arrange(desc(probes_per_gene))

# Identify genes associated with multiple probes
duplicate_genes <- duplicate_summary %>%
  filter(probes_per_gene > 1)

sum(duplicate_genes$probes_per_gene)
#44768-10025= 34743

# Merge annotation mapping with expression data
# -------------------------------------------------------------
# Verify if probe IDs in mapping correspond to expression data
all(gene_map_df$PROBEID == row.names(processed_data))

# Merge annotation (SYMBOL) with expression matrix
processed_data_df <- processed_data %>%
  as.data.frame() %>%
  tibble::rownames_to_column("PROBEID") %>%
  dplyr::mutate(SYMBOL = gene_symbols[PROBEID]) %>%
  dplyr::relocate(SYMBOL, .after = PROBEID)

# Remove probes without valid gene symbol annotation
processed_data_df <- processed_data_df %>%
  dplyr::filter(!is.na(SYMBOL))

# Select only numeric expression columns
expr_only <- processed_data_df %>%
  dplyr::select(-PROBEID, -SYMBOL)

# Collapse multiple probes per gene using average expression
# -------------------------------------------------------------
averaged_data <- limma::avereps(expr_only, ID = processed_data_df$SYMBOL)
dim(averaged_data)

# Convert averaged expression data to matrix format
data <- as.data.frame(averaged_data)
data <- data.matrix(data)
str(data)        
is.numeric(data) 

#### Differential Gene Expression Analysis ####
# -------------------------------------------------------------
# Adjust group labels according to dataset annotation
phenotype_data <- phenotype_data %>%
  mutate(source_name_ch1 = sub(".*-(.*)", "\\1", source_name_ch1))
groups <- factor(phenotype_data$source_name_ch1)

class(groups)
levels(groups)

# Create design matrix for linear modeling
# -------------------------------------------------------------
design <- model.matrix(~0 + groups)
colnames(design) <- levels(groups)

# Fit linear model to expression data
fit_1 <- lmFit(data, design)

# Define contrast to compare cancer vs normal samples
contrast_matrix <- makeContrasts(Tumor_vs_Normal = Tumor - Normal,
                                 levels = design)

# Apply contrasts and compute moderated statistics
fit_contrast <- contrasts.fit(fit_1, contrast_matrix)

fit_2 <- eBayes(fit_contrast)

# Extract list of differentially expressed genes (DEGs)
# -------------------------------------------------------------
deg_results <- topTable(fit_2,
                        coef = "Tumor_vs_Normal",  
                        number = Inf,               
                        adjust.method = "BH")      

# Classify DEGs into Upregulated, Downregulated, or Not Significant
# -------------------------------------------------------------
deg_results$threshold <- as.factor(ifelse(
  deg_results$adj.P.Val < 0.05 & deg_results$logFC > 1, "Upregulated",
  ifelse(deg_results$adj.P.Val < 0.05 & deg_results$logFC < -1, "Downregulated",
         "No")
))

# Subset genes by regulation direction
upregulated <- subset(deg_results, threshold == "Upregulated")
downregulated <- subset(deg_results, threshold == "Downregulated")

# Combine both sets of DEGs
deg_updown <- rbind(upregulated, downregulated)

write.csv(deg_results, file = "Results/DEGs_Results.csv")
write.csv(upregulated, file = "Results/Upregulated_DEGs.csv")
write.csv(downregulated, file = "Results/Downregulated_DEGs.csv")
write.csv(deg_updown, file = "Results/Updown_DEGs.csv")

#### Data Visualization ####
# -------------------------------------------------------------
# Volcano Plot: visualizes DEGs by logFC and adjusted p-values
ggplot(deg_results, aes(x = logFC, y = -log10(adj.P.Val), color = threshold)) +
  geom_point(alpha = 0.7, size = 2) +
  scale_color_manual(values = c("Upregulated" = "red",
                                "Downregulated" = "blue",
                                "No" = "grey")) +
  theme_minimal() +
  labs(title = "Volcano Plot of Differentially Expressed Genes",
       x = "log2 Fold Change",
       y = "-log10(P-value)",
       color = "Regulation")
# Save the plot as a PNG file
png("plots/volcano_plot.png", width = 2000, height = 1500, res = 300)
dev.off()

# Heatmap of Top Differentially Expressed Genes
# -------------------------------------------------------------
# Select top genes with smallest adjusted p-values
top_genes <- head(rownames(deg_updown[order(deg_updown$adj.P.Val), ]), 25)
# Subset averaged expression matrix for selected genes
heatmap_data <- data[top_genes, ]
# Generate unique column names per sample group for display
group_char <- as.character(groups)
heatmap_names <- ave(group_char, group_char, FUN = function(x) paste0(x, "_", seq_along(x)))
# Assign formatted names to heatmap columns
colnames(heatmap_data) <- heatmap_names
# Save heatmap as PNG
png("plots/heatmap_top25_DEGs.png", width = 2000, height = 1500, res = 300)

# Generate heatmap without additional scaling
pheatmap(
  heatmap_data,
  scale = "none", # for already normalized data
  cluster_rows = FALSE,              # Disable row clustering
  cluster_cols = TRUE,               # Cluster samples
  show_rownames = TRUE,              # Display gene names
  show_colnames = TRUE,              # Display sample labels
  color = colorRampPalette(c("blue", "white", "red"))(100),
  fontsize_row = 6,
  fontsize_col = 8,
  main = "Top 25 Differentially Expressed Genes"
)

dev.off()

