#!/bin/bash

destUser="destUser"
destHost="destHost"
destPasswd="destPasswd"

docker pull img1:version
docker pull img2:version

path="/backup/$(date +%Y%m%d)"
mkdir -p "${path}"

docker save img1:version -o "${path}/img1_version.tar"
docker save img2:version -o "${path}/img2_version.tar"

expect <<EOF
set timeout -1
spawn scp -p -r "${path}" ${destUser}@${destHost}:/backup/
expect "password:"
send "${destPasswd}\r"
expect eof
EOF

expect <<EOF
set timeout -1
spawn ssh ${destUser}@${destHost}
expect "password:"
send "${destPasswd}\r"
expect "# "

send "yes | cp -rf ${path}/* /backup/\r"
expect "# "

send "cd /opt/project\r"
expect "# "
send "sh img1_renew.sh\r"
expect "# "
send "sh img2_renew.sh\r"
expect "# "

send "exit\r"
expect eof
EOF