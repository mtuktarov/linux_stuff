#!/bin/bash

docker build . -t flask:latest
docker network create -d bridge mybridge
for i in {1..3} ; do docker run --network=mybridge -e FLASK_HOST=0.0.0.0 --rm --hostname flask-app$i --name flask-app$i -d flask:latest ; done
docker run --network=mybridge --rm --hostname nginx --name nginx -d -v $(pwd)/nginx-app.conf:/etc/nginx/conf.d/nginx-app.conf -p 80:80 imkulikov/nginx-sticky
