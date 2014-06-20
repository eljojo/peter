#!/bin/bash
set -e
source /build/buildconfig
set -x

/build/enable_repos.sh
/build/prepare.sh
/build/utilities.sh

/build/ruby2.1.sh
/build/nodejs.sh

# Must be installed after Ruby, so that we don't end up with two Ruby versions.
/build/nginx.sh

/build/finalize.sh
