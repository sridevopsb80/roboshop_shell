#before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and while execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
#if the common.sh exists in another directory, provide the absolute pathname of the file
# the component variable is defined individually for each service and is being called in the common.sh file


source common.sh
component=mongo

# $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Copy MongoDB repo file
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
STAT $?

PRINT Install MongoDB
dnf install mongodb-org -y &>>$LOG_FILE
STAT $?

PRINT Update MongoDB config file
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOG_FILE
STAT $?

# s/127.0.0.1/0.0.0.0/ - substitution

PRINT Start MongoDB Service
systemctl enable mongod &>>$LOG_FILE
systemctl restart mongod &>>$LOG_FILE
STAT $?
