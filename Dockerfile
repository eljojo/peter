FROM phusion/baseimage:0.9.11
MAINTAINER jojo [at] eljojo [dot] net

ENV HOME /root
ENV LC_ALL en_US.UTF-8
ENV RAILS_ENV production

RUN mkdir /build
ADD . /build
RUN /build/install.sh
CMD ["/sbin/my_init"]

RUN rm /usr/sbin/enable_insecure_key /etc/insecure_key.pub

EXPOSE 80 443
