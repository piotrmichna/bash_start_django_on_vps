#!/bin/bash

# author: Piotr Michna
# e-mail: pm@piotrmichna.pl
# created: 17.03.2021 

source dov_tools.sh
source dov_django.sh
source dov_root.sh


if [ "$0" == "./install.sh" ] || [ "$0" == "install.sh" ] ; then
    init_script
    get_root_menu
fi