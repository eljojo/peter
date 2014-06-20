#!/bin/bash
set -e
source /build/buildconfig
set -x

cd /tmp
wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
tar -xzvf chruby-0.3.8.tar.gz
cd chruby-0.3.8/
make install

echo "if [ -n \"\$BASH_VERSION\" ] || [ -n \"\$ZSH_VERSION\" ]; then">/etc/profile.d/chruby.sh
echo "  source /usr/local/share/chruby/chruby.sh">>/etc/profile.d/chruby.sh
echo "  chruby ruby">>/etc/profile.d/chruby.sh
echo "fi">>/etc/profile.d/chruby.sh

cd /tmp
wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz
tar -xzvf ruby-install-0.4.3.tar.gz
cd ruby-install-0.4.3/
make install

setuser app echo "gem: --no-ri --no-rdoc" > /home/app/.gemrc
setuser app echo "compat.version=2.0" > /home/app/.jrubyrc

ruby-install ruby -- --disable-install-doc
setuser app /usr/local/bin/chruby-exec ruby -- gem install bundler rake

apt-get install -y openjdk-7-jre-headless
ruby-install jruby --no-install-deps
setuser app chruby-exec jruby -- gem install bundler rake

