# A Docker base image for Ruby (web) apps

![Peter](https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png) <img src="http://blog.phusion.nl/wp-content/uploads/2013/11/docker.png" width="233" height="196" alt="Docker"></center>

Peter is a [Docker](http://www.docker.io) image meant to serve as a good base for **Ruby** web app images. This image is based on [Phusion's baseimage](https://github.com/phusion/baseimage-docker), and it's actually a modification of [Phusion's Passenger-docker Image](https://github.com/phusion/passenger-docker), but without passenger. It also has some modifications.

---------------------------------------

Differences with passenger-docker:

- Removed Phusion Passenger
- Removed Python
- Removed Ruby 1.9 and 2.0 (only 2.1 left)
- Disabled nginx by default (easy to enable)
- Disabled cron by default (easy to enable)
- Removed redis, memcached, pups
- Also installing jruby

To see all the changes, please read the [Changelog](https://github.com/eljojo/peter/blob/master/Changelog.md)

---------------------------------------

**Table of contents**

 * [Why use peter?](#why_use)
 * [About peter](#about)
   * [What's included?](#whats_included)
   * [Memory efficiency](#memory_efficiency)
 * [Inspecting the image](#inspecting_the_image)
 * [Using the image as base](#using)
   * [Getting started](#getting_started)
   * [The `app` user](#app_user)
   * [Using Nginx](#nginx)
     * [Adding your web app to the image](#adding_web_app)
     * [Configuring Nginx](#configuring_nginx)
     * [Setting environment variables in Nginx](#nginx_env_vars)
   * [Adding additional daemons](#adding_additional_daemons)
   * [Running scripts during container startup](#running_startup_scripts)
 * [Administering the image's system](#administering)
   * [Logging into the container with SSH](#login)
     * [Using your own key](#using_your_own_key)
   * [Logs](#logs)
 * [Building the image yourself](#building)
 * [Conclusion](#conclusion)

---------------------------------------

<a name="why_use"></a>
## Why use peter?

Why use peter instead of doing everything yourself in Dockerfile?

 * Your Dockerfile can be smaller.
 * It reduces the time needed to write a correct Dockerfile. You won't have to worry about the base system and the stack, you can focus on just your app.
 * It sets up the base system **correctly**. It's very easy to get the base system wrong, but this image does everything correctly. [Learn more.](https://github.com/phusion/baseimage-docker#contents)
 * It drastically reduces the time needed to run `docker build`, allowing you to iterate your Dockerfile more quickly.
 * It reduces download time during redeploys. Docker only needs to download the base image once: during the first deploy. On every subsequent deploys, only the changes you make on top of the base image are downloaded.

<a name="about"></a>
## About the image

I really liked passenger-docker, but I'm not a big fan of Passenger and I don't need to deploy python apps.
This is just a lightweight version of it.

<a name="whats_included"></a>
### What's included?

*Peter is built on top of a solid base: [baseimage-docker](http://phusion.github.io/baseimage-docker/).*

Basics (learn more at [baseimage-docker](http://phusion.github.io/baseimage-docker/)):

 * Ubuntu 14.04 LTS as base system.
 * A **correct** init process ([learn more](http://phusion.github.io/baseimage-docker/)).
 * Fixes APT incompatibilities with Docker.
 * syslog-ng.
 * The cron daemon (disabled by default)
 * The SSH server, so that you can easily login to your container to inspect or administer things. Password and challenge-response authentication are disabled by default. Only key authentication is allowed.
 * [Runit](http://smarden.org/runit/) for service supervision and management.

Language support:

 * Ruby 2.1.0, configured as default.
   * Planned to include jruby.
   * Ruby is installed through [the Brightbox APT repository](https://launchpad.net/~brightbox/+archive/ruby-ng). We're not using RVM!
 * Node.js 0.10, through [Chris Lea's Node.js PPA](https://launchpad.net/~chris-lea/+archive/node.js/).
 * A build system, git, and development headers for many popular libraries, so that the most popular Ruby and Node.js native extensions can be compiled without problems.

Web server and application server:

 * Nginx 1.6. Disabled by default.

<a name="memory_efficiency"></a>
### Memory efficiency

Peter is very lightweight on memory. In its default configuration, it only uses 10 MB of memory (the memory consumed by bash, runit, sshd, syslog-ng, etc).

<a name="inspecting_the_image"></a>
## Inspecting the image

To look around in the image, run:

    docker run -rm -t -i eljojo/peter bash -l

You don't have to download anything manually. The above command will automatically pull the passenger-docker image from the Docker registry.

<a name="using"></a>
## Using the image as base

<a name="getting_started"></a>
### Getting started

Put the following in your Dockerfile:

    # To make your builds reproducible, make
    # sure you lock down to a specific version, not to `latest`!
    FROM eljojo/peter:<VERSION>
    
    # Set correct environment variables.
    ENV HOME /root
    
    # Use baseimage-docker's init process.
    CMD ["/sbin/my_init"]
    
    # ...put your own build instructions here...
    
    # Clean up APT when done.
    RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

<a name="app_user"></a>
### The `app` user

The image has an `app` user with UID 9999 and home directory `/home/app`. Your application is supposed to run as this user. Even though Docker itself provides some isolation from the host OS, running applications without root privileges is good security practice.

Your application should be placed inside /home/app.

<a name="nginx"></a>
### Using Nginx

Nginx is disabled by default. Enable it like so:

    RUN rm -f /etc/service/nginx/down

<a name="adding_web_app"></a>
#### Adding your web app to the image

The default nginx website is disabled, so you have to add it to ``/etc/nginx/sites-enabled/your-app.conf``.
Because we're not using Passenger, you have to [set up your ruby app as a daemon](#adding_additional_daemons) and configure nginx to use a reverse proxy.

You can add a virtual host entry (`server` block) by placing a .conf file in the directory `/etc/nginx/sites-enabled`. For example:

    # /etc/nginx/sites-enabled/webapp.conf:
    server {
        listen 80;
        server_name www.webapp.com;
        root /home/app/webapp/public;
    }
    
    # Dockerfile:
    ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
    RUN mkdir /home/app/webapp
    RUN ...commands to place your web app in /home/app/webapp...

<a name="configuring_nginx"></a>
#### Configuring Nginx

The best way to configure Nginx is by adding .conf files to `/etc/nginx/main.d` and `/etc/nginx/conf.d`. Files in `main.d` are included into the Nginx configuration's main context, while files in `conf.d` are included in the Nginx configuration's http context.

For example:

    # /etc/nginx/main.d/secret_key.conf:
    env SECRET_KEY 123456;
    
    # /etc/nginx/conf.d/gzip_max.conf:
    gzip_comp_level 9;
    
    # Dockerfile:
    ADD secret_key.conf /etc/nginx/main.d/secret_key.conf
    ADD gzip_max.conf /etc/nginx/conf.d/gzip_max.conf

<a name="nginx_env_vars"></a>
#### Setting environment variables in Nginx

By default Nginx [clears all environment variables](http://nginx.org/en/docs/ngx_core_module.html#env) (except `TZ`) for its child processes (Passenger being one of them). That's why any environment variables you set with `docker run -e`, Docker linking and `/etc/container_environment`, won't reach Nginx.

To preserve these variables, place a file in the directory `/etc/nginx/main.d`. For example when linking a PostgreSQL container or MongoDB container:

    # /etc/nginx/main.d/postgres.env:
    env POSTGRES_PORT_5432_TCP_ADDR;
    env POSTGRES_PORT_5432_TCP_PORT;
    
    # Dockerfile:
    ADD postgres.env /etc/nginx/main.d/postgres.env

By default, peter already contains a config file `/etc/nginx/main.d/default.conf` which preserves the `PATH` environment variable.

<a name="adding_additional_daemons"></a>
### Adding additional daemons

You can add additional daemons (e.g. your own app) to the image by creating runit entries. You only have to write a small shell script which runs your daemon, and runit will keep it up and running for you, restarting it when it crashes, etc.

The shell script must be called `run`, must be executable, and is to be placed in the directory `/etc/service/<NAME>`.

Here's an example showing you how a memached server runit entry can be made.

    ### In memcached.sh (make sure this file is chmod +x):
    #!/bin/sh
    # `/sbin/setuser memcache` runs the given command as the user `memcache`.
    # If you omit that part, the command will be run as root.
    exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1

    ### In Dockerfile:
    RUN mkdir /etc/service/memcached
    ADD memcached.sh /etc/service/memcached/run

Note that the shell script must run the daemon **without letting it daemonize/fork it**. Usually, daemons provide a command line flag or a config file option for that.

<a name="running_startup_scripts"></a>
### Running scripts during container startup

peter uses the [baseimage-docker](http://phusion.github.io/baseimage-docker/) init system, `/sbin/my_init`. This init system runs the following scripts during startup, in the following order:

 * All executable scripts in `/etc/my_init.d`, if this directory exists. The scripts are run during in lexicographic order.
 * The script `/etc/rc.local`, if this file exists.

All scripts must exit correctly, e.g. with exit code 0. If any script exits with a non-zero exit code, the booting will fail.

The following example shows how you can add a startup script. This script simply logs the time of boot to the file /tmp/boottime.txt.

    ### In logtime.sh (make sure this file is chmod +x):
    #!/bin/sh
    date > /tmp/boottime.txt

    ### In Dockerfile:
    RUN mkdir -p /etc/my_init.d
    ADD logtime.sh /etc/my_init.d/logtime.sh

<a name="administering"></a>
## Administering the image's system

<a name="login"></a>
### Logging into the container with SSH

You can use SSH to login to any container that is based on passenger-docker-docker.

The first thing that you need to do is to ensure that you have the right SSH keys installed inside the container. By default, no keys are installed, so you can't login.

<a name="using_your_own_key"></a>
#### Using your own key

Edit your Dockerfile to install an SSH key:

    ## Install an SSH of your choice.
    ADD your_key /tmp/your_key
    RUN cat /tmp/your_key >> /root/.ssh/authorized_keys && rm -f /tmp/your_key

Then rebuild your image. Once you have that, start a container based on that image:

    docker run your-image-name

Find out the ID of the container that you just ran:

    docker ps

Once you have the ID, look for its IP address with:

    docker inspect <ID> | grep IPAddress

Now SSH into the container as follows:

    ssh -i /path-to/your_key root@<IP address>

<a name="logs"></a>
### Logs

If anything goes wrong, consult the log files in /var/log. The following log files are especially important:

 * /var/log/nginx/error.log
 * /var/log/syslog
 * Your app's log file in /home/app.

<a name="building"></a>
## Building the image yourself

If for whatever reason you want to build the image yourself instead of downloading it from the Docker registry, follow these instructions.

Clone this repository:

    git clone https://github.com/eljojo/peter.git
    cd peter

Start a virtual machine with Docker in it. You can use the Vagrantfile that we've already provided.

    vagrant up
    vagrant ssh
    cd /vagrant

Build the image:

    make

If you want to call the resulting image something else, pass the NAME variable, like this:

    make build NAME=joe/peter

Big thanks to the [Phusion](http://www.phusion.nl/) people for creating passenger-docker and baseimage. :-)

![More Peter](http://www.delish.com/cm/delish/images/Pe/peter-griffin-family-guy-del-fictional-foods-xl.jpg)

