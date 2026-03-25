#!/bin/bash

R="\[e31m"
G="\[e32m"
Y="\[e33m"
N="\[e0m"
USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p $LOGS_FOLDER

if  [ $USERID -ne 0 ]
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
        echo "$2 is...$G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo "$2 is...$R FAILURE $N" | tee -a $LOG_FILE
        exit
    fi
}

echo "Script started exectuing at: $(date)"

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld 
systemctl start mysqld
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD
VALIDATE $? "setting root password"









