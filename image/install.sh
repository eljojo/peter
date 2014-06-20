#!/bin/bash
set -e
source /build/buildconfig
set -x

/build/enable_repos.sh
/build/prepare.sh
/build/utilities.sh

/build/devheaders.sh
/build/ruby2.1.sh
/build/nodejs.sh
/build/nginx.sh

/build/finalize.sh
