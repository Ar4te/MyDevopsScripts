#!/bin/bash

cat <<'EOF' > /etc/keepalived/notify_master.sh
#!/bin/bash

# 状态文件
STATE_FILE="/etc/keepalived/keepalived.state"

# 定义日志文件
LOG_FILE="/log/keepalived/notify_master.log"

# 重启容器
docker restart mes_api && docker restart mes_web

sleep 5

# 写入状态
echo MASTER > $STATE_FILE

# 获取当前时间
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 记录状态
echo "$TIMESTAMP: Keepalived status changed to MASTER" >> $LOG_FILE

EOF

chmod a+x /etc/keepalived/notify_master.sh
chcon -h system_u:object_r:keepalived_unconfined_script_exec_t /etc/keepalived/notify_master.sh
Windows@2024