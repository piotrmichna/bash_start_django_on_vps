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
        echo -ne "${GREEN}------> $1 ${GREEN}<---${NC}\n\r"
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

function check_dir(){
  if [ -n "$1" ] ; then
    while ; do
      message "$1" "-q"
      read PARAM
      if [ -d "$HOME/$PARAM" ] ; then
        message "Katalog [ $HOME/$PARAM ] już istnieje!" "-e"
      else
        break
      fi
    done
  fi
}

function get_git_clone_config(){
  if [ "$PROJ_DIR" == "" ] ; then
    PROJ_DIR="dxd"
  fi

  mkdir /tmp/$PROJ_DIR
  while true ; do
    get_param "Podaj adres repozytorium aplikacji [q-quit]"

    if [ "$PARAM" == "Q" ] || [ "$PARAM" == "q" ] ; then
      rm -rf /tmp/$PROJ_DIR
      C_CGIT=0
      echo "------> Repozytorium zdalne=NIE <---" |& tee -a $LOG_FILE &> /dev/null
      break
    else
      git clone $PARAM /tmp/$PROJ_DIR &> /dev/null

      if [ $? -eq 0 ] ; then
        rm -rf /tmp/$PROJ_DIR
        GIT_LINK=$PARAM
        C_CGIT=1
        echo "------> Repozytorium zdalne=$GIT_LINK <---" |& tee -a $LOG_FILE &> /dev/null
        break
      else
        message "Błędny adres repozytorium!" "-e"
      fi
    fi
  done  
}

function get_config_user(){
  get_param "Załadować aplikacje z Githuba? [n/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    get_git_clone_config
  else
    C_CGIT=0
    echo "------> Repozytorium zdalne=NIE <---" |& tee -a $LOG_FILE &> /dev/null
  fi


  get_param "Utworzyć usługę systemową dla aplikacji? [n/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    C_SERVICE=1
  else
    C_SERVICE=0
  fi

  get_param "Podaj nazwę aplikacji"
  APP_NAME=$PARAM
  get_param "Podaj opis aplikacji"
  APP_DESCRIPTION=$PARAM
  get_param "Podaj katalog aplikacji ~/"
  APP_DIR=$PARAM
}

function get_config_root(){
  get_param "Utworzyć użytkownika systemowego? [*/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    C_USER=1
  else
    C_USER=0
  fi
}

function get_config(){
  message "Konfiguracja instalatora" "-m"
  get_param "Modyfikacja prompt'a termianal? [*/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    C_PROMPT=1
  else
    C_PROMPT=0
  fi

  get_param "Instalacja i konfiguracja narzędzi? [*/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    C_TOOLS=1
  else
    C_TOOLS=0
  fi

  if [ "$USER" == "root" ] ; then
    get_config_root
  else
    get_config_user
  fi
}

#get_config
get_git_clone_config