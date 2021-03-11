#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

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


if [ "$0" == "./lib_django.sh" ] || [ "$0" == "lib_django.sh" ] ; then
    echo "Skrypt z lib_django.sh"
fi