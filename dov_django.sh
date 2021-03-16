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

if [ "$0" == "./dov_django.sh" ] || [ "$0" == "dov_django.sh" ] ; then
    sudo ls > /dev/null
fi