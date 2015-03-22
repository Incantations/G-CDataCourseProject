# G-CDataCourseProject

This script is used to tidy the data for the Getting and Cleaning Data Coursera course. This script can be run as long as the Samsung data is in your working directory. If, however, you do not have the data handy, uncomment lines 16 to 18. This will download and unzip the data into your current working directory.

This file uses the following R libraries:

* dplyr
* data.table
* downloader

If you do not have these libraries, the script will not work properly. Please make sure they are installed.

HOW THE SCRIPT WORKS

1. It reads in the relevent sets using the read.table function.
2. It combines the sets vertically to create a tall data set. This uses cbind to add the labels and subjects to the train and the test set and then uses rbind to stack them.
3. It then labels the columns with the features provided by the raw data.
4. Using grep, it finds the columns with 'mean' or 'std' in their name and selects them.
5. Gsub is used to replace the Activity numbers for names using the provided activity data
6. New descriptive data labels are created to be clearer than the original. This is done using the gsub function repeatedly.
7. The means and stds are then grouped and summarised using the 'group_by' function and the 'summarise each' function. This creates a table of the averages for each subject and activity.
8. Finally the tidied data is written to the file: AssignmentSubmissionData.txt and placed in the working directory.
