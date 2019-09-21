#!/bin/bash

# if [[ -z "$1" ]]; then
#     echo "Usage: $0 <version>"
#     exit 1
# fi
# VERSION=$1
# ./create-cluster.sh $VERSION

rm _output

cd consumer
yarn
cd ..

node consumer > _output &
declare -ri consumer_pid="$!"

echo 'Sleeping 2 seconds...'
sleep 2

declare -ri start_port=5672
declare -ri num_consumers=3
declare -ri end_port="$((start_port + num_consumers))"
declare -i port=0

for ((port = start_port; port < end_port; port++))
do
    node consumer/conn "$port" 1 &
done

echo 'Sleeping 5 seconds...'
sleep 5

echo "Killing consumer pid $consumer_pid..."
kill "$consumer_pid"
wait "$consumer_pid"

readonly create_events="$(grep -E '^created' _output | wc -l)"
readonly close_events="$(grep -E '^closed' _output | wc -l)"

echo

if [[ $create_events -ne $num_consumers ]] || [[ $close_events -ne $num_consumers ]]
then
    echo --- MISSING EVENTS ---
    echo
    exit 1
fi

echo --- SUCCESS ---
echo
