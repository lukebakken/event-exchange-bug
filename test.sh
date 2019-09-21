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
CONSUMER_PID=$!

sleep 2

# for i in 2 3 4; do
for i in 2 3
do
    # node consumer/conn -q 567$i 1
    node consumer/conn 567$i 1
done

echo 'Sleeping 2 seconds...'
sleep 2

echo "Killing consumer pid $CONSUMER_PID..."
kill $CONSUMER_PID
wait $CONSUMER_PID

readonly create_events="$(grep -E '^created' _output | wc -l)"
readonly close_events="$(grep -E '^closed' _output | wc -l)"

echo
if [[ $create_events -ne 2 ]] || [[ $close_events -ne 2 ]]; then
    echo --- MISSING EVENTS ---
    echo
    exit 1
fi

echo --- SUCCESS ---
echo
