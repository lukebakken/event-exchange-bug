#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1

./cleanup.sh

docker network create rabbit-test

if [[ ! -f erlang-cookie.key ]]; then
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 64 > erlang-cookie.key
	chmod 400 erlang-cookie.key
fi

for i in 1 2 3; do
    docker run -it -d --rm --name rabbit$i -h rabbit$i --net=rabbit-test -v $PWD/enabled_plugins:/etc/rabbitmq/enabled_plugins -v $PWD/erlang-cookie.key:/var/lib/rabbitmq/.erlang.cookie -p 567$i:5672 rabbitmq:$VERSION
done

docker exec rabbit2 bash -c 'rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\@${HOSTNAME}.pid; rabbitmqctl stop_app; rabbitmqctl join_cluster rabbit@rabbit1; rabbitmqctl start_app'
docker exec rabbit3 bash -c 'rabbitmqctl stop_app; rabbitmqctl join_cluster rabbit@rabbit1; rabbitmqctl start_app'
