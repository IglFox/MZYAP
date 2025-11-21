FROM ubuntu:latest

RUN apt-get update && apt-get install -y build-essential nasm gcc make

WORKDIR /labs

COPY . .


RUN chmod -R 777 .



