#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1

./create-cluster.sh $VERSION

cd consumer
yarn
cd ..

node consumer > _output &
CONSUMER_PID=$!

sleep 2

for i in 1 2 3; do
    node consumer/conn -q 567$i 1
done

kill $CONSUMER_PID
wait $CONSUMER_PID

CREATE_EVENTS=$(grep created _output | wc -l)
CLOSE_EVENTS=$(grep closed _output | wc -l)

rm _output

echo
if [[ $CREATE_EVENTS -ne 3 ]] || [[ $CLOSE_EVENTS -ne 3 ]]; then
    echo --- MISSING EVENTS ---
    echo
    exit 1
fi

echo --- SUCCESS ---
echo
