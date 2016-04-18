---
title: "CodeBook"
author: "David Eckhardt"
date: "April 17, 2016"
output: html_document
---
The data was sourced from this location:
  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The script to automate these steps is:
  run_analysis.R

The steps to tidy the data were:   
load and unzip => 
  merge =>
    extract mean and std deviation =>
      rename activity names =>
        rename variable names =>
          output with average of each variable
          
features.txt contains features column names
```{r}
featuresLabels <- read.table(paste0(destDir,"/features.txt"), header=FALSE, stringsAsFactors = FALSE)[,2]
```

Read and merge features data - 561 device observation types
```{r}
featuresTrainData <- tbl_df(read.table(paste0(destDir,"/train/X_train.txt"), col.names=featuresLabels, header=FALSE))
featuresTestData <- tbl_df(read.table(paste0(destDir,"/test/X_test.txt"), col.names=featuresLabels, header=FALSE))
combinedFeaturesData <- bind_rows(featuresTrainData, featuresTestData)
```

Read and merge activity data - 6 types of subject activities
```{r}
activityTrainData <- tbl_df(read.table(paste0(destDir,"/train/y_train.txt"), col.names="activity", header=FALSE))
activityTestData <- tbl_df(read.table(paste0(destDir,"/test/y_test.txt"), col.names="activity", header=FALSE))
combinedActivityData <- bind_rows(activityTrainData, activityTestData)
```

Read and merge subject data - 30 different test participants
```{r}
subjectTrainData <- tbl_df(read.table(paste0(destDir,"/train/subject_train.txt"), col.names="subject", header=FALSE))
subjectTestData <- tbl_df(read.table(paste0(destDir,"/test/subject_test.txt"), col.names="subject", header=FALSE))
combinedSubjectData <- bind_rows(subjectTrainData, subjectTestData)
```
Read activity labels
```{r}
activityLabels <- read.table(paste0(destDir,"/activity_labels.txt"), header=FALSE, stringsAsFactors = TRUE)[,2]
```

Merge all data
```{r}
combinedData <- bind_cols(combinedSubjectData, combinedActivityData, combinedFeaturesData)
```

Extract only mean and std columns
```{r}
subCombinedData <- select(combinedData, matches("subject|activity|mean|std"))
```

Change the activity values in combined data
```{r}
subCombinedData <- mutate(subCombinedData, activity = factor(subCombinedData$activity, labels=activityLabels))
```

Rename key variable names
```{r}
names(subCombinedData) <- sub("Acc", "Accelerometer", names(subCombinedData))
names(subCombinedData) <- sub("Gyro", "Gyroscope", names(subCombinedData))
names(subCombinedData) <- sub("Mag", "Magnitude", names(subCombinedData))
```

Apply summary function to each column. 
```{r}
DataOut <- summarise_each(subCombinedData, funs(mean))
DataOut <- bind_rows(subCombinedData, DataOut)
```

Output with average of each variable for each activity and each subject
```{r}
write.table(DataOut, file = "./projectoutput.txt",row.name=FALSE)
```
