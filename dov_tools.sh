#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

currentDate=$(date +"%F")
currentTime=$(date +"%T")

# -------- KONFIGURACJA SKRYPUT ---------------
REQUIRMENTS="psycopg2-binary Django django-rest djangorestframework"
LOG_NAME="log_${currentDate}_${currentTime}.log"
# -------------- KONIEC -----------------------
C_ERR="\e[0;31m"
C_WOR="\e[0;33m"
C_MES="\e[0;34m"
C_QST="\e[0;30m\e[100m"
C_COR="\e[0;32m"
C_TIT="\e[0;33m"
C_ROO="\e[0;35m"
C_MEN="\e[0;33m\e[1m"
C_NRM="\e[0;97m"
GREEN="\e[0;32m"
WHITE="\e[0;97m"
DM="\e[2m"
BLINK="\e[5m"
BOLD="\e[1m"
NORM="\e[21m"
NC="\e[40m\e[0m"

# LOG_FILE="log_file.log"
# if [ -f $LOG_FILE ] ; then
#   rm $LOG_FILE
# fi
DIR_SC=`pwd`
if [ "$USER" == "root" ] ; then
  LOG_FILE="$HOME/python_log/${LOG_NAME}"
  if [ ! -d $HOME/python_log ] ; then
    mkdir $HOME/python_log/
  fi
else
  LOG_FILE="$DIR_SC/${LOG_NAME}"
fi

SYS_UPDATE=0
T_COL=0
T_ROW=0
# sudo modprobe pcspkr > /dev/null

function init_script(){
    if [ ! -d ~/.init_log ] ; then
        mkdir ~/.init_log/
    fi
    cd ~/.init_log/
    if [ ! -f init_${currentDate}.log ] ; then
        message "Aktualizacja pakietów." "-w"
        sudo apt-get update
        message "Usunięcie zbędnych pakietów." "-w"
        sudo apt-get autoremove -y
        message "Aktualizacja systemu." "-w"
        sudo apt-get upgrade -y
        message "Aktualizacja pip." "-w"
        pip3 install --upgrade pip
        rm *.*
        touch init_${currentDate}.log
    fi
    sudo dpkg -s pv &> /dev/null
    if [ $? -eq 1 ] ; then
        sudo apt-get install -y pv
        xup=1
    fi
    sudo dpkg -s figlet &> /dev/null
    if [ $? -eq 1 ] ; then
        sudo apt-get install -y figlet
    fi
    sudo dpkg -s ncurses-bin &> /dev/null
    if [ $? -eq 1 ] ; then
        sudo apt-get install -y ncurses-bin
    fi
}

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
        # local beep_num=0
        # while [ $beep_num -lt 5 ] ; do
        #   beep > /dev/null
        #   beep_num=$((beep_num + 1))
        #   sleep 0.25
        # done
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
        echo -ne "${C_NRM}  |${GREEN}?${C_NRM}|-> ${C_QST}$1: ${NC} "
        # beep > /dev/null
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
      if [ ! -z "$3" ] && [[ "$3" =~ ^[0-9]+$ ]] ; then
        read -n$3 PARAM
      else
        read PARAM
      fi
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
    figlet -t -k -f /usr/share/figlet/small.flf " $1  on VPS " |& tee -a $LOG_FILE
    echo -ne "${NC}${C_TIT}${BOLD}-----------------------------------------------------------------"
    echo "-----------------------------------------------------------------" |& tee -a $LOG_FILE &> /dev/null
    echo -ne "\n\r${C_TIT}W ramach szkolenia w ${BOLD}CodersLab${NC}"
    echo -ne "\n\r${C_TIT}  Autor: Piotr Michna${NC}"
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

    echo "W ramach szkolenia w CodersLab"
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
    echo "" |& tee -a $LOG_FILE
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

function get_user_git_config(){
    message "KONFIGRUACJA Gita" "-t"
    local guser=""
    guser=$(git config --global user.name)
    if [ "$guser" != "" ] ; then
        message 'Git został już skonfigurowany.' "-w"
    else
        message 'Konfigurowanie globalna użytkownika.' "-m"
        get_param 'Podaj Imię i nazwisko'
        local git_user=$PARAM
        get_param 'Podaj e-mail'
        local git_email=$PARAM
        git config --globa user.name $git_user &> /dev/null
        message "user.name $git_user" "-c"
        git config --globa user.email $git_email &> /dev/null
        message "user.email $git_email" "-c"
        git config --globa push.followtags true &> /dev/null
        message "push.followtags true" "-c"
        git config --globa alias.st "status" &> /dev/null
        message "alias st=status" "-c"
        git config --globa alias.ap "add -p" &> /dev/null
        message "alias ap=add -p" "-c"
        git config --globa alias.cm "commit -m" &> /dev/null
        message "alias cm=commit -m" "-c"
        git config --globa alias.ll "log -n 20 --all --graph --pretty --oneline" &> /dev/null
        message "alias ll=log -n 20 --all --graph --pretty --oneline" "-c"
        git config --globa alias.lb "branch -a -vv" &> /dev/null
        message "alias lb=branch -a -vv" "-c"
        git config --globa alias.df "diff" &> /dev/null
        message "alias df=diff" "-c"
        git config --globa alias.dfc "diff --chacek" &> /dev/null
        message "alias dfc=diff --chacek" "-c"
        git config --globa core.editor vim &> /dev/null
        message "core.editor vim" "-c"
    fi
    if [ ! -z "$1" ] ; then
        get_param 'Wybierz [x] aby zakończyć' "Xx"
    fi
}

function get_user_config_vim(){
    message "KONFIGRUACJA Vima" "-t"
    if [ -f $HOME/.vimrc ] ; then
        message 'Vim został już skonfigurowany.' "-m"
    else
        echo "set number" >> $HOME/.vimrc ; message "set number" "-c"
        echo "set autoindent" >> $HOME/.vimrc ; message "set autoindent" "-c"
        echo "set history=1000" >> $HOME/.vimrc ; message "set history=1000" "-c"
        echo "set title" >> $HOME/.vimrc ; message "set title" "-c"
        echo "set tabpagemax=50" >> $HOME/.vimrc ; message "set tabpagemax=50" "-c"
        echo "set tabstop=8" >> $HOME/.vimrc ; message "set tabstop=8" "-c"
        echo "set expandtab" >> $HOME/.vimrc ; message "set expandtab" "-c"
        echo "set shiftwidth=4" >> $HOME/.vimrc ; message "set shiftwidth=4" "-c"
        echo "set softtabstop=4" >> $HOME/.vimrc ; message "set softtabstop=4" "-c"

        echo "set ignorecase" >> $HOME/.vimrc ; message "set ignorecase" "-c"
        echo "set smartcase" >> $HOME/.vimrc ; message "set smartcase" "-c"
        echo "set incsearch" >> $HOME/.vimrc ; message "set incsearch" "-c"
    fi
    if [ ! -z "$1" ] ; then
        get_param 'Wybierz [x] aby zakończyć' "Xx"
    fi
}

function get_prompt(){
    message 'MODYFIKACJA PROMPT' "-t"
    message "Sprawdzanie konfiguracji." "-m"
    x=`pwd`
    message "Aktualny katalog: $x" "-c"
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
            sudo cp git_venv_prompt.sh "$HOME/.git_venv_prompt.sh"

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
    if [ ! -z "$1" ] ; then
        get_param 'Wybierz [x] aby zakończyć' "Xx"
    fi
}

function get_git_clone_config(){  
  while true ; do
    get_param "Podaj adres repozytorium aplikacji [q-quit]"

    if [ "$PARAM" == "Q" ] || [ "$PARAM" == "q" ] ; then
      C_CGIT=0
      echo "--|✓|-> Repozytorium gita=BRAK" |& tee -a $LOG_FILE &> /dev/null
      break
    else
      if [ "$PROJ_DIR" == "" ] ; then
        PROJ_DIR="dxd"
      fi
      message "Sprawdzanie repozytorium!" "-m"
      if [ -d /tmp/$PROJ_DIR ] ; then
        sudo rm /tmp/$PROJ_DIR
      fi
      sudo mkdir /tmp/$PROJ_DIR
      sudo git clone --depth 1 --single-branch $PARAM /tmp/$PROJ_DIR &> /dev/null

      if [ $? -eq 0 ] ; then
        sudo rm -rf /tmp/$PROJ_DIR
        GIT_LINK=$PARAM
        C_CGIT=1
        message "Link do repozytorium=$GIT_LINK" "-c"
        message "Sprawdź w repozytorium nazwę katalogu projektu Django!" "-w"
        message "I wpisz ją tak samo w następnym kroku!" "-w"
        break
      else
        C_CGIT=0
        message "Błędny adres repozytorium!" "-w"
      fi
    fi
  done  
}

function get_config_psql(){
  message 'KONFIGURACJA BAZY PostgreSQL' "-t"
  get_param "Utworzyć bazę  PostgreSQL [t/n]" "TtNn"
  PSQL_C=0
  if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
    local is_psql=0
    sudo dpkg -s postgresql &> /dev/null
    if [ $? -eq 0 ] ; then
      is_psql=1
    fi

    while true ; do
      get_param "Podaj nazwę bazy"
      PSQL_NAME=$PARAM
      if [ $is_psql -eq 1 ] ; then
        x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$PSQL_NAME'"`
        if [ "$x" == "" ] ; then
          PSQL_C=1
          break
        else
          message "Baza danych już istnieje" "-w"
        fi
      else
        if [ $PSQL_NAME != 'postgres' ] ; then
          PSQL_C=1
          break
        fi
      fi
    done

    if [ $PSQL_C -eq 1 ] ; then
      echo "--|✓|-> Nazwa bazy PostgreSQL=$PSQL_NAME" |& tee -a $LOG_FILE &> /dev/null
      PSQL_USER=""
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
        if [ $is_psql -eq 1 ] ; then
          x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
          if [ "$x" == "" ] ; then
            break
          else
            message "Użytkownik baza danych już istnieje" "-w"
          fi
        else
          if [ $PSQL_USER != 'postgres' ] ; then
            break
          fi
        fi
      done
      echo "--|✓|-> Nazwa użytkownika bazy PostgreSQL=$PSQL_USER" |& tee -a $LOG_FILE &> /dev/null
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
      get_param "Zapisać hasła w pliku log? [t/n]" "TtNn"
      if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
        echo "--|✓|-> Hasło użytkownika postgresql=${PSQL_PASS}" |& tee -a $LOG_FILE &> /dev/null
      fi
    fi
  fi
}

function get_postgresql(){
    message "BAZA PostreSQL" "-t"
    install_prog postgresql postgresql-contrib
    message "Tworzenie bazy postgresql $PSQL_NAME" "-m"
    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$PSQL_NAME'"`
    if [ "$x" != "" ] ; then
      message "Baza danych $PSQL_NAME juź istnieje" "-w"
    else
      sudo -u postgres psql -c "CREATE DATABASE $PSQL_NAME" |& tee -a $LOG_FILE &> /dev/null
      x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$PSQL_NAME'"`
      if [ "$x" != "" ] ; then
        message "Baza danych $PSQL_NAME utworzona." "-c"
      else
        message "Błąd tworzenia baza danych." "-e"
        get_exit "Błąd tworzenia baza danych $PSQL_NAME."
      fi
    fi
    message "Tworzenie użytkownika postgresql $PSQL_USER" "-m"
    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
    if [ "$x" == "" ] ; then
      sudo -u postgres psql -c "CREATE USER $PSQL_USER WITH PASSWORD '${PSQL_PASS}'" |& tee -a $LOG_FILE &> /dev/null
      x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
      if [ "$x" != "" ] ; then
        message "Dodano użytkownika $PSQL_USER" "-c"
      else
        message "Błąd tworzenia użytkownika $PSQL_USER" "-e"
        get_exit "Błąd tworzenia użytkownika $PSQL_USER"
      fi

      message "Uprawnienia bazy danych" "-m"
      sudo -u postgres psql -c "ALTER ROLE $PSQL_USER SET client_encoding TO 'utf8'" |& tee -a $LOG_FILE &> /dev/null
      message "Kodowanie utf8" "-c"
      sudo -u postgres psql -c "ALTER ROLE $PSQL_USER SET default_transaction_isolation TO 'read committed'" |& tee -a $LOG_FILE &> /dev/null
      message "read committed" "-c"
      sudo -u postgres psql -c "ALTER ROLE $PSQL_USER SET timezone TO 'Europe/Warsaw'" |& tee -a $LOG_FILE &> /dev/null
      message "Strefa czasowaEurope/Warsaw" "-c"
      sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $PSQL_NAME TO $PSQL_USER" |& tee -a $LOG_FILE &> /dev/null
      message "Nadanie uprawnień $PSQL_USER do bazy $PSQL_NAME" "-c"
    else
      message "Użytkownik baza danych już istnieje" "-w"
      message "Uprawnienia bazy danych" "-m"
      sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $PSQL_NAME TO $PSQL_USER" |& tee -a $LOG_FILE &> /dev/null
      message "Nadanie uprawnień $PSQL_USER do bazy $PSQL_NAME" "-c"
    fi
}

function system_update(){
  message 'UAKTUALNIENIE SYSTEMU' "-m"
  message 'Aktualizacja pakietów.' "-m"
  sudo apt-get update | pv -w 50 -l -c | tee -a $LOG_FILE | display_progres $C_MES
  message 'Ukończona aktualizacja pakietów' "-c"
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

function venv_activate(){
  message "Aktywacja środowiska virtualenv." "-m"
  cd "${HOME}/${PROJ_DIR}"
  if [ -d "venv" ] ; then
    x=`which python3`
    if [ "$x" == "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
      message "Środowisko virtualenv było włączone." "-m"
    else
      . venv/bin/activate
      x=`which python3`
      if [ "$x" == "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
        message "ON środowisko virtualenv." "-c"
      else
        message "Nie udane wyłączenie środowiska virtualenv." "-e"
        get_exit "Brak środowiska virtualenv"
      fi
    fi
  fi
}

function venv_deactivate(){
  message "Deaktywacja środowiska virtualenv." "-m"
  cd ${HOME}/${PROJ_DIR}
  x=`which python3`
  if [ "$x" == "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
    deactivate
    x=`which python3`
    if [ "$x" != "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
      message "OFF środowisko virtualenv." "-c"
    else
      message "Nie udane wyłączenie środowiska virtualenv." "-e"
      get_exit "Błąd wyłączenie środowiska virtualenv"
    fi
  else
    message "Środowiska virtualenv nie było aktywne." "-m"
  fi
}

function get_pip_install(){
  PIP_END=0
  for i in $@ ; do
    local lib_name=""
    local j=$i
    x=`echo $j | grep "==" | wc -l`
    if [ $x -eq 1 ] ; then
      oldIFS="$IFS"
      IFS='=='; j=($j)
      lib_name="$j"
      IFS="$oldIFS"
    else
      lib_name=$i
    fi
    x=`pip3 list | grep $lib_name | wc -l`
    if [ $x -eq 0 ] ; then
        message "Instalacja biblioteki $i" "-m"
        pip3 install "$i" |& tee -a $LOG_FILE
        x=`pip3 list | grep $lib_name | wc -l`
        if [ $x -eq 0 ] ; then
            message "Instalacji biblioteki $i." "-e"
            get_exit
        else
            message "Zainstalowano bibliotekę $i." "-c"
            PIP_END=1
        fi
    else
        message "Biblioteka $i jest już zainstalowana." "-w"
        PIP_END=1
    fi
  done
}

function get_install_lib(){
  message "INSTALACJA BIBLIOTEK" "-t"
  message "Szukanie pliku requirements.txt" "-m"

#   local requirments_file="asgiref==3.2.7
# Django==3.0.6
# Faker==4.1.0
# psycopg2-binary==2.8.5
# python-dateutil==2.8.1
# pytz==2020.1
# six==1.14.0
# sqlparse==0.3.1
# text-unidecode==1.3"
#   echo "$requirments_file" > "${HOME}/${PROJ_DIR}/requirements.txt"

  if [ -f "${HOME}/${PROJ_DIR}/requirements.txt" ] ; then
    message "Czytanie pliku requirements.txt" "-m"
    n=0
    while read p; do
      n=$((n+1))
      get_pip_install $p
    done <${HOME}/${PROJ_DIR}/requirements.txt
  else
    get_pip_install $REQUIRMENTS
  fi
}

function get_virtualenv(){
  message "ŚRODOWISKO VIRTUALENV" "-t"
  x=`pip3 list | grep virtualenv | wc -l`
  if [ $x -eq 0 ] ; then
    message 'Instalacja virtualenv' "-m"
    pip3 install virtualenv |& tee -a $LOG_FILE
    x=`pip3 list | grep virtualenv | wc -l`
    if [ $x -eq 1 ] ; then
        message 'Zainstalowano virtualenv' "-c"
    else
        message 'Błąd instalacji virtualenv' "-e"
        get_exit 'Błąd instalacji virtualenv'
    fi
  fi
  x=`pip3 list | grep virtualenv | wc -l`
  if [ $x -eq 1 ] ; then
    message 'Tworzenie środowiska virtualenv' "-m"
    cd ${HOME}/${PROJ_DIR}
    virtualenv -p python3 venv | tee -a $LOG_FILE | display_progres $C_MES
    if [ -d "venv" ] ; then
        message "Utworzono środowisko virtualenv." "-c"
        venv_activate
        get_install_lib
    else
        message "Nie udane utworzenie środowiska virtualenv." "-e"
        get_exit "Budowanie virtualenv"
    fi
  fi
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
    #get_param "Struktura katalogów jest zrozumiała? [t/n]" "TtNn"
    #get_prompt
    install_prog nginx
    get_git_clone_config
    end_script
    get_exit "BŁĄD INSTALACJI!"
fi