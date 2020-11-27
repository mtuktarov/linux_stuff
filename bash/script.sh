#!/bin/bash

echo $(( MIN ))
echo $(( MAX ))
while true ; do
    MIN=$(( MIN + 10 ))
    MAX=$(( MAX - 10 ))
    echo $((MIN))
    echo $MAX
    sleep 7
done
