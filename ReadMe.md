---
title: "Data Cleaning Project"
author: "David Eckhardt"
date: "April 17, 2016"
output: html_document
---

Getting and Cleaning Data Course Project
This project consists of tidying the data provided in a Samsung Galaxy accelerometer, and Gyroscope study.  
There were 30 subjects that participated in 6 different activities.  
The Accelerometer and Gyroscope information was aggregated into Train and Test files.

Subject
Description: Integer array of the 30 participants in the study.  No labels are provided for the subject data.  Train data has 7352 observations; Test data has 2947 observations.
Files: 	subject_train.txt
	subject_test.txt

Activities
Description:  integer array of 6 possible activities the subjects can participate in:
-	WALKING
-	WALKING_UPSTAIRS
-	WALKING_DOWNSTAIRS
-	SITTING
-	STANDING
-	LAYING
The data files contain the activity of each of the train and test observations.  Train data has 7352 observations; Test data has 2947 observations.
Files: 	y_train.txt
	y_test.txt

Features
Description: Large data files containing values for each of the 561 possible readings from the study participants.  Just as the other files, the features data is in test and train files.  The features.txt file describes each of the 561 values.  These data files contain the measurements of the Accelerometer, Gyroscope and Angular data.
Files: 	X_train.txt
	X_test.txt
	features.txt


```{r}
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
```
