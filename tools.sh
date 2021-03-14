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
INV="\e[7m"
DM="\e[2m"
BLINK="\e[5m"
BOLD="\e[1m"
NC="\e[0m"

currentDate=$(date +"%F")
currentTime=$(date +"%T")

DIR_SC=`pwd`
LOG_FILE="$DIR_SC/log_${currentDate}_${currentTime}.log"

function start_scripts(){
    sudo ls > /dev/null
    echo -ne "\n\r${NC}${C_MES}${DM}-----------------------------------------------------------------"
    echo "-----------------------------------------------------------------" |& tee -a $LOG_FILE &> /dev/null
    echo -ne "\n\r${C_TIT}${BOLD}"
    figlet -t -k -f /usr/share/figlet/small.flf " Django  on VPS " |& tee -a $LOG_FILE
    echo -ne "${NC}${C_MES}${DM}-----------------------------------------------------------------"
    echo "-----------------------------------------------------------------" |& tee -a $LOG_FILE &> /dev/null

    echo -ne "\n\r${C_MES}  Autor: ${BOLD}Piotr Michna${NC}"
    echo -ne "\n\r${C_MES}${DM} e-mail: pm@piotrmichna.pl"
    echo -ne "\n\r${C_MES}${DM}   Data: 15.03.2021\n\r"

    echo -ne "\n\r${C_MES}${DM} Skrypt przygotowany w oparciu o wirtualny serwer projektu:"
    echo -ne "\n\r${C_MES} UW-TEAM.ORG Jakuba Mrugalskiego"
    echo -ne "\n\r${C_MES}${DM}        Link: ${NC}${C_MES}https://mikr.us${NC}\n\r"
    echo -ne "\n\r${C_MES}         MIKR.US 1.0 ${BLINK}35zł/rok"
    echo -ne "\n\r${C_MES}${DM}         RAM: ${NC}${C_MES}256MB"
    echo -ne "\n\r${C_MES}${DM} Technologia: ${NC}${C_MES}OpenVZ 6${NC}"
    echo -ne "\n\r${C_MES}${DM}      System: ${NC}${C_MES}Ubuntu 16${NC}\n\r"
    echo -ne "\n\r${C_MES}     Korzystając z tego linku https://mikr.us/?r=758803ea"
    echo -ne "\n\r${C_MES}             otrzymasz dodatkowy miesiąc gratis.\n\r"

    echo "  Autor: Piotr Michna" |& tee -a $LOG_FILE &> /dev/null
    echo " e-mail: pm@piotrmichna.pl" |& tee -a $LOG_FILE &> /dev/null
    echo "   Data: 15.03.2021" |& tee -a $LOG_FILE &> /dev/null
    echo "" |& tee -a $LOG_FILE &> /dev/null
    echo " Skrypt przygotowany w oparciu o wirtualny serwer projektu:" |& tee -a $LOG_FILE &> /dev/null
    echo " UW-TEAM.ORG Jakuba Mrugalskiego" |& tee -a $LOG_FILE &> /dev/null
    echo "        Link: https://mikr.us" |& tee -a $LOG_FILE &> /dev/null
    echo "" |& tee -a $LOG_FILE &> /dev/null
    echo "         MIKR.US 1.0 35zł/rok" |& tee -a $LOG_FILE &> /dev/null
    echo "         RAM: 256MB" |& tee -a $LOG_FILE &> /dev/null
    echo " Technologia: OpenVZ 6" |& tee -a $LOG_FILE &> /dev/null
    echo "      System: Ubuntu 16" |& tee -a $LOG_FILE &> /dev/null
    echo "" |& tee -a $LOG_FILE &> /dev/null
    echo "     Korzystając z tego linku https://mikr.us/?r=758803ea" |& tee -a $LOG_FILE &> /dev/null
    echo "             otrzymasz dodatkowy miesiąc gratis." |& tee -a $LOG_FILE &> /dev/null
    echo "" |& tee -a $LOG_FILE &> /dev/null
}

start_scripts