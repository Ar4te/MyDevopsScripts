#!/bin/bash

cat <<'EOF'> /root/docker_operator.sh
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
EOF

# 要添加的任务
new_job="0 23 * * * /root/docker_operator.sh --clean -d /var > /dev/null 2>&1"

# 临时文件用来保存当前 crontab 内容
temp_crontab=$(mktemp)

# 将当前 crontab 导出到临时文件
crontab -l > $temp_crontab

# 将新任务添加到临时文件末尾
echo "$new_job" >> $temp_crontab

# 导入更新后的 crontab
crontab $temp_crontab

# 删除临时文件
rm -rf $temp_crontab

echo "任务已成功添加到 crontab。"

crontab -l