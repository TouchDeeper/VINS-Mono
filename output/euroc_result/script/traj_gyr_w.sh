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

log "read info"
echo_and_run evo_traj tum --ref ../imu_pose_tum_correspondence_cam.txt ../GYR_W/traj*.txt --align --plot_mode=xy $p

