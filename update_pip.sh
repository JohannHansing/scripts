#!/bin/bash

# RUN AS SUDO!
# cd ~/bin
# sudo ./update_pip [all]

# from https://github.com/nvie/pip-tools/issues/185 user datakid - Modified

for pkg in $( pip list --outdated | cut -d' ' -f 1 )
do
    echo $pkg
    if [ $1 == 'all' ]; then
        pip install -U $pkg
    else
        echo "update now? [yn]:"
        read answer
        if [ "$answer" == "y" ]; then
            pip install -U $pkg
        fi
    fi
done