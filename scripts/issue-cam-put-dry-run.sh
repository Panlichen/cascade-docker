#!/bin/bash

for file in `ls cow-fig`
do
    array=(${file//./ })
    key=${array[0]}
    # echo "$file, $key"
    # if [ $key -eq "001" ]; then
    #     sleep 8
    # else
    #     sleep 2
    # fi
    cmd="../../dairy_farm_client -f cow-fig/$file -k $key"
    echo $cmd
    # $cmd
done

echo "done issuing put requests"