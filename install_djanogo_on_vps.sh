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
