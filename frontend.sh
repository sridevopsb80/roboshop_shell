#before calling a function, it has to be sourced. here it is being sourced from common.sh.
# information is inherited from common.sh and during execution of this script, information from common.sh is substituted (made available).
# this is not the same as the file being executed.
# to execute, you can use bash <filename.sh>
#if the common.sh exists in another directory, provide the absolute pathname of the file
# the component variable is defined individually for each service and is being called in the common.sh file

source common.sh
component=frontend
app_path=/usr/share/nginx/html

# $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

PRINT Disable Nginx default Version
dnf module disable nginx -y  &>>$LOG_FILE
STAT $?

PRINT Enable Nginx 24 Version
dnf module enable nginx:1.24 -y  &>>$LOG_FILE
STAT $?

PRINT Install Nginx
dnf install nginx -y  &>>$LOG_FILE
STAT $?

PRINT Copy nginx config file
cp nginx.conf /etc/nginx/nginx.conf  &>>$LOG_FILE
STAT $?

APP_PREREQ

PRINT Start Nginx Service
systemctl enable nginx  &>>$LOG_FILE
systemctl restart nginx  &>>$LOG_FILE
STAT $?
