#!/bin/bash

docker build -t test-watchdog .
docker run -d --name github-watchdog test-watchdog
docker ps | grep github-watchdog
