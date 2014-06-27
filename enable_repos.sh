#!/bin/bash
set -e
source /build/buildconfig
set -x

# Temporary workaround for https://github.com/phusion/baseimage-docker/issues/73
# TODO: remove this when baseimage-docker 0.9.11 is released
apt-get update
apt-get install -y ca-certificates

## Brightbox Ruby 1.9.3, 2.0 and 2.1
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3173AA6
echo deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main > /etc/apt/sources.list.d/brightbox.list

## Chris Lea's Node.js PPA
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12
echo deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu trusty main > /etc/apt/sources.list.d/nodejs.list

apt-get update
