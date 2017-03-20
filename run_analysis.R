setwd('/Users/Dylan/Documents/Semester\ 4.2/Data\ Science/GettingAndCleaningData/dataForWeek4')
library(reshape2)

#download data file in the manner we've learned in class
inf <- "project1_data.zip"
if (!file.exists(inf)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, inf, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(inf) 
}

# Load activity data
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only mean and standard dev. data
featuresForProj <- grep(".*mean.*|.*std.*", features[,2])
featuresForProj.names <- features[featuresForProj,2]
featuresForProj.names <- gsub('-mean', 'Mean', featuresForProj.names)
featuresForProj.names <- gsub('-std', 'Std', featuresForProj.names)
featuresForProj.names <- gsub('[-()]', '', featuresForProj.names)

# Read x and y files, they are either: training sets and labels or test sets and activities
trainingSet<- read.table("UCI HAR Dataset/train/X_train.txt")[featuresForProj]
trainingLabels <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainingSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(trainingSubjects, trainingLabels, trainingSet)
testSet <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresForProj]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testData <- cbind(testSubjects, testActivities, testSet)

# Merge training and test tables into mergedData
mergedData <- rbind(trainData, testData)
colnames(mergedData) <- c("subject", "activity", featuresForProj.names)
mergedData$activity <- factor(mergedData$activity, levels = activity_labels[,1], labels = activity_labels[,2])
mergedData$subject <- as.factor(mergedData$subject)
mergedData.melted <- melt(mergedData, id = c("subject", "activity"))
mergedData.mean <- dcast(mergedData.melted, subject + activity ~ variable, mean)

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# named cleanMergedData.txt
write.table(mergedData.mean, "clean_merged_data.txt", row.names = FALSE, quote = FALSE)