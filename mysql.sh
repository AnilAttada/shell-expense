#!/bin/bash

R="/[e31m"
G="/[e32m"
Y="/[e33m"
N="/[e0m"
USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p $LOGS_FOLDER

if  [ $USERID -ne o ]
then
    echo -e " $R Error:: please run script with root access $N "
    exit 1
else
    echo -e " $G you are running with root access $N "
fi

echo "Script started exectuing at: $(date)" 



