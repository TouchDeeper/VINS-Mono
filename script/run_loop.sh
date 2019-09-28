#!/bin/bash
acc_n=0.08          # accelerometer measurement noise standard deviation. #0.2   0.04
gyr_n=0.004         # gyroscope measurement noise standard deviation.     #0.05  0.004
acc_w=0.00004         # accelerometer bias random work noise standard deviation.  #0.02
gyr_w=2.0e-6       # gyroscope bias random work noise standard deviation.     #4.0e-5
scale=1
run_num=27
power=1
#power=$(echo "($run_num-1)/2"|bc)


sed -i "s/^acc_n: [0-9]*\.[0-9]*/acc_n: $acc_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^acc_w: [0-9]*\.[0-9]*/acc_w: $acc_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^gyr_n: [0-9]*\.[0-9]*/gyr_n: $gyr_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^gyr_w: .[0-9]*\.[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: $gyr_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml

let power=(run_num-1)/2
#eval $(awk -v power_awk="$power" 'BEGIN {scale_awk=0.5^power_awk; printf "scale=%.15f", scale_awk}')
#scale=$(awk -v power_awk="$power" 'BEGIN {scale_awk=0.5^power_awk; printf "%.15f", scale_awk}')

echo $scale

#scale=$(echo "0.5**$power"|bc)
for loop in ACC_N ACC_W GYR_N GYR_W
#for loop in GYR_W
do
  for((i=0;i<$[run_num];i++)) 
  do  
    #power_=$(echo "i-$power"|bc)
    let power_=i-power
    scale=$(awk -v power_awk="$power_" 'BEGIN {scale_awk=2^power_awk; printf "%.13f", scale_awk}')
    # modify the vio_path
    sed -i "s:^vio_path.*\.txt\"$:vio_path\: \"/home/wang/vins_ws/src/VINS-Mono/output/euroc_result/$loop/vio$i\.txt\":g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    if [ "$loop" == "ACC_N" ];then
      acc_n_scaled=$(echo "$acc_n*$scale"|bc)
      # modify the acc_n's value
      sed -i "s/^acc_n: [0-9]*\.[0-9]*/acc_n: $acc_n_scaled/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
      #echo "scale="$scale "i="$i
      echo "acc_n="$acc_n_scaled "i="$i
    fi
    if [ "$loop" == "ACC_W" ];then
      acc_w_scaled=$(echo "$acc_w*$scale"|bc)
      # modify the acc_w's value
      sed -i "s/^acc_w: [0-9]*\.[0-9]*/acc_w: $acc_w_scaled/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
      #echo "scale="$scale "i="$i
      echo "acc_w="$acc_w_scaled "i="$i
    fi
    if [ "$loop" == "GYR_N" ];then
      gyr_n_scaled=$(echo "$gyr_n*$scale"|bc)
      # modify the acc_w's value
      sed -i "s/^gyr_n: [0-9]*\.[0-9]*/gyr_n: $gyr_n_scaled/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
      #echo "scale="$scale "i="$i
      echo "gyr_n="$gyr_n_scaled "i="$i
    fi
    if [ "$loop" == "GYR_W" ];then
      #translate the scientific notation to general float
      gyr_w_float=$(awk -v gyr_w_="$gyr_w", 'BEGIN {printf "%.13f", gyr_w_}')
          # awk can't work
          #gyr_w_scaled=$(awk -v gyr_w_="$gyr_w" scale_="$scale" 'BEGIN {gyr_w_scaled_=gyr_w_*scale_; printf "%.13f", gyr_w_scaled_}') 
      gyr_w_scaled=$(echo "$gyr_w_float*$scale"|bc)
      # modify the acc_w's value
      sed -i "s/^gyr_w: .[0-9]*\.[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: $gyr_w_scaled/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
      # search Scientific notation or general float or float like .00001
      #grep -rnsi "^gyr_w: .[0-9]*\.[^[:space:]]*\|^gyr_w: \.[^[:space:]]*"
      #ag "^gyr_w: -?[0-9]*\.[0-9]*(e\-?[0-9]*)?([0-9]*)?"
      #echo "scale="$scale "i="$i
      echo "gyr_w="$gyr_w_scaled "i="$i
    fi
    roslaunch vins_estimator euroc.launch&
    euroc_PID=$!
    echo "euroc_PID = "$euroc_PID
    roslaunch vins_estimator vins_rviz.launch&
    rviz_PID=$!
    echo "rviz_PID = "$rviz_PID
    sleep 1s
    rosbag play -q /media/wang/File/dataset/EuRoc/MH_05_difficult.bag&
    rosbag_pid=$!
    echo "rosbag PID = "$rosbag_pid
    sleep 1s
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
  
  #restore the noise parameters and vio path
  sed -i "s/^acc_n: [0-9]*\.[0-9]*/acc_n: $acc_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
  sed -i "s/^acc_w: [0-9]*\.[0-9]*/acc_w: $acc_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
  sed -i "s/^gyr_n: [0-9]*\.[0-9]*/gyr_n: $gyr_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
  sed -i "s/^gyr_w: .[0-9]*\.[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: $gyr_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
  sed -i "s:^vio_path.*\.txt\"$:vio_path\: \"/home/wang/vins_ws/src/VINS-Mono/output/euroc_result/vio\.txt\":g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
done




