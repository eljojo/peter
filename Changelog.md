## 0.9.11

 * Using chruby and ruby-install
 * removed passenger-docker's ruby
 * installing jruby and ruby 2.1.2
 * Using GraphicsMagick instead of ImageMagick (lightweight alternative)
 * Installing wget and curl
 * Added github ssh public key to /home/app/.ssh/known_hosts
 * Added LC_ALL=en_US.UTF-8 and RAILS_ENV=production as ENV variables

## 0.9.10 (release date: 2014-06-20)

 * Initial release, based on version passenger-docker-customizable 0.9.11
 * Changes from passenger-docker:
   * Removed passenger, python, redis, memcached, pups and ruby (1.9, 2.0)
   * Disabled cron by default

