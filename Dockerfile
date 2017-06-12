# How to run this script from same folder:
# docker build .

FROM ubuntu:14.04
MAINTAINER Chinmay Kolhatkar <chinmay@apache.org>

COPY app/ /app/
RUN chmod +x /app/setup.sh
RUN /app/setup.sh

USER openemm
WORKDIR /home/openemm
EXPOSE 50070 8088
#ENTRYPOINT ["/app/init.sh"]

