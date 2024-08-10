source common.sh #before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and while execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
#if the common.sh exists in another directory, provide the absolute pathname of the file
component=redis # the component variable is defined individually for each service and is being called in the common.sh file

PRINT Disbale redis default
dnf module disable redis -y &>>$LOG_FILE
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Enable redis 7
dnf module enable redis:7 -y &>>$LOG_FILE
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Install Redis 7
dnf install redis -y &>>$LOG_FILE
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Update Redis Config
sed -i -e '/^bind/ s/127.0.0.1/0.0.0.0/' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
# ^bind will look for lines starting with bind
# s/127.0.0.1/0.0.0.0/ - substitution. replaces 127.0.0.0 with 0.0.0.0
# '/protected-mode/ c protected-mode no'  - c is used to change a line. searches for protected mode and changes it into protected-mode no
# -e is used to combine two commands to one
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Start Redis Service
systemctl enable redis &>>$LOG_FILE
systemctl restart redis &>>$LOG_FILE
STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh
