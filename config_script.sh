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
  if [ -n "$2" ] ; then
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
      '-c') # correct ✓
        echo -ne "${GREY}[${GREEN}✓${GREY}]--->${BLUE} $1 ${GREY}<---${NC}\n\r"
        echo "------> $1 <---" |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-m') # message
        echo -ne "${GREY}------> ${GREEN}$1 ${GREEN}<---${NC}\n\r"
        echo "------> $1 <---" |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-q') # question
        echo -ne "${GREY}------> ${BOLD}$1: ${GREEN}"
      ;;
    esac
  else
    echo -ne "${GREY}------> $1 <---${NC}\n\r"
    echo "------> $1 <---" |& tee -a $LOG_FILE &> /dev/null
  fi
}

function get_param(){
  if [ -n "$1" ] ; then
    PARAM=""
    while [ "" == "$PARAM" ] ; do
      message "$1" "-q"
      read PARAM
      if [ -n "$2" ] ; then
        if [ `echo $2 | grep $PARAM | wc -l` -eq 0 ] ; then
          PARAM=""
        fi
      fi
    done
  fi
}

get_param "Instalacja dejango? [Y/n]" "yYnN"

echo "$PARAM"