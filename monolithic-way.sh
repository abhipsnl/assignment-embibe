#!/bin/bash

sudo cp github-watchdog.service /etc/systemd/system/
sudo systemctl enable github-watchdog.service
service github-watchdog status
