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

function get_logo(){
  echo -ne "${C_MES}${BOLD}/home/user/${NC}\n\r"
  echo -ne "       |\n\r"
  echo -ne "       + ${C_MES}${BOLD}proj_app/ ${NC}${GREEN}# Katalog aplikacji${NC}\n\r"
  echo -ne "             |\n\r"
  echo -ne "             + ${C_MES}${BOLD}.git/${NC}\n\r"
  echo -ne "             + ${C_MES}${BOLD}django_proj/ ${NC}${GREEN}# Katalog projektu Django${NC}\n\r"
  echo -ne "             |    |\n\r"
  echo -ne "             |    + ${C_MES}${BOLD}django_proj/${NC}\n\r"
  echo -ne "             |    + ${GREEN}${BOLD}manage.py${NC}\n\r"
  echo -ne "             + ${C_MES}${BOLD}venv${NC}\n\r\n\r"
}


function message(){
  if [ -n "$2" ] ; then
    case "$2" in
      '-t') # title
        echo -ne "\n\r${C_NRM}${BOLD}------> ${C_TIT}${BOLD}$1 ${C_NRM}${BOLD}<-----------${NC}\n\r"
        echo "" |& tee -a $LOG_FILE &> /dev/null
        echo "------> $1 <-----------" |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-e') # error
        echo -ne "${C_ERR}${BLINK}ERROR${NC}${C_NRM}->${C_ERR} ${BOLD}$1 ${NC}\n\r"
        echo "ERROR-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-w') # worning
        echo -ne "${C_NRM}------>${C_WOR} $1 ${NC}\n\r"
      ;;
      '-c') # correct ✓
        echo -ne "${C_NRM}[${GREEN}✓${C_NRM}]--->${C_COR} $1 ${NC}\n\r"
        echo "[✓]---> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-m') # message
        echo -ne "${C_NRM}------>${C_MES} $1 ${NC}\n\r"
        echo "" |& tee -a $LOG_FILE &> /dev/null
        echo "------> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-q') # question
        echo -ne "${C_NRM}------> ${BOLD}$1: ${C_QST}${BOLD}"
      ;;
    esac
  else
    echo -ne "${C_NRM}------> $1 ${NC}\n\r"
    echo "------> $1 " |& tee -a $LOG_FILE &> /dev/null
  fi
}

function get_param(){
  if [ -n "$1" ] ; then
    PARAM=""
    while [ "" == "$PARAM" ] ; do
      message "$1" "-q"
      read PARAM
      echo -ne "${NC}"
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
    while true ; do
      message "$1" "-q"
      read PARAM
      echo -ne "${NC}"
      if [ -d "$HOME/$PARAM" ] ; then
        message "Katalog [ $HOME/$PARAM ] już istnieje!" "-w"
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
      echo "---> Repozytorium gita=BRAK" |& tee -a $LOG_FILE &> /dev/null
      break
    else
      message "Sprawdzanie repozytorium!" "-m"
      git clone --depth 1 --single-branch $PARAM /tmp/$PROJ_DIR &> /dev/null

      if [ $? -eq 0 ] ; then
        rm -rf /tmp/$PROJ_DIR
        GIT_LINK=$PARAM
        C_CGIT=1
        echo "---> Repozytorium gita=$GIT_LINK" |& tee -a $LOG_FILE &> /dev/null
        message "Sprawdź w repozytorium nazwę katalogu projektu Django!" "-w"
        message "I wpisz ją tak samo niżej!" "-w"
        break
      else
        message "Błędny adres repozytorium!" "-w"
      fi
    fi
  done  
}

function get_django_conf(){  
  check_dir "Podaj katalog aplikacji ~/"
  PROJ_DIR=$PARAM
  echo "---> Ktalog projektu=$HOME/$PROJ_DIR" |& tee -a $LOG_FILE &> /dev/null

  get_param "Załadować aplikacje z Githuba? [n/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    get_git_clone_config
  else
    C_CGIT=0
    echo "---> Repozytorium gita=BRAK" |& tee -a $LOG_FILE &> /dev/null    
  fi
  get_param "Podaj katalog projektu Django: ~/$PROJ_DIR/"
  DJANGO_DIR=$PARAM
  echo "---> Katalog projektu Django=$HOME/$PROJ_DIR/$DJANGO_DIR" |& tee -a $LOG_FILE &> /dev/null
}

function get_conf_service(){
  get_param "Utworzyć usługę systemową dla aplikacji? gunicor + nginx [n/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    get_param "Podaj nazwa usługi systemowej (bez spacji)"
    C_SYS_NAME=$PARAM
    echo "---> Nazwa usługi systemowej=${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null

    get_param "Podaj opis usługi systemowej"
    C_SYS_DESCRIPTION=$PARAM
    echo "---> Opis usługi systemowej=${C_SYS_DESCRIPTION}" |& tee -a $LOG_FILE &> /dev/null

    get_param "Podaj liste hostów dla nginx: host0,host1.."
    C_SYS_HOSTS=$PARAM
    echo "---> Lista hostów nginx=${C_SYS_HOSTS}" |& tee -a $LOG_FILE &> /dev/null
    C_SERVICE=1
  else
    C_SERVICE=0
  fi
}

function get_config_psql_db(){
  while true ; do
    get_param "Podaj nazwę bazy"
    PSQL_NAME=$PARAM
    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$PSQL_NAME'"`
    if [ "$x" == "" ] ; then
      echo "---> Nazwa bazy postgresql=${PSQL_NAME}" |& tee -a $LOG_FILE &> /dev/null
      break
    else
      message "Baza danych już istnieje" "-w"
    fi
  done
}

function get_config_psql_user(){
  while true ; do
    if [ "$PSQL_USER" == "" ] ; then
      get_param "Podaj nazwę użytkownika bazy"
      PSQL_USER=$PARAM
    else
      message "Jeśli nie znasz hasła dla użytkonika $PSQL_USER konfiguracja nie będzie poprawna!" "-m"
      get_param "Czy użyć użytkownika [t/n]" "TtNn"
      if [ "$PARAM" == "N" ] || [ "$PARAM" == "n" ] ; then
        get_param "Podaj nazwę użytkownika bazy danych"
        PSQL_USER=$PARAM
      else
        break
      fi
    fi

    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
    if [ "$x" == "" ] ; then      
      break
    else
      message "Użytkownik baza danych już istnieje" "-w"
    fi
  done
  echo "---> Nazwa użytkownika postgresql=${PSQL_USER}" |& tee -a $LOG_FILE &> /dev/null
  while true ; do
    message "Podaj hasło" "-q"
    read -s PSQL_PASS
    echo -ne "${NC}\n\r"

    message "Podaj ponownie hasło" "-q"
    read -s PARAM
    echo -ne "${NC}\n\r"
    if [ "$PSQL_PASS" == "$PARAM" ] ; then
    C_PSQL=1
      break
    else
      message "Hasła nie są zgodne" "-w"
    fi
  done

  get_param "Zapisać wszystkie hasła w pliku log? [n/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    C_PASS_LOG=1 
    echo "---> Hasło użytkownika postgresql=${PSQL_PASS}" |& tee -a $LOG_FILE &> /dev/null
  else
    C_PASS_LOG=0
  fi

}

function get_config_psql(){
  C_PSQL=0
  get_param "Utworzyć konfiguracje bazy postgresql? [n/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    echo "---> Baza postgresql=TAK" |& tee -a $LOG_FILE &> /dev/null
    
    get_config_psql_db
    get_config_psql_user
  else
    C_PSQL=0
    echo "---> Baza postgresql=NIE" |& tee -a $LOG_FILE &> /dev/null
  fi
}

function get_config_user(){
  get_logo
  message "KONFIGURACJA DJANGO" "-m"
  get_django_conf

  message "KONFIGURACJA BAZY POSTGRES" "-m"
  get_config_psql

  message "KONFIGURACJA USŁUGI SYSTEMOWEJ" "-m"
  get_conf_service
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
  message "KONFIGURACJA INSTALATORA" "-t"
  get_param "Modyfikacja prompt'a termianal? [*/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    echo "---> Modyfikacja prompt'a termianal=TAK" |& tee -a $LOG_FILE &> /dev/null
    C_PROMPT=1
  else
    echo "---> Modyfikacja prompt'a termianal=NIE" |& tee -a $LOG_FILE &> /dev/null
    C_PROMPT=0
  fi

  get_param "Instalacja i konfiguracja narzędzi? [*/t]" "TtNn"
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    echo "---> Instalcja i konfiguracja narzędzi=TAK" |& tee -a $LOG_FILE &> /dev/null
    C_TOOLS=1
  else
    echo "---> Instalcja i konfiguracja narzędzi=NIE" |& tee -a $LOG_FILE &> /dev/null
    C_TOOLS=0
  fi

  if [ "$USER" == "root" ] ; then
    get_config_root
  else
    get_config_user
  fi
}

# message "KONFIGURACJA INSTLATORA" "-t"
# message "instalacja message" "-m"
# message "instalacja question" "-q"
# read x 
# echo -ne "${NC}"
# message "instalacja correct" "-c"
# message "instalacja worning" "-w"
# message "instalacja error" "-e"
# message "instalacja narzedzi"