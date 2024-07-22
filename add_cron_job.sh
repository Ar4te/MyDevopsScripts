#!/bin/bash
# 要添加的任务
# new_job="0 23 * * * $script_path > /dev/null 2>&1"

function add_cron_job() {
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
}

export -f add_cron_job
