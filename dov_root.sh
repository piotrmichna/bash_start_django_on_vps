#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl
# created: 17.03.2021 

source dov_tools.sh

function get_root_install_tools(){
    message "AKTUALIZACJA I INSTALACJA" "-t"
    install_prog vim git links curl bc
    get_param 'Wybierz [q] aby zakończyć' "qQ"
}

function get_root_menu(){
    #tput civis
    clear
    echo -ne "\n\r${NC}${C_TIT}${BOLD}-----------------------------------------------------------------"
    echo -ne "\n\r${C_TIT}${BOLD}"
    figlet -t -k -f /usr/share/figlet/small.flf " Python  on VPS "
    echo -ne "${NC}${C_TIT}${BOLD}-----------------------------------------------------------------"

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

    echo -ne "\n\r${NC}${C_TIT}${BOLD}-----------------------------------------------------------------"
    while true ; do
        echo -ne "\n\r ${C_TIT} [${C_MEN}I${NC}${C_TIT}] Instalacja ${DM}- instalacja podstawowych narzędzi."
        echo -ne "\n\r ${C_TIT} [${C_MEN}U${NC}${C_TIT}] Użytkownicy ${DM}- tworzenie urzytkowników systemowych."
        CHAR="IiUuXxPp"
        sudo dpkg -s vim &> /dev/null
        if [ $? -eq 0 ] ; then
            CHAR="${CHAR}Vv"
            echo -ne "\n\r ${C_TIT} [${C_MEN}V${NC}${C_TIT}] Konfiguracja vim ${DM}- tworzenie pliku .vimrc."
        fi
        sudo dpkg -s git &> /dev/null
        if [ $? -eq 0 ] ; then
            CHAR="${CHAR}Gg"
            echo -ne "\n\r ${C_TIT} [${C_MEN}G${NC}${C_TIT}] Konfiguracja git ${DM}- aliasy komend."
        fi
        echo -ne "\n\r ${C_TIT} [${C_MEN}P${NC}${C_TIT}] Konfiguracja prompt ${DM}- dodanie git branch i virtualenv."
        echo -ne "\n\r ${C_TIT} [${C_MEN}X${NC}${C_TIT}] Koniec skryptu."
        echo -ne "\n\r ${NC} [ ] Wybierz literę.${C_MEN}\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b${NC}${C_TIT}"
        read PARAM
        if [ `echo $CHAR | grep $PARAM | wc -l` -eq 1 ] ; then
            echo -ne "${NC}${C_TIT}${BOLD}-----------------------------------------------------------------\r\n"
            break
        fi
        if [ `echo $CHAR | grep "Gg" | wc -l` -eq 1 ] ; then
          tput cuu1
        fi
        if [ `echo $CHAR | grep "Vv" | wc -l` -eq 1 ] ; then
          tput cuu1
        fi
        tput cuu1
        tput cuu1
        tput cuu1
        tput cuu1
        tput cuu1
        tput cuu1
    done
    #tput cnorm
}

init_script
get_root_menu