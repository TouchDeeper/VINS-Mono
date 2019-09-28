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

for m in ape
do
    ls ../ACC_N/$m*.zip > /dev/null
    retcode=$?; if [ $retcode != 0 ]; then
        echo "missing files: "$m*.zip
        echo "run {ape, rpe}_demo.sh before this demo"
        exit 1
    else
        echo "found files for $m"
    fi
done

set -e  # exit on error
file=""
for i in {0..26}
do
    file="$file ../GYR_N/ape$i.zip"
done
for m in ape
do
    log "load results from evo_$m and save stats in table"
    echo_and_run evo_res $file $p --save_table ../results/"$m"_gyr_n.csv --save_plot ../results/"$m"_gyr_n.pdf
done
