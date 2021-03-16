#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl
# created: 15.03.2021

source dov_tools.sh

function get_django_project_tree(){
    echo -ne "     -> ${C_TIT}${BOLD}STRUKTURA NOWEGO PROJEKTU Django${NC}\n\r"
    echo -ne "     ->   ~/proj_app/ ${NC}${GREEN}${DM}# Katalog projektu${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${C_MES}${BOLD}.git/${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${C_MES}${BOLD}django_proj/ ${NC}${GREEN}${DM}# Katalog projektu Django${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    + ${C_MES}${BOLD}django_proj/${NC}${GREEN}${DM} # Katalog głównej aplikacji Django${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    |    + ${WHITE}settings.py${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    |    + ${WHITE}local_settings.py${GREEN}${DM} # Plik generowany automatycznie.${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}|    + ${GREEN}${BOLD}manage.py${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${C_MES}${BOLD}venv${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${WHITE}${DM}.gitignore${NC}\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${WHITE}$LOG_NAME${GREEN}${DM} # Zapis logów konfiguracji i instalacji.${NC}\n\r\n\r"
    echo -ne "     ->        ${C_TIT}${BOLD}+ ${WHITE}readme.md${NC}\n\r"

    echo "     -> STRUKTURA NOWEGO PROJEKTU Django" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->   ~/proj_app/ # Katalog projektu" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        + .git/" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        + django_proj/ # Katalog projektu Django" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        |    + django_proj/ # Katalog głównej aplikacji Django" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        |    |    + settings.py" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        |    |    + local_settings.py # Plik generowany automatycznie." |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        |    + manage.py" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        + venv" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        + .gitignore" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        + $LOG_NAME # Zapis logów konfiguracji i instalacji.\n\r" |& tee -a $LOG_FILE &> /dev/null
    echo "     ->        + readme.md" |& tee -a $LOG_FILE &> /dev/null
}

function get_django_conf(){
    start_scripts "Django"
    message 'KONFIGURACJA Django' "-t"
    get_django_project_tree
    check_dir "Podaj katalog projektu ~/"
    PROJ_DIR=$PARAM
    echo "--|✓|-> Ktalog projektu=$HOME/$PROJ_DIR" |& tee -a $LOG_FILE &> /dev/null

    get_param "Załadować aplikacje z Githuba? [n/t]" "TtNn"
    if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
        echo "--|✓|-> Zdalne repozytorium git=TAK" |& tee -a $LOG_FILE &> /dev/null
        get_git_clone_config
    else
        C_CGIT=0
        echo "--|✓|-> Zdalne repozytorium git=NIE" |& tee -a $LOG_FILE &> /dev/null
    fi

    get_param "Podaj katalog projektu Django: ~/$PROJ_DIR/"
    DJANGO_DIR=$PARAM
    echo "--|✓|-> Katalog projektu Django=$HOME/$PROJ_DIR/$DJANGO_DIR" |& tee -a $LOG_FILE &> /dev/null
}

function get_conf_django_service(){
    message 'KONFIGURACJA USŁUGI SYSTEMOWEJ' "-t"
    get_param "Utworzyć usługę systemową dla aplikacji? gunicor + nginx [n/t]" "TtNn"
    if [ "$PARAM" == "T" ] || [ "$PARAM" == "t" ] ; then
        get_param "Podaj nazwa usługi systemowej (bez spacji)"
        C_SYS_NAME=$PARAM
        echo "--|✓|-> Nazwa usługi systemowej=${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null

        get_param "Podaj opis usługi systemowej"
        C_SYS_DESCRIPTION=$PARAM
        echo "--|✓|-> Opis usługi systemowej=${C_SYS_DESCRIPTION}" |& tee -a $LOG_FILE &> /dev/null

        get_param "Podaj liste hostów dla nginx: host0,host1.."
        C_SYS_HOSTS=$PARAM
        echo "--|✓|-> Lista hostów nginx=${C_SYS_HOSTS}" |& tee -a $LOG_FILE &> /dev/null
        C_SERVICE=1
    else
        C_SERVICE=0
    fi
}

function get_django(){
    get_django_conf
    get_config_psql
}

if [ "$0" == "./dov_django.sh" ] || [ "$0" == "dov_django.sh" ] ; then
    sudo ls > /dev/null
    get_django
fi