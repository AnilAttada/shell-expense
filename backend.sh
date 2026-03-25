#!/bin/bash

R="\[e31m"
G="\[e32m"
Y="\[e33m"
N="\[e0m"
USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER

if  [ $USERID -ne o ]
then
    echo -e " $R Error:: please run script with root access $N " | tee -a $LOG_FILE
    exit 1
else
    echo -e " $G you are running with root access $N " | tee -a $LOG_FILE
fi

echo "please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is...$G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is...$R FAILURE $N" | tee -a $LOG_FILE
        exit
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabiling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabiling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "expense user" expense
    VALIDATE $? "Creating Expense system user"
else
    echo -e "system user already exist...$Y SKIPPING $N" | tee -a $LOG_FILE
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading code"

rm -rf /app/*
cd /app
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping of code"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "Copying service to system"

systemctl daemon-reload
systemctl start backend
systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Starting backend"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.anilkumar.shop -uroot -p$MYSQL_ROOT_PASSWORD -e 'use transactions' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.anilkumar.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/schema/backend.sql &>>$LOG_FILE
    VALIDATE $? "Loading data"
else
    echo -e "Data is already loaded"
fi

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarting backend"



