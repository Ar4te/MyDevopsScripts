#!/bin/bash
export sum=0
# 从sqlserver数据库读取要同步的数据表
cmd ./big_tables_file | while IFS= read -r line
do
  #去除前后空格
  line=$(echo $line | tr -d ' ')
  # 检查数据表在目标库是否存在，同时对目标数据表统计行数
  export sum=$(($sum + 1))
  v=$(mysql -h10.10.13.47 -P3306 -uadmin -pyR8NWLUa -D mesdb -N -e "select count(*) from $line;" 2>/dev/null | grep -v "^$")
  if [ $? -ne 0 ] ; then
    echo "table $line is not exist in mysql"
    continue
  fi
  # 对源表取数据行数
  o=$(sqlcmd -S tcp:10.10.13.11,1433 -U sa -P dz@123456 -d mesdb -h -1 -Q "select count(*) from $line;" | grep -v "row affected"| grep -v "^$")

  # 源表有数据才需要同步
  if [ $o -gt 0 ] ; then
    # 源表行数与目标表行数不一致才需要同步
    if [ $o -ne $v ]; then
       echo $sum-$line $o - $v
       # 如果目标表数据为空，选择insert，有数据的情况下选择update
       if [ $v -eq 0 ]; then
         python /opt/datax/bin/datax.py -j "-Xms2g -Xmx2g" -p "-DtableName='${line}'" /opt/datax/job/insert.json --loglevel info | grep "任务" | grep -v WARN &
       else
         python /opt/datax/bin/datax.py -j"-Xms2g -Xmx2g" -p "-DtableName='${line}'" /opt/datax/job/update.json --loglevel info | grep "任务" | grep -v WARN &
       fi
    fi
  else
    # 源表无数据，但目标表有数据
    if [ $v -gt 0 ]; then
       echo $sum $line $o - $v
python /opt/datax/bin/datax.py -j"-Xms2g -Xmx2g" -p "-DtableName='${line}'" /opt/datax/job/update.json --loglevel info | grep "任务" | grep -v WARN & 
    fi
  fi
done