# 1. Check Cholesterol level (using if) 
# Write an If statement to check cholesterol level is greater than 240, 
# if true, it will prints “High Cholesterol”
cholesterol <- 230
if (cholesterol > 240) {
  print("High Cholesterol")
}
# ----------------------------------------------------------------------------------------------------------------

# 2. Blood Pressure Status (using if...else)
# Write an if…else statement to check if blood pressure is normal.
# If it’s less than 120, print: “Blood Pressure is normal”
# If false then print: “Blood Pressure is high”

Systolic_bp <- 130
if (Systolic_bp < 120) {
  print("Blood Pressure is normal")
} else {
  print("Blood Pressure is high")
}
# ----------------------------------------------------------------------------------------------------------------

# 3. Automating Data Type Conversion with for loop

# patient_info.csv data
# Create a copy of the dataset to work on.
patient_info= read.csv("raw_data/patient_info.csv")
cleanpatient_info= patient_info
# Identify all columns that should be converted to factor type.
# Store their names in a variable (factor_cols).
factor_cols= c("gender", "diagnosis", "smoker")
# Use a for loop to convert all the columns in factor_cols to factor type.
# Pass factor_cols to the loop as a vector.
for (col in factor_cols) {
  cleanpatient_info[[col]]= as.factor(cleanpatient_info[[col]])
}
str(cleanpatient_info)
str(patient_info)
# 4. Converting Factors to Numeric Codes

# Choose one or more factor columns (e.g., smoking_status).
# Convert "Yes" to 1 and "No" to 0 using a for loop.
num_cols= c("smoker")
for (col in num_cols) {
  cleanpatient_info[[col]]= ifelse(cleanpatient_info[[col]]== "Yes", 1, 0)
}
str(cleanpatient_info)
#  Verification:
str(patient_info)
str(cleanpatient_info)

# 3. Automating Data Type Conversion with for loop

# metadata.csv
# Create a copy of the dataset to work on.
meta_data= read.csv("raw_data/Metadata (1).csv")
cleanmeta_data= meta_data
str(meta_data)
# Identify all columns that should be converted to factor type.
#gender #diagnosis #smoker
# Store their names in a variable (factor_cols).
metafactor_cols= c("height", "gender")
# Use a for loop to convert all the columns in factor_cols to factor type.
# Pass factor_cols to the loop as a vector.
for (col in metafactor_cols) {
  cleanmeta_data[[col]]= as.factor(cleanmeta_data[[col]])
}
str(cleanmeta_data)
str(meta_data)
# 4. Converting Factors to Numeric Codes
metanum_cols= c("gender")
for (col in metanum_cols) {
  cleanmeta_data[[col]]= ifelse(cleanmeta_data[[col]]== "Female", 1, 0)
}
#  Verification:
str(meta_data)
str(cleanmeta_data)

