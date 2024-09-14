#!/bin/bash

cat <<'EOF'> /etc/keepalived/chk.sh
#!/bin/bash

# 容器名称
CONTAINER_NAME=("mes_api" "mes_web")
# 检查当前状态
current_state=""

# 循环检查状态
while true; do
    new_state=""

    sed -n '/virtual_ipaddress {/,/}/p' /etc/keepalived/keepalived.conf | sed -e '1d' -e '$d' -e 's/^[ \t]*//' -e 's/[ \t]*$//' | awk '{print $3, $1}' | while read -r interface ip_address; do
        if [ "$(ip addr show "$interface" | grep "$ip_address" | wc -l)" -eq 1 ]; then
            new_state='MASTER'
        fi
    done

    # 检查状态是否变化
    if [ "$new_state" != "$current_state" ]; then
        if [ "$new_state" == "MASTER" ]; then
            echo "Switching to MASTER state. Starting container..."
            for container in "${CONTAINER_NAME[@]}"; do
                if [ "$(docker ps -q -f name="$container" | wc -l)" -eq 0 ]; then
                    docker start "$container"
                fi
            done
        else
            echo "Switching to non-MASTER state. Stopping container..."
             for container in "${CONTAINER_NAME[@]}"; do
                if [ "$(docker ps -q -f name="$container" | wc -l)" -eq 1 ]; then
                    docker stop "$container"
                fi
            done
        fi
        current_state="$new_state"
    fi

    # 等待一段时间后再次检查状态
    sleep 5
done
EOF
