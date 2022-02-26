#!/bin/bash

# CLI args
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ $# -ne 5 ]; then
    echo "Usage: ./host_info.sh <psql_host> <psql_port> <db_name> <psql_user> <psql_password>"
    exit 1
fi

vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)
memory_free=$(echo "$vmstat_mb" | awk '{print $4}'|tail -n1 | xargs)
cpu_idle=$(echo "$vmsat_mb" | awk '{print $15}'|tail -n1 | xargs)
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}'|tail -n1 | xargs)
disk_io=$(echo "$vmstat_mb" | awk '{print $5}'|tail -n1 | xargs)
disk_available=$(df -h | grep "/dev/sda1" | awk '{print $4}')
timestamp=$(date +"%x %R %Z")
host_id=($(psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "SELECT id FROM host_info WHERE hostname='$hostname';" | tail -n1))


insert_stmt="INSERT INTO host_usage (
    host_id, memory_free, cpu_idle,
    cpu_kernel, disk_io, disk_available,
    timestamp
    )
    VALUES (
        '$host_id', '$memory_free', '$cpu_idle',
        '$cpu_kernel', '$disk_io', '$disk_available',
        '$timestamp'
    )"

export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"
exit $?