#!/bin/bash

docker build -t prosyslab/dude:latest --build-arg CACHEBUST=$(date +%s) .
docker push prosyslab/dude:latest
