#!/bin/bash

# 脚本路径
script_path="/root/release_buff_cache.sh"

# 检查脚本是否存在，如果不存在则创建
if [ ! -f "$script_path" ]; then
    cat <<'EOF' >$script_path
#!/bin/bash
#将缓冲区的数据写入磁盘（清除buff）
sync
sync
sync
#释放页缓存
echo 1 > /proc/sys/vm/drop_caches
#释放dentries和inodes缓存
echo 2 > /proc/sys/vm/drop_caches
#释放页缓存和dentries、inodes缓存
echo 3 > /proc/sys/vm/drop_caches
echo "清除结束"
EOF

    # 确保脚本是可执行的
    chmod +x $script_path
    echo "脚本 $script_path 已创建并设置为可执行。"
else
    echo "脚本 $script_path 已存在。"
fi

# 要添加的任务
new_job="0 23 * * * $script_path > /dev/null 2>&1"

# 临时文件用来保存当前 crontab 内容
temp_crontab=$(mktemp)

# 将当前 crontab 导出到临时文件
crontab -l >$temp_crontab

# 检查任务是否已存在
if grep -Fxq "$new_job" $temp_crontab; then
    echo "任务已存在于 crontab 中。"
else
    # 将新任务添加到临时文件末尾
    echo "$new_job" >>$temp_crontab

    # 导入更新后的 crontab
    crontab $temp_crontab

    echo "任务已成功添加到 crontab。"
fi

# 删除临时文件
rm -rf $temp_crontab

# 显示当前 crontab 任务
crontab -l