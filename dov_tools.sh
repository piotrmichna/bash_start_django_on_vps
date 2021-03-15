#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

C_ERR="\e[0;31m"
C_WOR="\e[0;33m"
C_MES="\e[0;34m"
C_QST="\e[0;42m\e[30m"
C_COR="\e[0;32m"
C_TIT="\e[0;33m"
C_NRM="\e[0;97m"
GREEN="\e[0;32m"
WHITE="\e[0;97m"
DM="\e[2m"
BLINK="\e[5m"
BOLD="\e[1m"
NC="\e[40m\e[0m"

currentDate=$(date +"%F")
currentTime=$(date +"%T")

DIR_SC=`pwd`
#LOG_FILE="$DIR_SC/log_${currentDate}_${currentTime}.log"
LOG_FILE="log_file.log"
if [ -f $LOG_FILE ] ; then
  rm $LOG_FILE
fi

SYS_UPDATE=0
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

function display_progres(){
    echo -ne "$1"
    while read -r data; do
        echo "---> $data" &> /dev/null
    done
    echo -ne "\e[1A\e[K\e[0m"
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
        echo "" |& tee -a $LOG_FILE &> /dev/null
        echo -ne "\n\r${C_TIT}------> ${BOLD}${1}${NC}${C_TIT}"
        echo -n "------> $1" |& tee -a $LOG_FILE &> /dev/null
        end_line_date
      ;;
      '-e') # error
        echo -ne "${C_ERR}${BLINK}ERROR${C_NRM}${NC}->${C_ERR} ${BOLD}$1 ${NC}\n\r"
        echo "ERROR-> $1 " |& tee -a $LOG_FILE &> /dev/null
        sudo modprobe pcspkr
        local beep_num=0
        while [ $beep_num -lt 5 ] ; do          
          beep
          beep_num=$((beep_num + 1))
          sleep 0.25 
        done
      ;;
      '-w') # worning
        echo -ne "${C_NRM}  |${C_WOR}!${C_NRM}|->${C_WOR} $1 ${NC}\n\r"
        echo "--|!|-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-c') # correct ✓
        echo -ne "  ${C_NRM}|${GREEN}✓${C_NRM}|->${C_COR} $1 ${NC}\n\r"
        echo "--|✓|-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-m') # message
        echo -ne "${C_NRM}  |${C_MES}i${C_NRM}|->${C_MES} $1 ${NC}\n\r"
        echo "--|i|-> $1 " |& tee -a $LOG_FILE &> /dev/null
      ;;
      '-q') # question
        echo -ne "${C_NRM}  |${C_QST}?${C_NRM}|-> ${C_QST}$1: ${NC} "
        sudo modprobe pcspkr
        beep
      ;;
    esac
  else
    echo -ne "${C_NRM}     -> $1 ${NC}\n\r"
    echo "------> $1 " |& tee -a $LOG_FILE &> /dev/null
  fi
}

function get_param(){
  if [ -n "$1" ] ; then
    PARAM=""
    while [ "" == "$PARAM" ] ; do
      message "$1" "-q"

      read PARAM
      echo -ne "\e[40m\e[0m"
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
      echo -ne "\e[49m"
      if [ -d "$HOME/$PARAM" ] ; then
        message "Katalog [ ~/$PARAM ] już istnieje!" "-w"
      else
        break
      fi
    done
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
    
    echo -ne "\n\r${NC}${C_TIT}${BOLD}-----------------------------------------------------------------"
    echo "-----------------------------------------------------------------" |& tee -a $LOG_FILE &> /dev/null
    echo "" |& tee -a $LOG_FILE &> /dev/null
}

function get_exit(){
    echo "" |& tee -a $LOG_FILE &> /dev/null
    echo -ne "\n\r${C_ERR}------> EXIT ERROR: ${1}"
    echo -n "------> EXIT ERROR: $1" |& tee -a $LOG_FILE &> /dev/null
    end_line_date
    echo -ne "${NC}"
    echo "" |& tee -a $LOG_FILE
    exit 0
}

function end_script(){
    echo "" |& tee -a $LOG_FILE &> /dev/null
    echo -ne "\n\r${C_TIT}------> ${BOLD}KONIEC SKRYPTU${NC}${C_TIT} "
    echo -n "------> KONIEC SKRYPTU " |& tee -a $LOG_FILE &> /dev/null
    end_line_date
    echo -ne "${NC}"
    echo "" |& tee -a $LOG_FILE
}

function get_project_tree(){
    echo -ne "     -> ${C_TIT}${BOLD}STRUKTURA CZYSTEGO PROJEKTU Django${NC}\n\r"
    echo -ne "     ->   ${C_MES}${BOLD}~/proj_app/ ${NC}${GREEN}${DM}# Katalog projektu${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${C_MES}${BOLD}.git/${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${C_MES}${BOLD}django_proj/ ${NC}${GREEN}${DM}# Katalog Django${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    + ${C_MES}${BOLD}django_proj/${NC}${GREEN}${DM} # Katalog głównej aplikacji Django${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    |    + ${WHITE}settings.py${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    |    + ${WHITE}local_settings.py${GREEN}${DM} # Plik generowany automatycznie.${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    + ${GREEN}${BOLD}manage.py${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${C_MES}${BOLD}venv${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${WHITE}${DM}.gitignore${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${WHITE}$LOG_FILE${GREEN}${DM} # Zapis logów konfiguracji i instalacji.${NC}\n\r\n\r"
}

function get_prompt(){
    message 'MODYFIKACJA PROMPT' "-t"
    message "Sprawdzanie konfiguracji." "-m"
    local flag=1
    x=`ls -a $HOME | grep .git_venv_prompt.sh | wc -l`
    if [ $x -eq 1 ] ; then
        message "Prompt jest już skonfigurowany." "-w"
        while true ; do
            get_param "Nadpisać konfiguracje prompt? [n/t]" "TtNn"
            if [ "$PARAM" == "N" ] || [ "$PARAM" == "n" ] ; then
              message "Pominięto  konfigurację prompt." "-m"
              flag=0
            fi
            break
        done
    fi
    if [ $flag -gt 0 ] ; then
        local link_bash=""
        x=`ls -a $HOME | grep .bashrc | wc -l`
        if [ $x -eq 1 ] ; then
            message "Sprawdzanie pliku .bashrc." "-c"
            link_bash=".bashrc"
        else
            x=`ls -a $HOME | grep .bash_profile | wc -l`
            if [ $x -eq 1 ] ; then
              message "Sprawdzanie pliku .bash_profile." "-c"
              link_bash=".bash_profile"
            else
              message "Brak pliku .bashrc lub .bash_profile w katalogu domowym użytkownika!" "-e"
              get_exit
            fi
        fi

        if [ "$link_bash" != "" ] ; then
            message "Kopiowanie skryptu .git_bash_prompt.sh do katalogu domowego." "-m"
            cp git_venv_prompt.sh "$HOME/.git_venv_prompt.sh"

            x=`ls -a $HOME | grep .git_venv_prompt.sh | wc -l`
            if [ $x -gt 0 ] ; then
                message "Skrypt .git_bash_prompt.sh w katalogu domowym." "-c"
                x=`cat ~/$link_bash | grep 'source ~/.git_venv_prompt.sh' | wc -l`
                if [ $x -eq 0 ] ; then
                  echo "source ~/.git_venv_prompt.sh" >> "${HOME}/$link_bash"
                  message "Dołączenie skryptu w pliku $link_bash." "-c"
                else
                  message "Dołączenie skryptu w pliku $link_bash istniało." "-m"
                fi
            fi

        fi
    fi
}

function system_update(){
  message 'UAKTUALNIENIE SYSTEMU' "-t"
  message 'Aktualizacja pakietów.' "-m"
  sudo apt-get update | pv -w 50 -l -c | tee -a $LOG_FILE | display_progres $C_MES
  message 'Ukończona aktualizacja pakietów' "-c"

  message 'Aktualizacja systemu.' "-m"
  sudo apt-get upgrade -y | pv -w 50 -l -c | tee -a $LOG_FILE | display_progres $C_MES
  message 'Ukończona aktualizacja systemu.' "-c"

  message 'Usunięcie zbędnych repozytoriów.' "-m"
  sudo apt-get autoremove -y | pv -w 50 -l -c | tee -a $LOG_FILE | display_progres $C_MES
  message 'Ukończone usuwanie zbędnych pakietów.' "-c"
  SYS_UPDATE=1
}

function install_prog(){
  if [ $SYS_UPDATE -eq 0 ] ; then
    system_update
  fi
  for i in $@ ; do
    sudo dpkg -s $i &> /dev/null
    if [ $? -eq 0 ] ; then
      message "Program $i jest już zainstalowany" "-w"
    else
      message "Instalacja $i" "-m"
      sudo apt-get install -y $i | pv -w 50 -l -c | tee -a $LOG_FILE | display_progres $C_MES
      sudo dpkg-query -l $i &> /dev/null

      if [ $? -eq 1 ] ; then
        message "Program $i nie został zainstalowany! zerknij do pliku $LOG_FILE w katalogu instalatora." "-e"
        message "Zerknij po informacje do pliku $LOG_FILE w katalogu instalatora." "-w"
        message "Konynuować działanie skryptu? [t/n]" "-q"
        while true ; do
          read x
          echo -ne "${NC}\n\r"
          if [ "$x" == "T" ] ||  [ "$x" == "t" ] ; then
            break
          else
            message "Przerwano wykonywanie skryptu" "-w"
            exit
          fi
        done
      else
        message "Program $i został zainstalowany." "-c"
      fi
    fi
  done
}

if [ "$0" == "./dov_tools.sh" ] || [ "$0" == "dov_tools.sh" ] ; then
    start_scripts
    message "TYTUŁ MODÓŁU" "-t"
    message "Błąd wykonywania instrukcji!" "-e"
    message "Użytkownik ddd_user już istnieje." "-w"
    message "Proces wykonywania instrukcji." "-m"
    message "Wykonywanie instrukcji." "-c"
    message "Wykonać instalację narzędzi? [t/n]" "-q"
    echo -ne "${NC}\n\r"
    message "Wiadomość informacyjna"
    get_project_tree
    get_param "Struktura katalogów jest zrozumiała? [t/n]" "TtNn"
    get_prompt
    install_prog nginx
    end_script
    get_exit "BŁĄD INSTALACJI!"
fi