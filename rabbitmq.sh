source common.sh
component=rabbitmq
repo_service=rabbitmq-server

COPY_REPO

PRINT Install rabbitmq
dnf install rabbitmq-server -y &>>$LOG_FILE
STAT $?

REPO_SETUP

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

