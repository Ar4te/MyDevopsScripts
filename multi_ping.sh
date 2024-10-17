#!/bin/bash

ipListFilePath="./iplist.txt"
ipCnt=$(wc -l <"${ipListFilePath}")
count=0
while read -r item; do
    count=$((count + 1))
    datetimevar=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${item} ${count}/${ipCnt}"

    p=$(ping -c 3 "${item}" | grep -oP '\d+(?=% packet loss)')
    echo "Loss percentage: $p"
    if [ "$p" -eq 0 ]; then
        echo "${datetimevar}|${item}|true" >>./ipcheckdown.txt
    else
        echo "${datetimevar}|${item}|fail" >>./ipcheckdown.txt
    fi
done <"${ipListFilePath}"
