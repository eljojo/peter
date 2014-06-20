FROM phusion/baseimage:0.9.10
MAINTAINER jojo [at] eljojo [dot] net

ENV HOME /root
ENV LC_ALL en_US.UTF-8
ENV RAILS_ENV production

RUN mkdir /build
ADD . /build
RUN /build/install.sh
CMD ["/sbin/my_init"]
EXPOSE 80 443
