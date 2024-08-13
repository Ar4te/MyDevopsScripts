#!/bin/bash

cat <<'EOF'> /root/archive_images.sh
#!/bin/bash

set -e

function archive_images() {
    local filter_info="$1"
    local rm_image="$2"
    local base_path="$3"

    # 确保 base_path 存在
    if [ ! -d "$base_path" ]; then
        mkdir -p "$base_path"
    fi

    docker images | grep -E "$filter_info" | awk '{print $1, $2, $3}' | while read -r repo tag image_id; do
        # 如果 tag 中不包含 dev- 或 prd- 则跳过
        if [[ ! "$tag" == dev-* && ! "$tag" == prd-* ]]; then
            continue
        fi

        # 创建备份目录
        path="$base_path/$repo"
        if [ ! -d "$path" ]; then
            mkdir -p "$path"
        fi

        # 生成文件名和临时文件名
        random_sequence=$(printf "%06d" $((RANDOM % 1000000)))
        file_name="${tag}_${image_id}.tar"
        temp_file_name="/tmp/temp_ai_${file_name}_${random_sequence}"

        # 保存镜像
        docker save -o "$temp_file_name" "$image_id"

        # 压缩镜像
        tar -cf - "$temp_file_name" | zstd -o "$path/${file_name}.zst"

        # 删除临时文件
        rm -f "$temp_file_name"

        # 删除镜像（可选）
        if [[ -n "${rm_image}" && "${rm_image}" == "1" ]]; then
            docker rmi "$image_id"
        fi
    done

    echo "Archiving completed."
}

# 检查传入的参数数量
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <镜像筛选字符串:filter_info> <是否删除镜像:rm_image> <归档目录:base_path>"
    exit 1
fi

# 调用归档函数
archive_images "$1" "$2" "$3"
EOF
