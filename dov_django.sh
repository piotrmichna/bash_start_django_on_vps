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

function get_django_settings(){
    if [ -d "${HOME}/${PROJ_DIR}/${DJANGO_DIR}" ] ; then
        message "KONFIGURACJA Django." "-t"
        message "Konfiguracja ustawień Django." "-m"
        local host=$(echo $C_SYS_HOSTS | tr "," "\n")
        local hosts=""
        local var_set=""
        for addr in $host ; do
            if [ "$hosts" == "" ] ; then
            hosts="'$addr'"
            else
            hosts="${hosts},'$addr'"
            fi
        done
        message "Szukanie pliku local_settings.py." "-m"
        if [ -f "${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/local_settings.py" ] ; then
            message 'Nadpisano poprzednią kofigurację local_settings.py' "-m"
        fi
        local local_setting="LANGUAGE_CODE = 'pl-pl'

TIME_ZONE = 'Europe/Warsaw'

STATIC_URL = '/static/'
"

        echo "$local_setting" > ${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/local_settings.py
        var_set="LANGUAGE_CODE, TIME_ZONE, STATIC_URL"

        if [ "$hosts" != "" ] ; then
            local_setting="ALLOWED_HOSTS = [${hosts}]"
            message "Konfiguracja ustawień ALLOWED_HOSTS." "-c"
            var_set="${var_set}, ALLOWED_HOSTS"
            echo "$local_setting" >> ${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/local_settings.py
        fi

        if [ $PSQL_C -eq 1 ] ; then
            message "Konfiguracja ustawień DATABASES." "-m"
            local_setting="DATABASES = {
    'default': {
        'ENGINE': \"django.db.backends.postgresql_psycopg2\",
        'NAME': \"$PSQL_NAME\",
        'HOST': \"localhost\",
        'PASSWORD': \"$PSQL_PASS\",
        'USER': \"$PSQL_USER\",
        'PORT': 5432
    }
}"

            echo "$local_setting" >> ${HOME}/${PROJ_DIR}/${DJANGO_DIR}/${DJANGO_DIR}/local_settings.py
            message "Konfiguracja ustawień DATABASES." "-c"
            var_set="${var_set}, DATABASES"
        fi

        if [ "${GIT_LINK}" == "" ] ; then
            local_setting="try:
    from ${DJANGO_DIR}.local_settings import (${var_set})
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

function get_django_project(){
    message 'PROJEKT Django' "-t"
    if [ $PROJ_DIR != "" ] ; then
        message 'Tworzenie katalogu projektu.' "-m"
        if [ -d "${HOME}/${PROJ_DIR}" ] ; then
            message "Nie utoworzono ${HOME}/${PROJ_DIR}." "-w"
            message "Katalog ${HOME}/${PROJ_DIR} już istnieje." "-e"
            get_exit "Katalog projektu już istnieje." "-e"
        fi
        mkdir ${HOME}/${PROJ_DIR}
        if [ -d "${HOME}/${PROJ_DIR}" ] ; then
            message "Utworzono katalog projektu ${HOME}/${PROJ_DIR}." "-c"
        else
            message "Nie utoworzono ${HOME}/${PROJ_DIR}." "-e"
            get_exit "Nie utoworzono katalogu projektu."
        fi
        message 'Sprawdzanie konfiguracji git' "-m"
        if [ $C_CGIT -eq 1 ]; then
            message 'KLONOWANIE PROJEKTU Djanog' "-t"
            message 'Klonowanie repozytorium do katalogu projektu.' "-m"
            git clone ${GIT_LINK} ${HOME}/${PROJ_DIR} |& tee -a $LOG_FILE &> /dev/null

            if [ $? -eq 0 ] ; then
                if [ -d ${HOME}/${PROJ_DIR}/${DJANGO_DIR} ] ; then
                    message "Pomyślnie pobrano repozytorium ${GIT_LINK}." "-c"
                    get_virtualenv
                    venv_deactivate
                else
                    message "Błędna nazwa Katalogu projektu Django w pobranym repozytorium." "-e"
                    get_exit "Błąd konfiguracji git!"
                fi
            else
                message "Pobieranie repozytorium ${GIT_LINK}." "-e"
                get_exit "Błąd konfiguracji git!"
            fi
        else
            cd ${HOME}/${PROJ_DIR}
            message 'NOWY PROJEKT Djanog' "-t"
            message 'Tworzenie nowego repozytorium w katalogu projektu.' "-m"
            git init |& tee -a $LOG_FILE &> /dev/null
            if [ $? -eq 0 ] ; then
                message "Pomyślnie zinicjowano puste repozytorium ${HOME}/${PROJ_DIR}.git" "-c"
                message 'Tworzenie pliku .gitignore.' "-m"

                git_ignore=".idea/
__pycache__/
*.py[cod]
*\$py.class
env/
venv/
*.swp
*.*.swp
*.log
local_*.py"
                echo "$git_ignore" > .gitignore
                git add .gitignore
                git commit -m 'inicjalizacja repozytorium i dodanie .gitignore' |& tee -a $LOG_FILE &> /dev/null
                message 'Utworzono i dodano plik .gitignore.' "-c"
                message 'Tworzenie pliku readme.md.' "-m"
                echo "# Nowy Projekt Django" > readme.md
                git add readme.md
                git commit -m 'utworzenie readme.md' |& tee -a $LOG_FILE &> /dev/null
                message 'Utworzono i dodano plik readme.md.' "-c"

                get_virtualenv
                message "Django budowanie projektu." "-m"
                cd ${HOME}/${PROJ_DIR}
                django-admin startproject ${DJANGO_DIR}
                message "django-admin startproject ${DJANGO_DIR}." "-c"
                venv_deactivate
            else
                message "Nie udana inicjalizacja repozytorium w katalogu ${HOME}/${PROJ_DIR}." "-e"
                get_exit "Błąd tworzenia repozytorium git!"
            fi
        fi
        message "Przenoszenie pliku z zapiesem logów." "-m"
        mv "${LOG_FILE}" "${HOME}/${PROJ_DIR}/${LOG_NAME}"
        LOG_FILE="${HOME}/${PROJ_DIR}/${LOG_NAME}"
    else
        message 'Błąd konfiguracji Django' "-e"
        get_exit "Brak zdefiniowanego katalogu projektu"
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

function get_django_soft(){
    message 'INSTALACJA OPROGRAMOWANIA' "-T"
    install_prog git vim python3-pip python3-dev
}

function get_django(){
    get_django_conf
    get_config_psql
    get_conf_django_service
    # budowanie projektu
    get_django_soft
    get_django_project
    
    if [ $PSQL_C -eq 1 ] ; then
        get_postgresql
    fi
    get_django_settings

    if [ $C_SERVICE -eq 1 ] ; then
        get_nginx
        get_service
    fi
}

if [ "$0" == "./dov_django.sh" ] || [ "$0" == "dov_django.sh" ] ; then
    sudo ls > /dev/null
    get_django
fi