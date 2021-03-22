#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl
# created: 17.03.2021 

source dov_tools.sh


function get_required_install_tools(){
    message "AKTUALIZACJA I INSTALACJA" "-t"
    install_prog vim git links curl bc python3 python3-dev python3-pip
    pip3 install --upgrade pip
    pip3 install virtualenv
    if [ ! -z "$1" ] ; then
        get_param 'Wybierz [x] aby zakończyć' "Xx"
    fi
}

function add_user(){
    message "TWORZENIE UŻYTKOWNIKA" "-t"
    while true ; do
        get_param 'Podaj nazwę użytkownika'
        local username="$PARAM"
        grep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ] ; then
            message "Użytkownik już istnieje" "-w"
        else
            break
        fi
    done

    while true ; do
        message "Podaj hasło" "-q"
        read -s password
        echo -ne "${NC}\n\r"

        message "Podaj ponownie hasło" "-q"
        read -s user_pass
        echo -ne "${NC}\n\r"

        if [ ${#password} -gt 2 ] && [ "$password" == "$user_pass" ] ; then
            break
        else
          message "Hasła nie są zgodne lub za mało znaków" "-w"
        fi
    done
    user_pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
    useradd -m -p "$user_pass" "$username" -s /bin/bash
    if [ $? -eq 0 ] ; then
        message "Utworzono użytkownika $username" "-c"
        usermod -aG sudo "$username"
        message "Dodano użytkownika do grupy sudo" "-c"
    else
        message "Nie udane tworzenie użytkownika!" "-w"
    fi
    if [ ! -z "$1" ] ; then
        get_param 'Wybierz [x] aby zakończyć' "Xx"
    fi
}

function get_all_prompt(){
    message 'MODYFIKACJA PROMPT' "-t"
    message "Sprawdzanie konfiguracji." "-m"
    x=`ls -a /etc/skel/ | grep .git_venv_prompt.sh | wc -l`
    if [ $x -eq 1 ] ; then
        message "Prompt jest zmodyfikowany." "-q"
        echo -ne "\n\r"
        get_param 'Przywrucić domyślny prompt? [t/n]' "TtNn"
        if [ "$PARAM" == "t" ] || [ "$PARAM" == "T" ] ; then
            message "Przywracanie domyślnej konfiguracji." "-m"
            rm /etc/skel/.git_venv_prompt.sh
            message "Kasowanie /etc/skel/.git_venv_prompt.sh" "-c"
            if [ -d $HOME/bash_back ] ; then
                message "Przywrócono domyślny .bashrc" "-c"
                rm /etc/skel/.bashrc
                cp $HOME/bash_back/.bashrc_back /etc/skel/.bashrc
            fi
            message "Przywrócono domyślny prompt" "-c"
        fi
    else
        message "Prompt jest domyślny." "-q"
        echo -ne "\n\r"
        get_param 'Dodać do prompt informacje o git i virtualev? [t/n]' "TtNn"
        if [ "$PARAM" == "t" ] || [ "$PARAM" == "T" ] ; then
            message "Modyfikowanie prompt." "-m"
            cp git_venv_prompt.sh /etc/skel/.git_venv_prompt.sh
            message "Kopiowanie git_venv_prompt.sh /etc/skel/.git_venv_prompt.sh" "-c"
            if [ ! -d $HOME/bash_back ] ; then
                mkdir $HOME/bash_back
                cp /etc/skel/.bashrc $HOME/bash_back/.bashrc_back
                message "Kopiowanie /etc/skel/.bashrc $HOME/bash_back/.bashrc_back" "-c"
            fi
            echo "source ~/.git_venv_prompt.sh" >> /etc/skel/.bashrc
            message "Modyfikacja /etc/skel/.bashrc" "-c"
            message "Zmodyfikowano prompt" "-c"
        fi
    fi
    if [ ! -z "$1" ] ; then
        get_param 'Wybierz [x] aby zakończyć' "Xx"
    fi
}

function get_root_all_task(){
    message "PRZYGOTOWANIE SERWERA" "-t"
    message "Nie zaleca się używać konta root." "-m"
    message "Jeśli tego nie zrobiłeś, dodaj użytkownika systemu." "-m"
    get_param 'Dodać użytkownika? [t/n]' "TtNn"
    if [ "$PARAM" == "t" ] ; then
        add_user
    fi

    get_required_install_tools

    if [ $(git config --global --list | grep alias.dfc | wc -l) -eq 0 ] ; then
        get_user_git_config
    fi

    sudo dpkg -s vim &> /dev/null
    if [ $? -eq 0 ] && [ ! -f ~/.vimrc ] ; then
        get_user_config_vim
    fi

    if [ ! -f ~/.git_venv_prompt.sh ] ; then
        get_prompt
    fi
}

function get_root_menu(){
    sudo ls &> /dev/null
    while true ; do
        while true ; do
            clear
            echo -ne "\n\r${NC}${C_ROO}${BOLD}-----------------------------------------------------------------"
            echo -ne "\n\r${C_ROO}${BOLD}"
            figlet -t -k -f /usr/share/figlet/small.flf "  - START  VPS - "
            echo -ne "${NC}${C_ROO}${BOLD}-----------------------------------------------------------------"
            echo -ne "\n\r${C_ROO}W ramach szkolenia w ${C_MES}${BOLD}CodersLab${NC}"
            echo -ne "\n\r${C_ROO}  Autor: Piotr Michna${NC}"
            echo -ne "\n\r${C_ROO}${DM} e-mail: pm@piotrmichna.pl"
            echo -ne "\n\r${C_ROO}${DM}   Data: 15.03.2021\n\r"

            echo -ne "\n\r${C_ROO}${DM} Skrypt przygotowany w oparciu o wirtualny serwer projektu:"
            echo -ne "\n\r${C_ROO} UW-TEAM.ORG Jakuba Mrugalskiego"
            echo -ne "\n\r${C_ROO}${DM}        Link: ${NC}${C_ROO}https://mikr.us${NC}\n\r"
            echo -ne "\n\r${C_ROO}         MIKR.US 1.0 ${BLINK}35zł/rok"
            echo -ne "\n\r${C_ROO}${DM}         RAM: ${NC}${C_ROO}256MB"
            echo -ne "\n\r${C_ROO}${DM} Technologia: ${NC}${C_ROO}OpenVZ 6${NC}"
            echo -ne "\n\r${C_ROO}${DM}      System: ${NC}${C_ROO}Ubuntu 16${NC}\n\r"
            echo -ne "\n\r${C_ROO}     Korzystając z tego linku https://mikr.us/?r=758803ea"
            echo -ne "\n\r${C_ROO}             otrzymasz dodatkowy miesiąc gratis.\n\r"

            echo -ne "\n\r${NC}${C_ROO}${BOLD}-----------------------------------------------------------------"

            PARAM=""
            sudo dpkg -s bc &> /dev/null
            if [ $? -eq 0 ] && [ $SYS_UPDATE -eq 0 ] ; then
                echo -ne "\n\r ${C_ROO} [${C_MEN}I${NC}${C_ROO}] Instalacja ${DM}- instalacja podstawowych narzędzi."
            else
                echo -ne "\n\r ${C_ROO}${DM} [I] Instalacja - instalacja podstawowych narzędzi."
            fi
            echo -ne "\n\r ${C_ROO} [${C_MEN}U${NC}${C_ROO}] Użytkownicy ${DM}- tworzenie urzytkowników systemowych."
            CHAR="iux"
            sudo dpkg -s vim &> /dev/null
            if [ $? -eq 0 ] && [ ! -f ~/.vimrc ] ; then
                CHAR="${CHAR}v"
                echo -ne "\n\r ${C_ROO} [${C_MEN}V${NC}${C_ROO}] Konfiguracja vim ${DM}- tworzenie pliku .vimrc."
            fi
            if [ ! -f ~/.gitconfig ] || [ $(git config --global --list | grep alias.dfc | wc -l) -eq 0 ] ; then
                CHAR="${CHAR}g"
                echo -ne "\n\r ${C_ROO} [${C_MEN}G${NC}${C_ROO}] Konfiguracja git ${DM}- aliasy komend."
            fi
            if [ ! -f ~/.git_venv_prompt.sh ] ; then
                CHAR="${CHAR}p"
                echo -ne "\n\r ${C_ROO} [${C_MEN}P${NC}${C_ROO}] Konfiguracja prompt ${DM}- dodanie git branch i virtualenv."
            fi
            if [ ! -f /etc/skel/.git_venv_prompt.sh ] ; then
                CHAR="${CHAR}s"
                echo -ne "\n\r ${C_ROO} [${C_MEN}S${NC}${C_ROO}] Konfiguracja prompt dla wszystkich ${DM}- dodanie git branch i virtualenv."
            else
                CHAR="${CHAR}s"
                echo -ne "\n\r ${C_ROO} [${C_MEN}S${NC}${C_ROO}] Konfiguracja prompt dla wszystkich ${DM}- przywrócenie domyślnych ustawień."
            fi
            echo -ne "\n\r ${C_ROO} [${C_MEN}A${NC}${C_ROO}] Wykonaj wszystko."
            echo -ne "\n\r ${C_ROO} [${C_MEN}X${NC}${C_ROO}] Koniec skryptu."
            echo -ne "\n\r ${NC} [ ] Wybierz literę.${C_MEN}\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b${NC}${C_ROO}"
            PARAM=""
            while true ; do
                read -N1 -s PARAM
                PARAM=$(echo "$PARAM" | tr '[:upper:]' '[:lower:]')
                x=$(echo $CHAR | grep $PARAM 2> /dev/null | wc -l 2> /dev/null)
                if [ "$PARAM" != "" ] && [ $x -eq 1 ] ; then
                    echo -ne "$PARAM"
                    break
                fi
            done
            echo -ne "\n\r${NC}${C_ROO}${BOLD}-----------------------------------------------------------------${NC}\r\n"
            if [ `echo $CHAR | grep $PARAM | wc -l` -eq 1 ] ; then
                break
            fi
            if [ `echo $CHAR | grep "g" | wc -l` -eq 1 ] ; then
                tput cuu1
            fi
            if [ `echo $CHAR | grep "v" | wc -l` -eq 1 ] ; then
                tput cuu1
            fi
            if [ `echo $CHAR | grep "p" | wc -l` -eq 1 ] ; then
                tput cuu1
            fi
            if [ `echo $CHAR | grep "s" | wc -l` -eq 1 ] ; then
                tput cuu1
            fi
            if [ "$PARAM" != "x" ] ; then
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            fi
        done

        case $PARAM in
            i)
                get_required_install_tools "w"
                PARAM=""
                ;;
            g)
                get_user_git_config "w"
                PARAM=""
                ;;
            v)
                get_user_config_vim "w"
                PARAM=""
                ;;
            p)
                get_prompt "w"
                PARAM=""
                ;;
            u)
                add_user "w"
                PARAM=""
                ;;
            a)
                get_root_all_task
                PARAM=""
                ;;
            s)
                get_all_prompt "w"
                PARAM=""
                ;;
        esac

        if [ "$PARAM" == "x" ] ; then
            break
        fi
    done

    #tput cnorm
}

if [ "$0" == "./dov_root.sh" ] || [ "$0" == "dov_root.sh" ] ; then
    init_script
    get_root_menu
fi