#!/bin/bash

mkdir -p /log/keepalived

cat <<'EOF' > /etc/keepalived/health_chk.sh
#!/bin/bash

# Script for check app healthy

LOG_FILE="/log/keepalived/health_chk.log"
STATE=`cat /etc/keepalived/keepalived.state`

STATE='BACKUP'

`sed -n '/virtual_ipaddress {/,/}/p' /etc/keepalived/keepalived.conf | sed -e '1d' -e '$d' -e 's/^[ \t]*//' -e 's/[ \t]*$//' | awk '{print $3, $1 }'` | while read line; do 
    if [ $(ip addr show "$interface" | grep "$ip_address" | wc -l) -eq 1 ]; then
        STATE='MASTER'
    fi
done

if [[ $STATE == 'MASTER' ]]; then
    echo "$(date): STATE is MASTER" >> $LOG_FILE
    APP_OK=$(docker ps | grep -E 'mes_api|mes_web' | wc -l)
    if [ "$APP_OK" -eq 2 ]; then
        echo "$(date): APP is UP" >> $LOG_FILE
        exit 0
    else
        echo "$(date): APP is DOWN, change state to BACKUP" >> $LOG_FILE
        exit 1
    fi
else
    APP_OK=$(docker ps | grep -E 'mes_api|mes_web' | wc -l)
    if [ "$APP_OK" -eq 0 ]; then
        echo "$(date): STATE: $STATE, needn't stop Docker containers" >> $LOG_FILE
        exit 0
    fi
    echo "$(date): STATE is $STATE, stopping Docker containers" >> $LOG_FILE
    if docker stop mes_api && docker stop mes_web; then
        echo "$(date): Docker containers stopped successfully" >> $LOG_FILE
    else
        echo "$(date): Failed to stop Docker containers" >> $LOG_FILE
    fi
    exit 0
fi
EOF

chmod a+x /etc/keepalived/health_chk.sh
chcon -h system_u:object_r:keepalived_unconfined_script_exec_t /etc/keepalived/health_chk.sh


chmod a+x /etc/keepalived/*.sh
chcon -h system_u:object_r:keepalived_unconfined_script_exec_t /etc/keepalived/*.sh
systemctl restart keepalived && systemctl status keepalived