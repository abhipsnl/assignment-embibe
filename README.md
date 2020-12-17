Github Watchdog
=================

Description
-------------
This README file help you to deploy github watchdog , github watchdog is a solution,
which monitor contributions list for given open github project


Variables
----------
`GITHUB_PROJECTS`                                            # Name of the github project, for multiple projects add the name with comma (,)
`NOTIFICATION_CHENNEL`                                       # Supported channels are slack, email, Twitter account.
`YOUR_WEBHOOK_URL`
`POLLING_INTERVAL`                                           # Supported input Seconds, Minutes, Hour, ( 10s, 10m, 1h)
`GIT_USERNAME`                                               # GitHub Username




Example
---------
monolithic way
---------------
1) git clone https://github.com/sharmajee1/assignment-embibe.git

2) Modify config/github_watchdog.conf based on your need.

2) cd assignment-embibe && ./monolithic-way.sh

3) service github-watchdog status 


Author
------
Abhishek Sharma ( github sharmajee1)
