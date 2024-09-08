FROM debian
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update --quiet=2 && apt-get install fio=3.33-3 --quiet=2 && rm -rf /var/lib/apt/lists/* && mkdir /data
COPY test.fio /
WORKDIR /tmp
CMD ["sh", "-cx", "df -h .; fio /test.fio"]
