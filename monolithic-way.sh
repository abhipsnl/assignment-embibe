#!/bin/bash

sudo cp github-watchdog.service /etc/systemd/system/
sudo cp github-watchdog.sh /usr/local/bin/
sudo systemctl enable github-watchdog.service
sudo systemctl daemon-reload
sudo service github-watchdog start
service github-watchdog status
