#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl

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


if [ "$0" == "./lib_django.sh" ] || [ "$0" == "lib_django.sh" ] ; then
    echo "Skrypt z lib_django.sh"
fi