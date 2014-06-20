#!/bin/bash
set -e
source /build/buildconfig
set -x

## Many Ruby gems and NPM packages contain native extensions and require a compiler.
$minimal_apt_get_install build-essential

$minimal_apt_get_install git wget curl

## Disable Cron by default
touch /etc/service/cron/down
