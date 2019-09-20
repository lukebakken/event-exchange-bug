#!/bin/bash

for i in 1 2 3; do
    docker stop rabbit$i
done
