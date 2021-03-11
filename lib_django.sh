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

function get_virtualenv(){
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

function get_postgresql(){
    message "BAZA PostreSQL" "-t"
    message "Tworzenie bazy postgresql $PSQL_NAME"
    sudo -u postgres psql -c "CREATE DATABASE $PSQL_NAME" |& tee -a $LOG_FILE &> /dev/null

    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$PSQL_NAME'"`
    if [ "$x" != "" ] ; then
        message "Baza danych $PSQL_NAME istnieje" "-c"
    else
      message "Błąd tworzenia baza danych" "-e"
    fi
    message "Tworzenie użytkownika postgresql $PSQL_USER"
    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
    if [ "$x" == "" ] ; then
      sudo -u postgres psql -c "CREATE USER $PSQL_USER WITH PASSWORD '${PSQL_PASS}'" |& tee -a $LOG_FILE &> /dev/null
      x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
        if [ "$x" != "" ] ; then
            message "Dodano użytkownika $PSQL_USER" "-c"
        else
            message "Błąd tworzenia użytkownika $PSQL_USER" "-e"
        fi
    else
      message "Użytkownik baza danych już istnieje" "-m"
    fi
    message "Uprawnienia bazy danych" "-m"
    sudo -u postgres psql -c "ALTER ROLE $PSQL_USER SET client_encoding TO 'utf8'" |& tee -a $LOG_FILE &> /dev/null
    message "Kodowanie utf8" "-c"
    sudo -u postgres psql -c "ALTER ROLE $PSQL_USER SET default_transaction_isolation TO 'read committed'" |& tee -a $LOG_FILE &> /dev/null
    message "read committed" "-c"
    sudo -u postgres psql -c "ALTER ROLE $PSQL_USER SET timezone TO 'Europe/Warsaw'" |& tee -a $LOG_FILE &> /dev/null
    message "Strefa czasowaEurope/Warsaw" "-c"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $PSQL_NAME TO $PSQL_USER" |& tee -a $LOG_FILE &> /dev/null
    message "Nadanie uprawnień $PSQL_USER do bazy $PSQL_NAME" "-c"
}

function venv_deactivate(){
    cd $HOME/$PROJ_DIR
    x=`which python3`
    echo "$x"
    if [ "$x" == "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
        deactivate
        message "Deaktywacja środowiska virtualenv." "-m"
        x=`which python3`
        if [ "$x" != "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
            message "Środowisko virtualenv wyłączone." "-c"
        else
            message "Nie udane wyłączenie środowiska virtualenv." "-w"
        fi
    else
        message "Środowiska virtualenv nie było aktywne." "-w"
    fi
}


function venv_activate(){
    local local_dir=`pwd`
    cd $HOME/$PROJ_DIR
    if [ !-d "venv" ] ; then
        get_virtualenv
    else
        x=`which python3`
        if [ "$x" != "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
            message "Środowisko virtualenv wyłączone." "-c"
        else
            message "Nie udane wyłączenie środowiska virtualenv." "-w"
        fi
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
        git clone $GIT_LINK $HOME/$PROJ_DIR |& tee -a $LOG_FILE &> /dev/null

        if [ $? -eq 0 ] ; then
            message "Pomyślnie pobrano repozytorium $GIT_LINK." "-c"
            get_virtualenv
            venv_deactivate
        else
            message "Pobieranie repozytorium $GIT_LINK." "-e"
        fi
    else
        cd $HOME/$PROJ_DIR
        git init
        if [ $? -eq 0 ] ; then
            message "Pomyślnie zinicjowano puste repozytorium w katalogu $HOME/$PROJ_DIR." "-c"
            get_virtualenv
            message "Django budowanie projektu." "-T"
            cd $HOME/$PROJ_DIR
            django-admin startproject $DJANGO_DIR
            message "django-admin startproject $DJANGO_DIR." "-c"
            venv_deactivate
        else
            message "Nie udana inicjalizacja repozytorium w katalogu $HOME/$PROJ_DIR." "-e"
        fi        
    fi
}

function get_nginx(){
    message "KONFIGURACJA Nginx." "-T"
    install_prog nginx
    message 'Konfiguracja servera nginx' "-m"

    host=$(echo $C_SYS_HOSTS | tr "," "\n")
    hosts=""
    for addr in $host ; do
        hosts="${hosts} $addr"
    done
    if [ "$hosts" == "" ] ; then
        hosts="localhost"
    fi
    serv_conf="server {
    listen [::]:80;
    server_name $hosts;
    location /static/ {
        root ${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/;
    }
    location / {
        include proxy_params;
        proxy_pass http://unix:${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}.sock;
    }
}"
    cd $HOME/$PROJ_DIR/

    sudo echo "$serv_conf" > "${DJANGO_DIR}.serv"
    sudo cp "${DJANGO_DIR}.serv" /etc/nginx/sites-available/
    sudo rm "${DJANGO_DIR}.serv"
    message "Zapis /etc/nginx/sites-available/${DJANGO_DIR}.serv" "-c"

    sudo ln -s "/etc/nginx/sites-available/${DJANGO_DIR}.serv" "/etc/nginx/sites-enabled/${DJANGO_DIR}.serv"

    message "Dowiązanie /etc/nginx/sites-enabled/${DJANGO_DIR}.serv" "-c"

    sudo systemctl restart nginx.service

    message "Restart nginx" "-c"
}

function get_service(){
    message "USŁUGA SYSTEMOWA GUNICORN" "-T"
    message "Aktywacja środowiska virtualnev"
    venv_activate

    get_pip_install gunicorn

    venv_deactivate

    message "Tworzenie plików konfiguracji usługi ${C_SYS_NAME}.service" "-m"

    local service_vile="[Unit]
Description=$C_SYS_DESCRIPTION
After=network.target
[Service]
User=invent
Group=www-data
WorkingDirectory=${HOME}/${PROJ_DIR}/${DJANGO_DIR}/
ExecStart=${HOME}/${PROJ_DIR}/venv/bin/gunicorn --workers 1 --bind unix:${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}.sock ${DJANGO_DIR}.wsgi:application
[Install]
WantedBy=multi-user.target"

    sudo echo "$service_vile" > "${C_SYS_NAME}.service"
    sudo cp "${C_SYS_NAME}.service" /etc/systemd/system/
    #sudo rm "${C_SYS_NAME}.service"
    sduo systemctl enable "${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null
    sduo systemctl start "${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null
    sduo systemctl daemon-reload |& tee -a $LOG_FILE &> /dev/null
    sduo systemctl restart "${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null
}


if [ "$0" == "./lib_django.sh" ] || [ "$0" == "lib_django.sh" ] ; then
    echo "Skrypt z lib_django.sh"
fi