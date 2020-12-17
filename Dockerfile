FROM ubuntu
COPY . /app
WORKDIR /app
RUN apt-get update && \
    apt-get install -y curl git

ENTRYPOINT if [ ! -d /usr/local/config ];then mkdir -p /usr/local/config ;fi ; cp -r config/* /usr/local/config/ ; bash github-watchdog.sh
