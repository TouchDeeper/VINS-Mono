#!/bin/bash
acc_n=0.08          # accelerometer measurement noise standard deviation. #0.2   0.04
gyr_n=0.004         # gyroscope measurement noise standard deviation.     #0.05  0.004
acc_w=0.00004         # accelerometer bias random work noise standard deviation.  #0.02
gyr_w=2.0e-6       # gyroscope bias random work noise standard deviation.     #4.0e-5
scale=1
run_num=3
power=1
#power=$(echo "($run_num-1)/2"|bc)
let power=(run_num-1)/2
#eval $(awk -v power_awk="$power" 'BEGIN {scale_awk=0.5^power_awk; printf "scale=%.15f", scale_awk}')
#scale=$(awk -v power_awk="$power" 'BEGIN {scale_awk=0.5^power_awk; printf "%.15f", scale_awk}')

echo $scale

#scale=$(echo "0.5**$power"|bc)
for loop in ACC_N ACC_W GYR_N GYR_W
do
  if [ "$loop" == "ACC_N" ];then
    echo "[ == ]"
    for((i=0;i<$[run_num];i++)) 
    do  
      #power_=$(echo "i-$power"|bc)
      let power_=i-power
      scale=$(awk -v power_awk="$power_" 'BEGIN {scale_awk=2^power_awk; printf "%.15f", scale_awk}')
      acc_n_scaled=$(echo "$acc_n*$scale"|bc)
      sed -i "s/^acc_n: [0-9]*\.[0-9]*/acc_n: $acc_n_scaled/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
      #echo "scale="$scale "i="$i
      echo "acc_n="$acc_n_scaled "i="$i
      roslaunch vins_estimator euroc.launch&
      euroc_PID=$!
      echo "euroc_PID = "$euroc_PID
      roslaunch vins_estimator vins_rviz.launch&
      rviz_PID=$!
      echo "rviz_PID = "$rviz_PID
      sleep 1s
      rosbag play /media/wang/File/dataset/EuRoc/MH_05_difficult.bag&
      rosbag_pid=$!
      echo "rosbag PID = "$rosbag_pid
      isRosbagExist=`ps -ef|grep rosbag|grep -v "grep"|wc -l`
      while [ "$isRosbagExist" -ne "0" ]
      do
        echo "sleep 1s"
        sleep 1s
        isRosbagExist=`ps -ef|grep rosbag|grep -v "grep"|wc -l`
      done
      kill -9 $euroc_PID
      echo "kill euroc_PID"
      kill -9 $rviz_PID
      echo "kill rviz_PID"
    done 
  fi
done




