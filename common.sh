LOG_FILE=/root/roboshop.log
rm -f $LOG_FILE
code_dir=$(pwd)

PRINT() {
  echo &>>$LOG_FILE
  echo &>>$LOG_FILE
  echo " ####################################### $* ########################################" &>>$LOG_FILE
  echo $*
}

#STAT for status, just a function name to print success and failure messages based on the output of $? command. in case of failure, exit command is used to stop the script execution.
STAT() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
  else
    echo -e "\e[31mFAILURE\e[0m"
    echo
    echo "Refer the log file for more information : File Path : ${LOG_FILE}"
    exit $1
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
  STAT $?

  PRINT Enable NodejS 20 Module
  dnf module enable nodejs:20 -y &>>$LOG_FILE
  STAT $?

  PRINT Install Nodejs
  dnf install nodejs -y &>>$LOG_FILE
  STAT $?

  APP_PREREQ

  PRINT Download NodeJS Dependencies
  npm install &>>$LOG_FILE
  STAT $?

  SCHEMA_SETUP
  SYSTEMD_SETUP

}


JAVA() {

  PRINT Install Maven and Java
  dnf install maven -y &>>$LOG_FILE
  STAT $?

  APP_PREREQ

  PRINT Download Dependencies
  mvn clean package &>>$LOG_FILE
  mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
  STAT $?

  SCHEMA_SETUP
  SYSTEMD_SETUP

}

SCHEMA_SETUP() {
  if [ "$schema_setup" == "mongo" ]; then
    PRINT Copy MongoDB repo file
    cp /root/roboshop_shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
    STAT $?

    PRINT Install MongoDB Client
    dnf install mongodb-mongosh -y &>>$LOG_FILE
    STAT $?

    PRINT Load Master Data
    mongosh --host mongodb.dev.sridevops.site </app/db/master-data.js &>>$LOG_FILE
    STAT $?
  fi

  if [ "$schema_setup" == "mysql" ]; then
    PRINT Install MySQL Client
    dnf install mysql -y &>>$LOG_FILE
    STAT $?

    for file in schema master-data app-user; do
      PRINT Load file - $file.sql
      mysql -h mysql.dev.sridevops.site -uroot -pRoboShop@1 < /app/db/$file.sql &>>$LOG_FILE
      STAT $?
    done

  fi

}

COPY_REPO(){
PRINT Copy $component repo file
cp $component.repo /etc/yum.repos.d/$component.repo
STAT $?
}

REPO_SETUP(){
PRINT Start $component Service
systemctl daemon-reload
systemctl enable $repo_service &>>$LOG_FILE
systemctl restart $repo_service &>>$LOG_FILE
STAT $?
}

PYTHON(){
  PRINT Install Python
  dnf install python3 gcc python3-devel -y &>>$LOG_FILE
  STAT $?

  APP_PREREQ

  PRINT Download Dependencies
  cd /app
  pip3 install -r requirements.txt &>>$LOG_FILE
  STAT $?

  SYSTEMD_SETUP
}

GOLANG(){
  PRINT Install golang
  dnf install golang -y &>>$LOG_FILE
  STAT $?

  APP_PREREQ

  PRINT Download Dependencies and Build Software
  cd /app
  go mod init dispatch &>>$LOG_FILE
  go get &>>$LOG_FILE
  go build &>>$LOG_FILE
  STAT $?

  SYSTEMD_SETUP
}