#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

source config_script.sh

sudo ls > /dev/null

echo -ne "\n\r${C_TIT}${BOLD}------> INSTALL DJANGO <-----------[ ${currentDate} ${currentTime} ]${NC}\n\r"
echo "" |& tee -a $LOG_FILE &> /dev/null
echo "------> INSTALL DJANGO <-----------[ ${currentDate} ${currentTime} ]" |& tee -a $LOG_FILE &> /dev/null

get_config

if [ $C_TOOLS -eq 1 ] ; then
    message 'Aktualizacja repozytorium' "-m"
    sudo apt-get update |& tee -a $LOG_FILE &> /dev/null
    message 'Wykonane' "-c"

    message 'Aktualizacja systemu' "-m"
    sudo apt-get upgrade -y |& tee -a $LOG_FILE &> /dev/null
    message 'Wykonane' "-c"
    message 'INSTALACJA NARZĘDZI' "-m"
    
fi
