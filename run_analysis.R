## Install and load the appropriate packages
Install.packages("reshape2")
install.packages("docxtractr")
library(reshape2)
library(docxtractr)

myfile<- "getdata_dataset.zip"

## Download and unzip the files:
if (!file.exists(myfile)){
  F_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(F_URL, myfile, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(myfile) 
}

# Load activity labels & features
activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_Labels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract the mean and the SD
TargetFeatures <- grep(".*mean.*|.*std.*", features[,2])
TargetFeatures.names <- features[TargetFeatures,2]
TargetFeatures.names <- gsub('[-()]', '', TargetFeatures.names)


# import the datasets to R
training <- read.table("UCI HAR Dataset/train/X_train.txt")[TargetFeatures]
train_Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(train_Subjects,train_Activities,training)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[TargetFeatures]
test_Activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_Subjects, test_Activities, test)

# merge datasets and labels
margedData <- rbind(training, test)
colnames(margedData) <- c("subject", "activity", TargetFeatures.names)

# converts activities & subjects to factors
margedData$activity <- factor(margedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
margedData$subject <- as.factor(margedData$subject)

margedData.melted <- melt(margedData, id = c("subject", "activity"))
margedData.mean <- dcast(margedData.melted, subject + activity ~ variable, mean)

write.table(margedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)