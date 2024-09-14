#!/bin/bash

cat <<'EOF'> /etc/keepalived/notify_fault.sh 
#!/bin/bash

LOGFILE="/log/keepalived/keepalived-notify.log"

STATE=`cat /etc/keepalived/keepalived.state`

echo "$(date "+%Y-%m-%d %H:%M:%S") ${STATE} node notify_fault begin" | tee -a $LOGFILE 2>&1

docker stop mes_api && docker stop mes_web
EOF

chmod a+x /etc/keepalived/notify_fault.sh
chcon -h system_u:object_r:keepalived_unconfined_script_exec_t  /etc/keepalived/notify_fault.sh
