#!/usr/bin/env bash

set -e  # exit on error

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


log "run multiple and save results"

for ((i=0; i<27; i++))
do
	echo_and_run evo_ape tum ../euroc_mh05_groundtruth.tum ../ACC_W/vio$i.txt -va --save_results ../ACC_W/ape$i.zip
done
