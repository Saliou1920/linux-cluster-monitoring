#! /bin/sh

cmd=$1
db_username=$2
db_password=$3

#start docker
sudo systemctl status docker || sudo systemctl start docker

# check container status
container_status=$(docker container inspect jrvs-psql | grep -c "\"State\": {\"Running\": true")

case $cmd in 
    create)
        if [ $container_status -eq 0 ]; then
            echo "Container already exists"
            exit 1
        fi

        if [$# -ne 3]; then
            echo "Create requires username and password"
            exit 1
        fi

        # create container
        docker volume create jrvs-psql-volume
        docker run --name jrvs-psql -e POSTGRES_PASSWORD=$db_password -d -v jrvs-psql-volume:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
        exit $?
        ;;

    start|stop)
        if [ $container_status -eq 0 ]; then
            echo "Container does not exist"
            exit 1
        fi

        if [ $# -ne 2 ]; then
            echo "Start or stop requires no arguments"
            exit 1
        fi

        # start or stop container
        docker container $cmd jrvs-psql
        exit $?
        ;;

        *)
            
    echo "Illegal command"
    echo "Usage: ./psql_docker.sh start|stop|create"
    exit 1
    ;;

esac