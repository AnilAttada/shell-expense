#!/bin/bash

R="/[e31m"
G="/[e32m"
Y="/[e33m"
N="/[e0m"
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

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo "$2 is...$G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo "$2 is...$R FAILURE $N" | tee -a $LOG_FILE
        exit
    fi
}

dnf install nginx -y 
VALIDATE $? "Installing nginx"

systemctl enable nginx
systemctl start nginx
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE 4? "Removing default content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "Unzipping the code"

rm -rf /etc/nginx/default.d/expense.conf
VALIDATE $? "Removing before existing data"

cp $SCRIPT_DIR/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copying expense conf"

systemctl restart nginx
VALIDATE $? "Restarting nginx"


