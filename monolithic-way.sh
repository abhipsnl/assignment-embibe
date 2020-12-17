#!/bin/bash

sudo cp github-watchdog.service /etc/systemd/system/
sudo cp github-watchdog.sh /usr/local/bin/
if [ ! -d /usr/local/config ];then
    mkdir -p /usr/local/config
    sudo cp -r config /usr/local/
fi    
sudo systemctl enable github-watchdog.service
sudo systemctl daemon-reload
sudo service github-watchdog start
service github-watchdog status
