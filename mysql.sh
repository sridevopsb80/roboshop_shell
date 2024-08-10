source common.sh #before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and while execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
#if the common.sh exists in another directory, provide the absolute pathname of the file
component=mysql # the component variable is defined individually for each service and is being called in the common.sh file

PRINT Install MySQL Server
dnf install mysql-server -y &>>$LOG_FILE
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Start MySQL Service
systemctl enable mysqld &>>$LOG_FILE
systemctl restart mysqld &>>$LOG_FILE
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Setup MySQL Root Password
mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh


