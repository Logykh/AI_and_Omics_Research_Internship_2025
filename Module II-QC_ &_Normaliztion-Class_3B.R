# Load Required Libraries
library(GEOquery)             
library(affy)                 
library(arrayQualityMetrics)  
library(dplyr)                
gse_data <- getGEO("GSE16515", GSEMatrix = TRUE)

# Extract expression data matrix (genes/probes × samples)
expression_data <- exprs(gse_data$GSE16515_series_matrix.txt.gz)

# Extract feature (probe annotation) data
feature_data <-  fData(gse_data$GSE16515_series_matrix.txt.gz)

# Extract phenotype (sample metadata) data
phenotype_data <-  pData(gse_data$GSE16515_series_matrix.txt.gz)

# Check missing values in sample annotation
sum(is.na(phenotype_data$source_name_ch1)) 

# Untar CEL files if compressed as .tar
untar("raw data/GSE16515_RAW.tar", exdir = "raw data/CEL_Files")

# Read CEL files into R as an AffyBatch object
raw_data <- ReadAffy(celfile.path = "raw data/CEL_Files")
raw_data

# ---------------------------------------------------
#### Quality Control (QC) Before Pre-processing ####
# ---------------------------------------------------
arrayQualityMetrics(expressionset = raw_data,
                    outdir = "Results/QC_Raw_Data",
                    force = TRUE,
                    do.logtransform = TRUE)

normalized_data <- rma(raw_data)

# QC after data normalization 
arrayQualityMetrics(expressionset = normalized_data,
                    outdir = "Results/QC_Normalized_Data",
                    force = TRUE)

# Extract normalized expression values into a data frame
processed_data <- as.data.frame(exprs(normalized_data))
dim(processed_data)

#### Filter Low-Variance Transcripts (“soft” intensity based filtering) ####
# ---------------------------------------------------------------------------
# Calculate median intensity per probe across samples
row_median <- rowMedians(as.matrix(processed_data))

# Visualize distribution of probe median intensities
hist(row_median,
     breaks = 100,
     freq = FALSE,
     main = "Median Intensity Distribution")

# Set a threshold to remove low variance probes
threshold <- 3.2 
abline(v = threshold, col = "black", lwd = 2) 

# Select probes above threshold
indx <- row_median > threshold 
filtered_data <- processed_data[indx, ] 

# Rename filtered expression data with sample metadata
colnames(filtered_data) <- rownames(phenotype_data)

# Overwrite processed data with filtered dataset
processed_data <- filtered_data 

#### Phenotype Data Preparation ####
# -----------------------------------

class(phenotype_data$source_name_ch1) 

# Define experimental groups (normal vs cancer)
groups <- factor(phenotype_data$source_name_ch1)
class(groups)
levels(groups)

