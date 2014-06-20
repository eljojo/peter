#!/bin/bash
set -e
source /build/buildconfig
set -x

cd /tmp
wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
tar -xzvf chruby-0.3.8.tar.gz
cd chruby-0.3.8/
make install

echo "if [ -n \"\$BASH_VERSION\" ] || [ -n \"\$ZSH_VERSION\" ]; then\n  source /usr/local/share/chruby/chruby.sh\n  chruby use ruby\nfi">/etc/profile.d/chruby.sh

cd /tmp
wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz
tar -xzvf ruby-install-0.4.3.tar.gz
cd ruby-install-0.4.3/
make install

# echo "gem: --no-ri --no-rdoc" > /etc/gemrc
echo "gem: --no-ri --no-rdoc" > /home/app/.gemrc
echo "compat.version=2.0" > /home/app/.jrubyrc

ruby-install ruby
chruby-exec ruby -- gem install bundler rake

ruby-install jruby
chruby-exec jruby -- gem install bundler rake

