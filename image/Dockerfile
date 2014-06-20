FROM phusion/baseimage:0.9.10
MAINTAINER jojo [at] eljojo [dot] net

ENV HOME /root
RUN mkdir /build
ADD . /build
RUN /build/install.sh
CMD ["/sbin/my_init"]
EXPOSE 80 443
