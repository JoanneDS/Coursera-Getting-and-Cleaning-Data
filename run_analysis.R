###Load required package
library(datasets)
library(data.table)

filesPath <- getwd()

filename <- "getdata%2Fprojectfiles%2FUCI HAR Datasett.zip"

# Download and unzip the dataset:
if (!file.exists(filename))
{
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) 
  unzip(filename) 

# Load activity labels + features
activityLabels <- read.table(file.path(filesPath,"UCI HAR Dataset/activity_labels.txt"))
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table(file.path(filesPath,"UCI HAR Dataset/features.txt"))
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- grep("mean()|std()", features[,2])
featuresWanted.names <- features[featuresWanted,2]

# Load the datasets
train <- read.table(file.path(filesPath,"UCI HAR Dataset/train/X_train.txt"))[featuresWanted]
trainActivities <- read.table(file.path(filesPath,"UCI HAR Dataset/train/Y_train.txt"))
trainSubjects <- read.table(file.path(filesPath,"UCI HAR Dataset/train/subject_train.txt"))
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table(file.path(filesPath,"UCI HAR Dataset/test/X_test.txt"))[featuresWanted]
testActivities <- read.table(file.path(filesPath,"UCI HAR Dataset/test/Y_test.txt"))
testSubjects <- read.table(file.path(filesPath,"UCI HAR Dataset/test/subject_test.txt"))
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData_mean <- aggregate(allData[,3:length(allData)], by=list(activity = allData$activity, subject=allData$subject), FUN = mean)
allData_mean <- setcolorder(allData_mean, c("subject", "activity", featuresWanted.names))
write.table(allData_mean, "tidyData.txt", row.name=FALSE)