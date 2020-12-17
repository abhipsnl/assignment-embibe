#!/bin/bash

# =================================================================================================
#
#
#      Script: github-watchdog.sh
#
# Description: Script to monitor the list of contributors for given Open GitHub Project.
#
#
# =================================================================================================

ECHO_CMD="echo"
DATE="$(date +"%b-%d-%y")"
LOGS_DIR="/var/lib/github-watchdog-logs"
CONFIG_DIR="/usr/local/config"
LOG_FILE="${LOGS_DIR}/log-github_watchdog-${DATE}.log"
CONFIG_FILE="${CONFIG_DIR}/github_watchdog.conf"
GIT_API="https://api.github.com/repos"

DisplayMessage() {
    # Display function
    TEXT="$1"
    MSG="$2"

    if [ "${MSG}" == "ERROR" ];then
        ${ECHO_CMD} "${TEXT}" | awk -v msg="${MSG}" '{printf("%5s %-140s %10s\n","",$0,"[ "msg" ]")}' | tee -a ${LOG_FILE}
    elif [ "${MSG}" == "OK" ];then
        ${ECHO_CMD} "${TEXT}" | awk -v msg="${MSG}" '{printf("%5s %-140s %10s\n","",$0,"[ "msg" ]")}' | tee -a ${LOG_FILE}
    elif [ "${MSG}" == "INFO" ];then
        ${ECHO_CMD} "${TEXT}" | awk -v msg="${MSG}" '{printf("%5s %-140s %10s\n","",$0,"[ "msg" ]")}' | tee -a ${LOG_FILE}
    elif [ "${MSG}" == "WARN" ];then
        ${ECHO_CMD} "${TEXT}" | awk -v msg="${MSG}" '{printf("%5s %-140s %10s\n","",$0,"[ "msg" ]")}' | tee -a ${LOG_FILE}
    elif [ "${MSG}" == "SKIPPED" ];then
        ${ECHO_CMD} "${TEXT}" | awk -v msg="${MSG}" '{printf("%5s %-140s %10s\n","",$0,"[ "msg" ]")}' | tee -a ${LOG_FILE}
    fi

}

SlackNotification() {
    curl -X POST -H 'Content-type: application/json; charset=utf-8' --data '{"text":"New Contributor Added to your Project"}' ${YOUR_WEBHOOK_URL}
    if [ $? -ne 0 ];then
        DisplayMessage "Failed to send slack notification" "ERROR"
        exit 1
    fi
}

SendNotification() {
    # Function to send notification
    if [ "${NOTIFICATION_CHENNEL}" != "slack" ];then
        DisplayMessage "Currently only skack option is enabled" "ERROR"
        exit 1
    fi
    case ${NOTIFICATION_CHENNEL} in
    slack)
        SlackNotification
    ;;
    twitter)
        echo "foo"
    ;;
    esac
    
}

PreRequisite() {
    # Function to check pre-requisite for this script
    if [ ! -d "${LOGS_DIR}" ];then
        mkdir -p ${LOGS_DIR}
    fi
    if [ ! -d ${CONFIG_DIR} ];then
	    mkdir -p ${CONFIG_DIR}
	    cp -r config/* ${CONFIG_DIR}/
    fi

    DisplayMessage "Checking Pre-Requisute" "INFO"
    which git >/dev/null 2>&1
    if [ $? -ne 0 ];then
        DisplayMessage "Either Git is not installed or you da not have permission to run it" "ERROR"
        exit 1
    fi

    if [ ! -f "${CONFIG_FILE}" ];then
        DisplayMessage "Config file -  ${CONFIG_FILE} not exits, please check and rerun" "ERROR"
        exit 1
    fi
    DisplayMessage "All looks Good!" "OK"
}

Header() {
    ${ECHO_CMD} "
    =============================================================

    Log file : ${LOG_FILE}
    
    =============================================================
    "
}

MonitorNewEntry() {
    # Function to identify if any new contributors added.
    INITIAL_FILE="$1"
    NEW_FILE="$2"
    PROJ="$3"
    INITIAL_COUNT=$(cat ${INITIAL_FILE} | wc -l)
    NEW_COUNT=$(cat ${NEW_FILE} | wc -l)

    if [ ${INITIAL_COUNT} -lt ${NEW_COUNT} ];then
        DisplayMessage "${NEW_COUNT} New Entry found for project ${PROJ}" "OK"
        SendNotification
        cp ${NEW_FILE} ${INITIAL_FILE}
    fi
}

WatchDog() {
  # Watch dog function to monitor contributors name for given project.
  while true
  do
      # Performing Basic validations
      . ${CONFIG_FILE}
      if [ $? -ne 0 ];then
          DisplayMessage "Failed to load the config file" "ERROR"
          exit 1
      fi
      VARIABLES=$(cat ${CONFIG_FILE} | grep -v "^#" | sed '/^$/d' | awk -F"export" '{print $2}' | awk -F"=" '{print $1}')
      if [ -z "${VARIABLES}" ];then
        DisplayMessage "No variables defined in conf file, can not continue" "ERROR"
        exit 1
      fi
 
      for var in ${VARIABLES}
      do
          variable=$(eval echo \$${var})
          if [ -z "${variable}" ];then
              DisplayMessage "Varibale ${var} can not be empty, correct and rerun it" "ERROR"
              exit 1
          fi
      done

      GITHUB_PROJECTS="$(echo ${GITHUB_PROJECTS} | sed 's/,/ /g')"
      for project in ${GITHUB_PROJECTS}
      do
          if [ ! -f "${GIT_USERNAME}-${project}-initial-data.txt" ];then
              curl -s ${GIT_API}/${GIT_USERNAME}/${project}/contributors | grep "login" 1>${GIT_USERNAME}-${project}-initial-data.txt
              if [ $? -ne 0 ];then
                  #DisplayMessage "Failed to fetch details for - ${project} project, or this project does not have any contributors yet." "ERROR"
                  continue
              fi
          else
              if [ -s "${GIT_USERNAME}-${project}-initial-data.txt" ];then
                  #DisplayMessage "Fetching latest details for - ${project} project" "INFO"
                  curl -s ${GIT_API}/${GIT_USERNAME}/${project}/contributors | grep "login" 1>${GIT_USERNAME}-${project}-new-data.txt
                  if [ $? -ne 0 ];then
                      DisplayMessage "Failed to fetch details for - ${project} project" "ERROR"
                      exit 1
                  fi
                  MonitorNewEntry "${GIT_USERNAME}-${project}-initial-data.txt" "${GIT_USERNAME}-${project}-new-data.txt" "${project}"
              else
                  #DisplayMessage "Fetching initial details for - ${project} project" "INFO"
                  curl ${GIT_API}/${GIT_USERNAME}/${project}/contributors 2>>${LOG_FILE} | grep "login" 1>${GIT_USERNAME}-${project}-initial-data.txt
                  if [ $? -ne 0 ];then
                      #DisplayMessage "Failed to fetch details for - ${project} project, or this project does not have any contributors yet" "ERROR"
                      continue
                 fi
              fi
          fi

      done
      sleep ${POLLING_INTERVAL}
    done
}

# Main
Header
PreRequisite
WatchDog
