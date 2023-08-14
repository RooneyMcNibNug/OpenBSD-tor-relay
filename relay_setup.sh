## Make sure to run this from the 
## Requires running with doas (OpenBSD's sudo alternative) with proper perms for user

login_conf_section="tor:\
    :openfiles-max=13500:\
    :tc=daemon:"

weekly_local_section="#!/bin/sh\
PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin"\
RAND=$(jot -r 1 900)\
sleep ${RAND}\
pkg_add -u -I &&\
rcctl restart tor"

# Install obfsuproxy package
pkg_add -i tor obfs4proxy

# Force copy of the local torrc to overwrite the one in /etc/tor/
cp -rf ./torrc /etc/tor/torrc

# Append the new section to the file
echo "$login_conf_section" | sudo tee -a /etc/login.conf > /dev/null

echo "kern.maxfiles=16000" >> /etc/sysctl.conf
sysctl kern.maxfiles=16000

# Enable Automatic package update checks (every week) for security
# !NOTE!: This is assuming your server is dedicated to provide a Tor relay. Please be aware that services will be restarted during the automatic software update process documented here. It will automatically upgrade all other non-tor-relevant packages as well.

echo "$weekly_local_section" | sudo tee -a /etc/weekly.local > /dev/null
rcctl restart cron

# Enable tor and start with all the latest configurations
rcctl enable tor
rcctl start tor

# Print out syslogs for ensuring things are configured/running properly
tail /var/log/messages
