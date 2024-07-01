#!/bin/bash

clean() {
    docker_log_dir="$1"

    mapfile -t logs < <(find "$docker_log_dir" -type f -name "*-json.log")

    if [ ${#logs[@]} -gt 0 ]; then
        echo "清空以下日志文件："
        printf '%s\n' "${logs[@]}"
        echo ""

        for log_file in "${logs[@]}"; do
            truncate -s 0 "$log_file"
            ls -lh "$log_file"
        done
    else
        echo "'$1'目录下未找到符合格式(*-json.log)的文件"
    fi
}

if [ "$1" == "--clean" ]; then
    if [ "$2" == "-d" ]; then
        if [ ! -d "$3" ] || [ -z "$3" ]; then
            echo "请输入docker日志目录"
            exit 1
        fi
        clean "$3"
    else
        echo "请输入正确的选项和参数: ./clean_docker_log.sh --clean -d /root/log"
        exit 1
    fi
else
    echo "请输入正确的选项和参数，例如: ./clean_docker_log.sh --clean -d /root/log"
    exit 1
fi