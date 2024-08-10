# the component variable value is defined individually for each service

#defining the log file
LOG_FILE=/tmp/roboshop.log
rm -f $LOG_FILE #used to get rid of logs from previous run. do not use if you want to store logs of all runs.
code_dir=$(pwd)

#defining a print function to replace using echo

#output is being redirected to /tmp/roboshop.log.
# notice that output will be appended because of the usage of >>
# PRINT Remove old content - example of print function being called with variables. using $* will print it all
PRINT() {
  echo &>>$LOG_FILE  #used to introduce an empty line
  echo &>>$LOG_FILE #used to introduce an empty line
  echo " ####################################### $* ########################################" &>>$LOG_FILE #will be written to log file
  echo $* #will be written to output screen.
  # let's say we are passing PRINT Remove old content
  # the output of this function will introduce two empty lines in the log file, then it will print ###Remove old content### in the logfile and then print PRINT Remove old content in the stdout
}

#Stat function is taking variable input from the exit status in other scripts
#if the exit status value being provided is equal to 0, then print success.
#if the value is not 0, print failure, display message to refer to log file for more info, print the value of the exit status and then exit
STAT() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
  else
    echo -e "\e[31mFAILURE\e[0m"
    echo
    echo "Refer the log file for more information : File Path : ${LOG_FILE}"
    exit $1 #exit command is used to exit the task if there is a failure. without the exit command, shell will proceed with the other stages
  fi
}

APP_PREREQ() {
  PRINT Adding Application User
  id roboshop &>>$LOG_FILE
  if [ $? -ne 0 ]; then
    useradd roboshop &>>$LOG_FILE
  fi
  STAT $?

  PRINT Remove old content
  rm -rf ${app_path}  &>>$LOG_FILE
  STAT $?

  PRINT Create App Directory
  mkdir ${app_path}  &>>$LOG_FILE
  STAT $?

  PRINT Download Application Content
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip  &>>$LOG_FILE
  STAT $?

  PRINT Extract Application Content
  cd ${app_path}
  unzip /tmp/${component}.zip  &>>$LOG_FILE
  STAT $?
}

SYSTEMD_SETUP() {
    PRINT Copy Service file
    cp ${code_dir}/${component}.service /etc/systemd/system/${component}.service &>>$LOG_FILE
    STAT $?

    PRINT Start Service
    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable ${component} &>>$LOG_FILE
    systemctl restart ${component} &>>$LOG_FILE
    STAT $?
}

NODEJS() {
  PRINT Disable NodeJS Default Version
  dnf module disable nodejs -y &>>$LOG_FILE
  STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

  PRINT Enable NodejS 20 Module
  dnf module enable nodejs:20 -y &>>$LOG_FILE
  STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

  PRINT Install Nodejs
  dnf install nodejs -y &>>$LOG_FILE
  STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

  APP_PREREQ

  PRINT Download NodeJS Dependencies
  npm install &>>$LOG_FILE
  STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

  SCHEMA_SETUP
  SYSTEMD_SETUP

}


JAVA() {

  PRINT Install Maven and Java
  dnf install maven -y &>>$LOG_FILE
  STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

  APP_PREREQ

  PRINT Download Dependencies
  mvn clean package &>>$LOG_FILE
  mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
  STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

  SCHEMA_SETUP
  SYSTEMD_SETUP

}

SCHEMA_SETUP() {
  if [ "$schema_setup" == "mongo" ]; then
    PRINT COpy MongoDB repo file
    cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
    STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

    PRINT Install MongoDB Client
    dnf install mongodb-mongosh -y &>>$LOG_FILE
    STAT $?

    PRINT Load Master Data
    mongosh --mongodb.dev.sridevops.site </app/db/master-data.js &>>$LOG_FILE
    STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh
  fi

  if [ "$schema_setup" == "mysql" ]; then
    PRINT Install MySQL Client
    dnf install mysql -y &>>$LOG_FILE
    STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh

    for file in schema master-data app-user; do
      PRINT Load file - $file.sql
      mysql -h mysql.dev.sridevops.site -uroot -pRoboShop@1 < /app/db/$file.sql &>>$LOG_FILE
      STAT $? # $? is used to get the exit status which is then fed to the stat function which is defined in common.sh
    done

  fi

}
