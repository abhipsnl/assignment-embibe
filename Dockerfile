FROM ubuntu
COPY . /app
WORKDIR /app
RUN apt-get update && \
    apt-get install -y curl git

ENTRYPOINT bash github_watchdog.sh
