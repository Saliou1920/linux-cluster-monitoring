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

# hardware specs
cpu_number=$(grep -c ^processor /proc/cpuinfo)
cpu_architecture=$(uname -m)
cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ":" -f2 | xargs)
cpu_mhz=$(lscpu | grep "CPU MHz:" | awk '{print $3}')
l2_cache=$(lscpu | grep "L2 cache:" | awk '{print $3}')
total_mem=$(free -m | grep "Mem:" | awk '{print $2}')
timestamp=$(date +"%x %R %Z")

# insert data into db
insert_stmt="INSERT INTO host_info (
    hostname, cpu_number, cpu_architecture,
    cpu_model, cpu_mhz, l2_cache,
    total_mem, timestamp
    )
    VALUES (
        '$hostname', '$cpu_number','$cpu_architecture',
        '$cpu_model', '$cpu_mhz', '$l2_cache',
        '$total_mem','$timestamp'
    )"

# insert into database
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"
exit $?