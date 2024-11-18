# before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and during execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
# if the common.sh exists in another directory, provide the absolute pathname of the file
# the value for variable (which was defined in common.sh) component is defined in the files wherever they are needed for execution.


source common.sh
component=mysql

# $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Install MySQL Server
dnf install mysql-server -y &>>$LOG_FILE
STAT $?

PRINT Start MySQL Service
systemctl enable mysqld &>>$LOG_FILE
systemctl restart mysqld &>>$LOG_FILE
STAT $?

PRINT Setup MySQL Root Password
mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
STAT $?


