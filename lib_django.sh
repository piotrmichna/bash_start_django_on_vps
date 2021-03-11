#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

PYTHON_INSTAL_LIB="psycopg2-binary Django django-rest gunicorn"

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

function get_django(){
    mkdir $HOME/$PROJ_DIR
    if [ $? -eq 0 ] ; then
        message "Utworzono katalog projektu $HOME/$PROJ_DIR." "-c"
    else
        message "Nie utoworzono $HOME/$PROJ_DIR." "-w"
    fi

    if [ $C_CGIT -eq 1 ]; then
        git clone $GIT_LINK $HOME/$PROJ_DIR  |& tee -a $LOG_FILE &> /dev/null

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
}

if [ "$0" == "./lib_django.sh" ] || [ "$0" == "lib_django.sh" ] ; then
    echo "Skrypt z lib_django.sh"
    
fi