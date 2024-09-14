#!/bin/bash

cat <<'EOF'> /etc/keepalived/notify_backup.sh
#!/bin/bash

# 状态文件
STATE_FILE="/etc/keepalived/keepalived.state"

# 定义日志文件
LOG_FILE="/log/keepalived/notify_backup.log"

# 写入状态
echo BACKUP > $STATE_FILE

# 获取当前时间
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 记录降级状态
echo "$TIMESTAMP: Keepalived status changed to BACKUP" >> $LOG_FILE

docker stop mes_api && docker stop mes_web
EOF

chmod a+x /etc/keepalived/notify_backup.sh
chcon -h system_u:object_r:keepalived_unconfined_script_exec_t  /etc/keepalived/notify_backup.sh
