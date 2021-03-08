#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
GREY="\e[0;90m"
BLINK="\e[5m"
BOLD="\e[1m"
NC="\e[0m"
currentDate=$(date +"%F")
currentTime=$(date +"%T")

LOG_FILE="app.log"


function message(){
  if [ -n $2 ] ; then
    case "$2" in
      '-t') # title
        echo -ne "\n\r${BLUE}${BOLD}------> $1 <-----------[ ${currentDate} ${currentTime} ]${NC}\n\r"
        echo "" |& tee -a $LOG_FILE &> /dev/null
        echo "------> $1 <-----------[ ${currentDate} ${currentTime} ]" |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-e') # error
        echo -ne "${RED}${BLINK}ERROR${NC}${RED}-> $1 <---${NC}\n\r"
        echo "------> $1 <---" |& tee -a $LOG_FILE &> /dev/null
      ;;
    esac
  else
    echo -ne "${GREY}------> $1 <---${NC}\n\r"
    echo "------> $1 <---" |& tee -a $LOG_FILE &> /dev/null
  fi
}

message "Instalacja django" -t
