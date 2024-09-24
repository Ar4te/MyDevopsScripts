#!/bin/bash
be_log_path="/data/doris/be/log/"
be_log_archive_path="/log/doris/be/"
fe_log_path="/data/doris/fe/log/"
fe_log_archive_path="/log/doris/fe/"
script_log_path="/log/doris/archive_log"

function archive_logs() {
    local log_path=$1
    local log_archive_path=$2

    mkdir -p "${log_archive_path}"

    if [ -d "${log_path}" ]; then
        cd "${log_path}" || exit

        find "${log_path}" -size +1000M -name "*.log.*" -print0 | while IFS= read -r -d '' file; do
            echo "$(date '+%Y-%m-%d %H:%M:%S %Z'): ${file}" >>"${script_log_path}"
            local archive_log_file_name="${file}.zst"
            tar -cf - "${file}" | zstd -o "${archive_log_file_name}" &&
                mv "${archive_log_file_name}" "${log_archive_path}" &&
                rm -f "${file}"
        done
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S %Z'): Directory ${log_path} does not exist." >>"${script_log_path}"
    fi
}

function get_log_path() {
    if [ ! -f "${script_log_path}" ]; then
        touch "${script_log_path}"
    fi

    echo "${script_log_path}"
}

if [ "$#" -eq 1 ] && [ "${1}" == "log-path" ]; then
    get_log_path
else
    echo "log file path is ${script_log_path}"
    echo "$(date '+%Y-%m-%d %H:%M:%S %Z'): Archiving ${be_log_path} logs...." >>"${script_log_path}"
    archive_logs "${be_log_path}" "${be_log_archive_path}"
    echo "$(date '+%Y-%m-%d %H:%M:%S %Z'): Archived ${be_log_path} logs" >>"${script_log_path}"
    echo "$(date '+%Y-%m-%d %H:%M:%S %Z'): Archiving ${fe_log_path} logs...." >>"${script_log_path}"
    archive_logs "${fe_log_path}" "${fe_log_archive_path}"
    echo "$(date '+%Y-%m-%d %H:%M:%S %Z'): Archived ${fe_log_path} logs" >>"${script_log_path}"
fi
