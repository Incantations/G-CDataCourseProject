##
# 1 Merges the training and the test sets to create one data set.
# 2 Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3 Uses descriptive activity names to name the activities in the data set
# 4 Appropriately labels the data set with descriptive variable names. 
# 5 From the data set in step 4, creates a second, independent tidy data set with the 
#   average of each variable for each activity and each subject.

## Set up the libraries - if you don't have libraries, please install them.
library(dplyr)
library(data.table)

#------ PART 1 ------- Merges the training and the test sets to create one data set.

## Download and unzip the data - uncomment if you don't have the data in your current working directory
#library(downloader)
#download("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "wearableData.zip")
#unzip("wearableData.zip")

#read in the test sets
test_setX <-read.table("UCI HAR Dataset/test/X_test.txt")
test_labels <-read.table("UCI HAR Dataset/test/y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
train_setX <- read.table("UCI HAR Dataset/train/X_train.txt")
train_labels <- read.table("UCI HAR Dataset/train/y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

# combine the sets
test_set<-cbind(test_labels,test_subjects,test_setX) # first combine all the tests
train_set<-cbind(train_labels,train_subjects,train_setX) # then combine all the train
merged_set <- rbind(test_set,train_set) # since the sets have the same number of variables and different obs we will make it a thin set

#------ PART 2 ------- Extracts only the measurements on the mean and standard deviation for each measurement. 

## Attach labels to the 563 variables
features <- read.table("UCI HAR Dataset/features.txt")
names(merged_set) <-c("Activity","Subject",as.character(features$V2)) # the first two columns are special, the others need to be strings

## Find the columns with mean in it
mean_cols<-grep("mean\\(\\)",names(merged_set)) # we are using purely the means that have stds attached here
std_cols<-grep("std\\(\\)",names(merged_set))

# the mean and std are now separate. We want them together
tot_cols <- cbind(mean_cols,std_cols)
tot_cols <- tot_cols[order(tot_cols)]
tot_merged_set <-merged_set[c(1,2,tot_cols)]

# since we are interested in the measurements only and not the fouriour transform. We remove these.
t_cols <- grep("^t",names(tot_merged_set)) # find all variables starting with t
tot_merged_set <-tot_merged_set[c(1,2,t_cols)]


#------ PART 3 ------- Uses descriptive activity names to name the activities in the data set

#Import the activity table
activities <- read.table("UCI HAR Dataset/activity_labels.txt")

# using the numbers as a hash, read in the activities
for(i in 1:6){
  tot_merged_set$Activity<-gsub(i,activities$V2[i],tot_merged_set$Activity)
}


#------ PART 4 ------- Appropriately labels the data set with descriptive variable names. 
## Current data labels are a bit vague. We currently have 5 XYZ measurements and 5 magnitude measurements
## It seems best to just make changes to these

set_to_change <- names(tot_merged_set)
set_to_change <- set_to_change[c(seq(3,32,6),seq(33,42,2))]
set_to_change <- gsub("mean\\(\\)","",set_to_change)
set_to_change <- gsub("\\-X","",set_to_change)
set_to_change <- gsub("^t","",set_to_change)

#create new label
new_labels <- c("movement_of_body", "acc_due_to_gravity","jerk_of_body","rotation_of_body",
              "jerk_rotation_of_body","total_movement_of_body","total_acc_due_to_gravity","total_jerk_of_body",
               "total_rotation_of_body","total_jerk_rotation_of_body")

# join it to the new set

label_ref <- cbind(set_to_change,new_labels)

# Update names
var_desc <- names(tot_merged_set)

for(i in 1:length(label_ref[,1])){
  var_desc<-gsub(label_ref[i,1],label_ref[i,2],var_desc)
}

#clean up names
var_desc <- gsub("^t","",var_desc)
var_desc <- gsub("mean\\(\\)","_MEAN",var_desc)
var_desc <- gsub("std\\(\\)","_STD",var_desc)
var_desc <- gsub("\\-X","_on_X_axis_of_phone",var_desc)
var_desc <- gsub("\\-Y","_on_Y_axis_of_phone",var_desc)
var_desc <- gsub("\\-Z","_on_Z_axis_of_phone",var_desc)

#attach these names to the data set
 names(tot_merged_set)<-var_desc


#------ PART 5 ----- From the data set in step 4, creates a second, independent tidy data set with the 
#   average of each variable for each activity and each subject.

#cut data by activity and subject
label_set<- names(tot_merged_set)
clean_set<-arrange(tot_merged_set,Subject)
subject<-group_by(clean_set,Subject,Activity)
clean_set_sum<-summarise_each(subject,funs(mean))
clean_means<-data.table(clean_set_sum)

#write the data to AssignmentSubmissionData.txt in the root folder
write.table(clean_set_sum,file = "AssignmentSubmissionData.txt",row.name=FALSE )



