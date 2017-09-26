# Here are the data for the project:
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# Instruction: create one R script called run_analysis.R that does the following.
#   Merges the training and the test sets to create one data set.
#   Extracts only the measurements on the mean and standard deviation for each measurement.
#   Uses descriptive activity names to name the activities in the data set
#   Appropriately labels the data set with descriptive variable names.
#   From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#   Download mentioned file using dowload.file command and unzip manually

library(plyr)
library(dplyr)

# Read all required data files
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

# Read test files
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Read training files
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Extracts only the measurements on the mean and standard deviation for each measurement.
measurement <- grepl("mean|std", features$V2)

# Rename x_test file header/column names
# Select only the measurements on the mean and standard deviation from x_test
# Add activity_level in y_test using activity_labels
names(x_test) = features$V2
x_test_required <- x_test[,measurement]
y_test_labeled <- mutate(y_test,activity_label = activity_labels$V2[y_test[,1]])
y_test_labeled <- rename(y_test_labeled, activity_id = V1)
subject_test <- rename(subject_test, subject_id = V1)

# Combine subject_test, x_test, y_test in columns
test_combined <- cbind(subject_test, y_test_labeled, x_test_required)

# Rename x_train file header/column names
# Select only the measurements on the mean and standard deviation from x_train
# Add activity_level in y_train using activity_labels
names(x_train) = features$V2
x_train_required <- x_train[,measurement]
y_train_labeled <- mutate(y_train,activity_label = activity_labels$V2[y_train[,1]])
y_train_labeled <- rename(y_train_labeled, activity_id = V1)
subject_train <- rename(subject_train, subject_id = V1)

# Combine subject_train, x_train, y_train in columns
train_combined <- cbind(subject_train,y_train_labeled,x_train_required)

# Finally combine test and train data in rows
all_combined <- rbind(test_combined , train_combined)

# Appropriately labels the data set with descriptive variable names.
names(all_combined) <- gsub("\\(|\\)", "", names(all_combined))
names(all_combined) <- gsub("-", "_", names(all_combined))
names(all_combined) <- gsub("BodyBody", "Body", names(all_combined))
names(all_combined) <- gsub("mean", "Mean", names(all_combined))
names(all_combined) <- gsub("std", "Std", names(all_combined))

# Create tidy data set with the average of each variable for each activity and each subject
tidy_data <- ddply(all_combined, c("subject_id","activity_id","activity_label"), numcolwise(mean))

# Download summarized average data in a file
write.csv(tidy_data, file="tidy_data.csv")
