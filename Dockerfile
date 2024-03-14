FROM debian:latest

RUN apt update
RUN apt -y install git curl jq jp2a nano

ENTRYPOINT bash
