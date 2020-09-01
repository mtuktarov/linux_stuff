#!/bin/bash


get_cpu_values(){
    local MY_VAR="my pretty variable"
    vmstat -s | awk '{ if ($2$3$4 ~ /[^(idle)].*cpu/) sum += $1; else if ($2 ~ /idle/) idle = $1 ;} END {print sum" "idle+sum }'
}

read init_work init_all <<< $(get_cpu_values)

while true ; do
    get_cpu_values
    echo $MY_VAR
    sleep 1
#    read work all <<< $(get_cpu_values)
#    diff_all=$(( all - init_all ))
#    diff_work=$(( work - init_work ))
#    work_time=$(( 100 * diff_work / diff_all ))
#    printf "%b: %d; %b: %d\n" "idle" $((100-$work_time)) "work" $work_time
done
