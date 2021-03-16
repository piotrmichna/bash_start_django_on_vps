#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl
# created: 15.03.2021

source dov_tools.sh


if [ "$0" == "./dov_django.sh" ] || [ "$0" == "dov_django.sh" ] ; then
    sudo ls > /dev/null
fi