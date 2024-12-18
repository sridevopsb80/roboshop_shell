# before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and during execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
# if the common.sh exists in another directory, provide the absolute pathname of the file
# the component variable and repo_service variable are defined in common.sh file. value for these variables are defined individually in the file for each service


source common.sh
component=mongo
repo_service=mongod

# $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

COPY_REPO

PRINT Install MongoDB
dnf install mongodb-org -y &>>$LOG_FILE
STAT $?

PRINT Update MongoDB config file
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOG_FILE
STAT $?

# s/127.0.0.1/0.0.0.0/ - substitution

REPO_SETUP