#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

source config_script.sh
source lib_django.sh

sudo ls > /dev/null

echo -ne "\n\r${C_TIT}${BOLD}------> INSTALL DJANGO <-----------[ ${currentDate} ${currentTime} ]${NC}\n\r"
echo "" |& tee -a $LOG_FILE &> /dev/null
echo "------> INSTALL DJANGO <-----------[ ${currentDate} ${currentTime} ]" |& tee -a $LOG_FILE &> /dev/null

get_config

function get_prompt(){
    message 'MODYFIKACJA PROMPT' "-t"
    message "Sprawdzanie konfiguracji" "-m"
    x=`ls -a $HOME | grep .git_venv_prompt.sh | wc -l`

    if [ $x -gt 0 ] ; then
        message "Prompt jest już skonfigurowany" "-w"
    else
        local link_bash=""
        x=`ls -a $HOME | grep .bashrc | wc -l`
        if [ $x -eq 1 ] ; then
            message "Sprawdzanie pliku .bashrc." "-m"
            link_bash="${HOME}/.bashrc"
        else
            x=`ls -a $HOME | grep .bash_profile | wc -l`
            if [ $x -eq 1 ] ; then
                message "Sprawdzanie pliku .bash_profile." "-m"
                link_bash="${HOME}/.bash_profile"
            else
                message "Brak pliku .bashrc lub .bash_profile w katalogu domowym użytkownika!" "-e"
                get_exit
            fi
        fi

        if [ "$link_bash" != "" ] ; then
            message "Kopiowanie skryptu .git_bash_prompt.sh do katalogu domowego." "-m"
            cp git_venv_prompt.sh "$HOME/.git_bash_prompt.sh"

            x=`ls -a $HOME | grep .git_venv_prompt.sh | wc -l`
            if [ $x -gt 0 ] ; then
                message "Skrypt .git_bash_prompt.sh w katalogu domowym." "-c"
                echo "source ~/git_venv_prompt.sh" > $link_bash
            fi

        fi
    fi
}

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

if [ $C_TOOLS -eq 1 ] ; then
    message 'UAKTUALNIENIE SYSTEMU' "-t"
    message 'Aktualizacja repozytorium' "-m"
    sudo apt-get update |& tee -a $LOG_FILE &> /dev/null
    message 'Wykonane' "-c"

    message 'Aktualizacja systemu' "-m"
    sudo apt-get upgrade -y |& tee -a $LOG_FILE &> /dev/null
    message 'Wykonane' "-c"
    message 'INSTALACJA NARZĘDZI' "-t"
    install_prog git vim links bc python3-pip python3-dev postgresql postgresql-contrib nginx

    # message 'CZYSZCZENIE' "-m"
    # sudo apt-get purge nginx bc -y |& tee -a $LOG_FILE &> /dev/null
    # sudo apt-get autoremove -y |& tee -a $LOG_FILE &> /dev/null    
fi

get_django

if [ $C_PSQL -eq 1 ] ; then
    get_postgresql
fi

if [ "$PROJ_DIR" != "" ] ; then    
    get_django_settings    
fi

if [ $C_SERVICE -eq 1 ] ; then
    get_nginx
    get_service
fi