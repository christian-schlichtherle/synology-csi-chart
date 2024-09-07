FROM debian
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update --quiet=2 && apt-get install fio --quiet=2 && rm -rf /var/lib/apt/lists/* && mkdir /data
WORKDIR /data
COPY test.fio .
VOLUME /data
