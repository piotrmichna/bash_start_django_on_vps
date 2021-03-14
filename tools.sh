#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

C_ERR="\e[0;31m"
C_WOR="\e[0;33m"
C_MES="\e[0;34m"
C_QST="\e[0;35m"
C_COR="\e[0;32m"
C_TIT="\e[0;33m"
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
#LOG_FILE="$DIR_SC/log_${currentDate}_${currentTime}.log"
LOG_FILE="log_file.log"
rm log_file.log

T_COL=0
T_ROW=0

function get_position(){
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    echo -en "\033[6n" > /dev/tty
    IFS=';' read -r -d R -a pos
    stty $oldstty
    T_ROW=$((${pos[0]:2} - 1))
    T_COL=$((${pos[1]} - 1))
}

function end_line_date(){
    tput civis
    currentDate=$(date +"%F")
    currentTime=$(date +"%T")
    get_position
    if [ $T_COL -lt 42 ] ; then
        echo -ne " <" |& tee -a $LOG_FILE
        get_position
        while [ $T_COL -lt 44 ] ; do
            echo -ne "-" |& tee -a $LOG_FILE
            get_position
        done
        echo -ne "[${currentDate} ${currentTime}]\n\r" |& tee -a $LOG_FILE
    else
        echo -ne " <" |& tee -a $LOG_FILE
        get_position
        while [ $T_COL -lt 65 ] ; do
            echo -ne "-" |& tee -a $LOG_FILE
            get_position
        done
        echo -ne "\n\r"  |& tee -a $LOG_FILE
    fi
    tput cnorm
    echo -ne "${NC}"
}

function message(){
  if [ -n "$2" ] ; then
    case "$2" in
      '-t') # title
        echo "" |& tee -a $LOG_FILE
        echo -ne "\n\r${C_TIT}------> ${BOLD}${1}${NC}${C_TIT}"
        echo -n "------> $1" |& tee -a $LOG_FILE &> /dev/null
        end_line_date
      ;;
      '-e') # error
        echo -ne "${C_ERR}${BLINK}ERROR${C_NRM}${NC}->${C_ERR} ${BOLD}$1 ${NC}\n\r"
        echo "ERROR-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-w') # worning
        echo -ne "${C_NRM}  [${C_WOR}!${C_NRM}]->${C_WOR} $1 ${NC}\n\r"
        echo "--[!]-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-c') # correct ✓
        echo -ne "  ${C_NRM}[${GREEN}✓${C_NRM}]->${C_COR} $1 ${NC}\n\r"
        echo "--[✓]-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-m') # message
        echo -ne "${C_NRM}  [${C_MES}i${C_NRM}]->${C_MES} $1 ${NC}\n\r"
        echo "" |& tee -a $LOG_FILE &> /dev/null
        echo "--[i]-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-q') # question
        echo -ne "${C_NRM}  [${C_QST}?${C_NRM}]-> ${C_QST}$1: ${BOLD}"
      ;;
    esac
  else
    echo -ne "${C_NRM}     -> $1 ${NC}\n\r"
    echo "------> $1 " |& tee -a $LOG_FILE &> /dev/null
  fi
}

function start_scripts(){
    sudo ls > /dev/null
    echo -ne "\n\r${NC}${C_TIT}${BOLD}-----------------------------------------------------------------"
    echo "-----------------------------------------------------------------" |& tee -a $LOG_FILE &> /dev/null
    echo -ne "\n\r${C_TIT}${BOLD}"
    figlet -t -k -f /usr/share/figlet/small.flf " Django  on VPS " |& tee -a $LOG_FILE
    echo -ne "${NC}${C_TIT}${BOLD}-----------------------------------------------------------------"
    echo "-----------------------------------------------------------------" |& tee -a $LOG_FILE &> /dev/null

    echo -ne "\n\r${C_TIT}  Autor: ${BOLD}Piotr Michna${NC}"
    echo -ne "\n\r${C_TIT}${DM} e-mail: pm@piotrmichna.pl"
    echo -ne "\n\r${C_TIT}${DM}   Data: 15.03.2021\n\r"

    echo -ne "\n\r${C_TIT}${DM} Skrypt przygotowany w oparciu o wirtualny serwer projektu:"
    echo -ne "\n\r${C_TIT} UW-TEAM.ORG Jakuba Mrugalskiego"
    echo -ne "\n\r${C_TIT}${DM}        Link: ${NC}${C_TIT}https://mikr.us${NC}\n\r"
    echo -ne "\n\r${C_TIT}         MIKR.US 1.0 ${BLINK}35zł/rok"
    echo -ne "\n\r${C_TIT}${DM}         RAM: ${NC}${C_TIT}256MB"
    echo -ne "\n\r${C_TIT}${DM} Technologia: ${NC}${C_TIT}OpenVZ 6${NC}"
    echo -ne "\n\r${C_TIT}${DM}      System: ${NC}${C_TIT}Ubuntu 16${NC}\n\r"
    echo -ne "\n\r${C_TIT}     Korzystając z tego linku https://mikr.us/?r=758803ea"
    echo -ne "\n\r${C_TIT}             otrzymasz dodatkowy miesiąc gratis.\n\r"

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
message "TYTUŁ MODÓŁU" "-t"
message "Błąd wykonywania instrukcji!" "-e"
message "Użytkownik ddd_user już istnieje." "-w"
message "Proces wykonywania instrukcji." "-m"
message "Wykonywanie instrukcji." "-c"
message "Wykonać instalację narzędzi? [t/n]" "-q"
echo -ne "${NC}\n\r"
message "Wiadomość informacyjna"