#!/bin/bash

vmstat -s | awk '{ if ($2$3$4 ~ /[^(idle)].*cpu/) sum += $1; else if ($2 ~ /idle/) idle = $1 ;} END {print sum" "idle+sum }'
