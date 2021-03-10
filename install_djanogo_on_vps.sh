#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

source config_script.sh

sudo ls > /dev/null

echo -ne "\n\r${C_TIT}${BOLD}------> INSTALL DJANGO <-----------[ ${currentDate} ${currentTime} ]${NC}\n\r"
echo "" |& tee -a $LOG_FILE &> /dev/null
echo "------> INSTALL DJANGO <-----------[ ${currentDate} ${currentTime} ]" |& tee -a $LOG_FILE &> /dev/null

get_config

function install_prog(){
    for i in $@ ; do
        sudo dpkg -s $i &> /dev/null
        if [ $? -eq 0 ] ; then
            #soft_config $i
            message "Program $i jest już zainstalowany" "-w"
        else
            message "Instalacja $i" "-m"
            sudo apt-get install -y $i |& tee -a $LOG_FILE &> /dev/null
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
                #soft_config $i
            fi
        fi
    done
}

function get_pip_install(){
    for i in $@ ; do
        x=`pip3 list | grep $i | wc -l`
        if [ $x -eq 0 ] ; then
            message "Instalacja biblioteki $i"
            pip3 install $i |& tee -a $LOG_FILE &> /dev/null
            x=`pip3 list | grep $i | wc -l`
            if [ $x -eq 0 ] ; then
                message "Instalacji biblioteki $i." "-e"
                exit
            else
                message "Zainstalowano bibliotekę $i." "-c"
            fi
        else
            message "Biblioteka $i jest już zainstalowana."
        fi
    done
}

function get_firtualenv(){
    message "ŚRODOWISKO VIRTUALENV" "-t"

    get_pip_install virtualenv
    
    message 'Konfiguracja środowiska virtualenv'
    cd $HOME/$PROJ_DIR
    virtualenv -p python3 venv |& tee -a $LOG_FILE &> /dev/null
    if [ -d "venv" ] ; then
        message "Utworzenie środowiska virtualenv." "-c"
        cd $HOME/$PROJ_DIR
        . venv/bin/activate
        message 'Aktywacja środowiska virtualenv' "-c"
        message 'Instalacja wymaganych bibliotek' "-m"
        get_pip_install psycopg2-binary Django django-rest
    else
        message "Nie udane utworzenie środowiska virtualenv." "-e"
    fi
}

if [ $C_TOOLS -eq 1 ] ; then
    message 'Aktualizacja repozytorium' "-m"
    sudo apt-get update |& tee -a $LOG_FILE &> /dev/null
    message 'Wykonane' "-c"

    message 'Aktualizacja systemu' "-m"
    sudo apt-get upgrade -y |& tee -a $LOG_FILE &> /dev/null
    message 'Wykonane' "-c"
    message 'INSTALACJA NARZĘDZI' "-m"
    install_prog git vim links bc python3-pip python3-dev postgresql postgresql-contrib nginx

    message 'CZYSZCZENIE' "-m"
    sudo apt-get purge nginx bc -y |& tee -a $LOG_FILE &> /dev/null
    sudo apt-get autoremove -y |& tee -a $LOG_FILE &> /dev/null    
fi

if [ "$PROJ_DIR" != "" ] ; then
    mkdir $HOME/$PROJ_DIR
    if [ $? -eq 0 ] ; then
        message "Utworzono katalog projektu $HOME/$PROJ_DIR." "-c"
    else
        message "Nie utoworzono $HOME/$PROJ_DIR." "-w"
    fi

    if [ $C_CGIT -eq 1 ]; then
        git clone $GIT_LINK $HOME/$PROJ_DIR &> /dev/null

        if [ $? -eq 0 ] ; then
            message "Pomyślnie pobrano repozytorium $GIT_LINK." "-c"
            get_firtualenv
        else
            message "Pobieranie repozytorium $GIT_LINK." "-e"
        fi
    else
        cd $HOME/$PROJ_DIR
        git init
        if [ $? -eq 0 ] ; then
            message "Pomyślnie zinicjowano puste repozytorium w katalogu $HOME/$PROJ_DIR." "-c"
            get_firtualenv
            message "Django budowanie projektu." "-T"
            cd $HOME/$PROJ_DIR
            django-admin startproject $DJANGO_DIR
            message "django-admin startproject $DJANGO_DIR." "-c"
        else
            message "Nie udana inicjalizacja repozytorium w katalogu $HOME/$PROJ_DIR." "-e"
        fi        
    fi
fi