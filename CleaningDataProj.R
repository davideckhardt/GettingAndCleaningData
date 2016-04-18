rm(list = ls(all=TRUE))
library(dplyr)

destDir <- "./Data"
destName <- paste0(destDir,"/projectFiles.zip")

# load the data file zip on first pass only
if(!file.exists(destName)){
  dir.create(destDir)
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, destfile = destName)
  print(dateDownloaded <- date())
  unzip(zipfile=destName,exdir=destDir)
}

destDir <- paste0(destDir,"/UCI HAR Dataset")

# features.txt contains features column names
featuresLabels <- read.table(paste0(destDir,"/features.txt"), header=FALSE, stringsAsFactors = FALSE)[,2]

# read and combine features data - 561 device observation types
featuresTrainData <- tbl_df(read.table(paste0(destDir,"/train/X_train.txt"), col.names=featuresLabels, header=FALSE))
featuresTestData <- tbl_df(read.table(paste0(destDir,"/test/X_test.txt"), col.names=featuresLabels, header=FALSE))
combinedFeaturesData <- bind_rows(featuresTrainData, featuresTestData)

# read and combine activity data - 6 types of subject activities
activityTrainData <- tbl_df(read.table(paste0(destDir,"/train/y_train.txt"), col.names="activity", header=FALSE))
activityTestData <- tbl_df(read.table(paste0(destDir,"/test/y_test.txt"), col.names="activity", header=FALSE))
combinedActivityData <- bind_rows(activityTrainData, activityTestData)

# read and combine subject data - 30 different test participants
subjectTrainData <- tbl_df(read.table(paste0(destDir,"/train/subject_train.txt"), col.names="subject", header=FALSE))
subjectTestData <- tbl_df(read.table(paste0(destDir,"/test/subject_test.txt"), col.names="subject", header=FALSE))
combinedSubjectData <- bind_rows(subjectTrainData, subjectTestData)

# read activity labels
activityLabels <- read.table(paste0(destDir,"/activity_labels.txt"), header=FALSE, stringsAsFactors = TRUE)[,2]

# merge all data
combinedData <- bind_cols(combinedSubjectData, combinedActivityData, combinedFeaturesData)

# extract only mean and std columns
subCombinedData <- select(combinedData, matches("subject|activity|mean|std"))

# change the activity values in combined data
subCombinedData <- mutate(subCombinedData, activity = factor(subCombinedData$activity, labels=activityLabels))

# rename the variable names
names(subCombinedData) <- sub("Acc", "Accelerometer", names(subCombinedData))
names(subCombinedData) <- sub("Gyro", "Gyroscope", names(subCombinedData))
names(subCombinedData) <- sub("Mag", "Magnitude", names(subCombinedData))

# Apply summary function to each column. 
DataOut <- summarise_each(subCombinedData, funs(mean))
DataOut <- bind_rows(subCombinedData, DataOut)

# output with average of each variable for each activity and each subject
write.table(DataOut, file = "./projectoutput.txt",row.name=FALSE)


