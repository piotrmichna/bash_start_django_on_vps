#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

C_ERR="\e[0;31m"
C_WOR="\e[0;33m"
C_MES="\e[0;34m"
C_QST="\e[0;32m"
C_COR="\e[0;32m"
C_TIT="\e[0;34m"
C_NRM="\e[0;97m"
GREEN="\e[0;32m"
BLINK="\e[5m"
BOLD="\e[1m"
NC="\e[0m"

currentDate=$(date +"%F")
currentTime=$(date +"%T")

DIR_SC=`pwd`
LOG_FILE="$DIR_SC/log_${currentDate}_${currentTime}.log"

function start_scripts(){
    sudo ls > /dev/null
    echo -ne "\n\r${C_TIT}${BOLD}------> INSTALL DJANGO ON VPS <-----------[ ${currentDate} ${currentTime} ]${NC}\n\r"
    echo "" |& tee -a $LOG_FILE &> /dev/null
    echo "------> INSTALL DJANGO ON VPS <-----------[ ${currentDate} ${currentTime} ]" |& tee -a $LOG_FILE &> /dev/null
}