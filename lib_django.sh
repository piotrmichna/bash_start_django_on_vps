#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

PYTHON_INSTAL_LIB="psycopg2-binary Django django-rest gunicorn"

function get_exit(){
    echo -ne "${C_TIT}${BOLD}------> ERROR EXIT ON INSTALL DJANGO <-----------${NC}\n\r"
    echo "------> ERROR EXIT ON INSTALL DJANGO <-----------" |& tee -a $LOG_FILE &> /dev/null
    exit 0
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
            message "Biblioteka $i jest już zainstalowana." "-w"
        fi
    done
}

function get_virtualenv(){
    message "ŚRODOWISKO VIRTUALENV" "-t"

    get_pip_install virtualenv

    message 'Konfiguracja środowiska virtualenv' "-m"
    cd ${HOME}/${PROJ_DIR}
    virtualenv -p python3 venv |& tee -a $LOG_FILE &> /dev/null
    if [ -d "venv" ] ; then
        message "Utworzenie środowiska virtualenv." "-c"
        cd ${HOME}/${PROJ_DIR}
        . venv/bin/activate
        message 'Aktywacja środowiska virtualenv' "-c"
        message 'Instalacja wymaganych bibliotek' "-m"
        get_pip_install psycopg2-binary Django django-rest djangorestframework
    else
        message "Nie udane utworzenie środowiska virtualenv." "-e"
        get_exit
    fi
}

function get_postgresql(){
    message "TWORZENIE BAZY PostreSQL" "-t"
    message "Tworzenie bazy postgresql $PSQL_NAME" "-m"
    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$PSQL_NAME'"`
    if [ "$x" != "" ] ; then
        message "Baza danych $PSQL_NAME juź istnieje" "-w"
    else
        sudo -u postgres psql -c "CREATE DATABASE $PSQL_NAME" |& tee -a $LOG_FILE &> /dev/null
        x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$PSQL_NAME'"`
        if [ "$x" != "" ] ; then
            message "Baza danych $PSQL_NAME utworzona." "-c"
        else
            message "Błąd tworzenia baza danych." "-e"
            get_exit
        fi
    fi
    message "Tworzenie użytkownika postgresql $PSQL_USER" "-m"
    x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
    if [ "$x" == "" ] ; then
        sudo -u postgres psql -c "CREATE USER $PSQL_USER WITH PASSWORD '${PSQL_PASS}'" |& tee -a $LOG_FILE &> /dev/null
        x=`sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PSQL_USER'"`
        if [ "$x" != "" ] ; then
            message "Dodano użytkownika $PSQL_USER" "-c"
        else
            message "Błąd tworzenia użytkownika $PSQL_USER" "-e"
            get_exit
        fi
    else
      message "Użytkownik baza danych już istnieje" "-w"
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
    message "Deaktywacja środowiska virtualenv." "-m"
    cd ${HOME}/${PROJ_DIR}
    x=`which python3`
    if [ "$x" == "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
        deactivate
        x=`which python3`
        if [ "$x" != "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
            message "OFF środowisko virtualenv." "-c"
        else
            message "Nie udane wyłączenie środowiska virtualenv." "-e"
            get_exit
        fi
    else
        message "Środowiska virtualenv nie było aktywne." "-w"
    fi
}


function venv_activate(){
    message "Aktywacja środowiska virtualenv." "-m"
    local local_dir=`pwd`
    cd "${HOME}/${PROJ_DIR}"
    if [ -d "venv" ] ; then
        x=`which python3`
        if [ "$x" == "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
            message "Środowisko virtualenv było włączone." "-w"
        else
            . venv/bin/activate
            x=`which python3`
            if [ "$x" == "${HOME}/${PROJ_DIR}/venv/bin/python3" ] ; then
                message "ON środowisko virtualenv." "-c"
            else
                message "Nie udane wyłączenie środowiska virtualenv." "-e"
                get_exit
            fi
        fi        
    else
        get_virtualenv
    fi
    cd "$local_dir"
}

function get_django(){
    message "Django." "-t"
    if [ -d "${HOME}/${PROJ_DIR}" ] ; then
        message "Nie utoworzono ${HOME}/${PROJ_DIR}." "-w"
        message "Katalog ${HOME}/${PROJ_DIR} już istnieje." "-e"
        get_exit
    fi
    mkdir ${HOME}/${PROJ_DIR}
    if [ $? -eq 0 ] ; then
        message "Utworzono katalog projektu ${HOME}/${PROJ_DIR}." "-c"
    else
        message "Nie utoworzono ${HOME}/${PROJ_DIR}." "-e"
        get_exit
    fi

    if [ $C_CGIT -eq 1 ]; then
        git clone ${GIT_LINK} ${HOME}/${PROJ_DIR} |& tee -a $LOG_FILE &> /dev/null

        if [ $? -eq 0 ] ; then
            if [ -d ${HOME}/${PROJ_DIR}/${DJANGO_DIR} ] ; then
                message "Pomyślnie pobrano repozytorium ${GIT_LINK}." "-c"
                get_virtualenv
                venv_deactivate
            else
                message "Błędna nazwa Katalogu projektu Django w pobranym repozytorium." "-e"
                get_exit
            fi
        else
            message "Pobieranie repozytorium ${GIT_LINK}." "-e"
            get_exit
        fi
    else
        cd ${HOME}/${PROJ_DIR}
        git init |& tee -a $LOG_FILE &> /dev/null
        if [ $? -eq 0 ] ; then
            message "Pomyślnie zinicjowano puste repozytorium w katalogu ${HOME}/${PROJ_DIR}." "-c"
            get_virtualenv
            message "Django budowanie projektu." "-t"
            cd ${HOME}/${PROJ_DIR}
            django-admin startproject ${DJANGO_DIR}
            message "django-admin startproject ${DJANGO_DIR}." "-c"
            venv_deactivate
        else
            message "Nie udana inicjalizacja repozytorium w katalogu ${HOME}/${PROJ_DIR}." "-e"
            get_exit
        fi        
    fi
}

function get_django_settings(){
    if [ -d "${HOME}/${PROJ_DIR}/${DJANGO_DIR}" ] ; then
        message "KONFIGURACJA Django." "-t"
        message "Konfiguracja ustawień Django." "-m"
        local host=$(echo $C_SYS_HOSTS | tr "," "\n")
        local hosts=""
        for addr in $host ; do
            if [ "$hosts" == "" ] ; then
            hosts="'$addr'"
            else
            hosts="${hosts},'$addr'"
            fi
        done

        local local_setting="ALLOWED_HOSTS = [${hosts}]
DATABASES = {
    'default': {
        'ENGINE': \"django.db.backends.postgresql_psycopg2\",
        'NAME': \"$PSQL_NAME\",
        'HOST': \"localhost\",
        'PASSWORD': \"$PSQL_PASS\",
        'USER': \"$PSQL_USER\",
        'PORT': 5432
    }
}
LANGUAGE_CODE = 'pl-pl'

TIME_ZONE = 'Europe/Warsaw'

STATIC_URL = '/static/'"

        local x=""
        if [ -f "${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/local_settings.py" ] ; then
            x='Nadpisano poprzednią kofigurację local_settings.py'
        fi
        echo "$local_setting" > ${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/local_settings.py
        if [ "$x" != "" ] ; then
            message "$x" "-w"
        else
            message "Utworzono  kofigurację local_settings.py" "-c"
        fi

        if [ "${GIT_LINK}" == "" ] ; then
            local_setting="try:
    from ${DJANGO_DIR}.local_settings import (DATABASES, ALLOWED_HOSTS, LANGUAGE_CODE, TIME_ZONE, STATIC_URL)
except ModuleNotFoundError:
    print('Brak konfiguracji bazy danych w pliku local_settings.py!')
    exit(0)"
            echo "$local_setting" >> ${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/settings.py
            message "Zmodyfikowano kofigurację settings.py" "-c"
        fi

        venv_activate
        cd "${HOME}/${PROJ_DIR}/${DJANGO_DIR}"
        message "Wykonanie migracji modeli do bazy." "-m"
        python manage.py migrate |& tee -a $LOG_FILE &> /dev/null
        message "Wykonano migracje modeli do bazy." "-c"
        venv_deactivate
    fi
}

function get_nginx(){
    message "KONFIGURACJA Nginx." "-t"
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
    cd ${HOME}/${PROJ_DIR}/

    sudo echo "$serv_conf" > "${DJANGO_DIR}.serv"
    sudo cp "${DJANGO_DIR}.serv" /etc/nginx/sites-available/
    sudo rm "${DJANGO_DIR}.serv"
    message "Zapis /etc/nginx/sites-available/${DJANGO_DIR}.serv" "-c"

    x=$(sudo ln -s "/etc/nginx/sites-available/${DJANGO_DIR}.serv" "/etc/nginx/sites-enabled/${DJANGO_DIR}.serv")
    if [ "$x" != "" ] ; then
        message "Nadpisano poprzednią konfigurację ${DJANGO_DIR}.serv" "-w"
    fi

    message "Dowiązanie /etc/nginx/sites-enabled/${DJANGO_DIR}.serv" "-c"

    sudo systemctl restart nginx.service

    message "Restart nginx" "-c"
}

function get_service(){
    message "USŁUGA SYSTEMOWA GUNICORN" "-t"

    venv_activate

    get_pip_install gunicorn

    venv_deactivate

    message "Tworzenie plików konfiguracji usługi ${C_SYS_NAME}.service" "-m"

    local service_vile="[Unit]
Description=$C_SYS_DESCRIPTION
After=network.target
[Service]
User=$USER
Group=www-data
WorkingDirectory=${HOME}/${PROJ_DIR}/${DJANGO_DIR}/
ExecStart=${HOME}/${PROJ_DIR}/venv/bin/gunicorn --workers 1 --bind unix:${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}.sock ${DJANGO_DIR}.wsgi:application
[Install]
WantedBy=multi-user.target"

    sudo echo "$service_vile" > "${C_SYS_NAME}.service"
    if [ -f "/etc/systemd/system/${C_SYS_NAME}.service" ] ; then
        message "Nadpisanie poprzedniej usługi ${C_SYS_NAME}.service" "-w"
    fi
    sudo cp "${C_SYS_NAME}.service" /etc/systemd/system/
    #sudo rm "${C_SYS_NAME}.service"
    message "Utworzono usługę ${C_SYS_NAME}.service" "-c"

    sudo systemctl enable "${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null
    message "Aktywowano usługę ${C_SYS_NAME}.service" "-c"
    sudo systemctl start "${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null
    message "Uruchomiono usługę ${C_SYS_NAME}.service" "-c"
    sudo systemctl daemon-reload |& tee -a $LOG_FILE &> /dev/null
    message "Ponownie załadowany deamon" "-c"
    sudo systemctl restart "${C_SYS_NAME}.service" |& tee -a $LOG_FILE &> /dev/null

}


if [ "$0" == "./lib_django.sh" ] || [ "$0" == "lib_django.sh" ] ; then
    source config_script.sh
    sudo ls > /dev/null
    echo "Skrypt z lib_django.sh"
    LOG_FILE="log.txt"
    PROJ_DIR="dev/ddd"
    DJANGO_DIR="dxd"
    PSQL_NAME="ddd_db"
    PSQL_USER="ddd_user"
    PSQL_PASS="ddpass"
    C_CGIT=0
    C_SYS_NAME="ddd"
    C_SYS_DESCRIPTION="Ddd Django gunicorn service"
    C_SYS_HOSTS="ddd.pl,www.ddd.pl,localhost"

    get_django
    get_postgresql
    get_django_settings
    get_nginx
    get_service
fi