getwd()
# 1. Set Working Directory
setwd("D:/AI_Omics_Internship_2025")   
# ---------------------------------------------------------------------------
# 2. Create Project Folder
#press file then new project then new directory then new project then type directory name "Module_I" and path

# Inside the project directory, create the following subfolders using R code:
# raw_data, clean_data, scripts, results or Tasks, plots etc
dir.create("raw_data")     
dir.create("clean_data")   
dir.create("scripts")  
dir.create("results")
dir.create("plots")
# ---------------------------------------------------------------------------
# 3. Download "patient_info.csv" dataset from GitHub repository
# load the dataset into your R environment
data = read.csv("raw_data/patient_info.csv")

# Inspect the structure of the dataset using appropriate R functions
str(data)

# Identify variables with incorrect or inconsistent data types.
# gender 
## diagnosis
### smoker
##################
# Convert variables to appropriate data types where needed

# convert gender into factor
data$gender_fact = as.factor(data$gender)
class(data$gender_fact)
# Reorder factor levels manually
data$gender_fact_manual = factor(data$gender_fact, 
                                 levels = c("Male", "Female"))
levels(data$gender_fact_manual)
# convert gender_factor into numeric using ifelse function
data$gender_num <- ifelse(data$gender_fact == "Male", 0 , 1)
class(data$gender_num)
str(data)
# convert gender_num into factor
data$gender_num <- as.factor(data$gender_num)
class(data$gender_num)

##################

# convert diagnosis into factor
data$diagnosis_fact = as.factor(data$diagnosis)
# Convert diagnosis_fact to numeric using ifelse statement (Cancer = 1, Normal = 0)
data$diagnosis_num = ifelse(data$diagnosis_fact == "Cancer", 1, 0)
class(data$diagnosis_num)
# Convert diagnosis_num to factor
data$diagnosis_num = as.factor(data$diagnosis_num)
class(data$diagnosis_num)
str(data)

##################

# convert smoker into factor
data$smoker_fact = as.factor(data$smoker)
# convert smoker_fact to numeric
data$smoker_num = ifelse(data$smoker_fact == "Yes", 1, 0 )
class(data$smoker_num)
# convert smoker_num into factor
data$smoker_num = as.factor(data$smoker_num)
class(data$smoker_num)

##################

# Create a new variable for smoking status as a binary factor:
# 1 for "Yes", 0 for "No"
data$smoking_status= ifelse(data$smoker_fact == "Yes", 1, 0)
str(data$smoking_status)
str(data)

##################
# Save the cleaned dataset in your clean_data folder with the name patient_info_clean.csv
write.csv(data, "clean_data/patient_info_clean.csv")
# Save the entire R workspace
save.image(file = "Logykhaled_Class_Ib_Assignment.RData")

