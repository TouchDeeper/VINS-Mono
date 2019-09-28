#!/usr/bin/env bash

# printf "\033c" resets the output
function log { printf "\033c"; echo -e "\033[32m[$BASH_SOURCE] $1\033[0m"; }
function echo_and_run { echo -e "\$ $@" ; read input; "$@" ; read input; }

# always run in script directory
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

p="-p"
if [[ $* == *--no_plots* ]]; then
    p=
fi

for m in rpe
do
    ls ../GYR_N/$m*.zip > /dev/null
    retcode=$?; if [ $retcode != 0 ]; then
        echo "missing files: "$m*.zip
        echo "run {ape, rpe}_demo.sh before this demo"
        exit 1
    else
        echo "found files for $m"
    fi
done

set -e  # exit on error

for m in rpe
do
    log "load results from evo_$m and save stats in table"
    echo_and_run evo_res ../GYR_N/"$m"*.zip $p --save_table "$m"_gyr_n.csv --save_plot "$m"_gyr_n.pdf
done
