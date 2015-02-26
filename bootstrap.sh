#!/bin/bash

function green { G='\033[0;32m'; NC='\033[0m'; echo -e "${G}$1${NC}"; }

green ">>> Downloading and installing Puppetlabs Debian repository."

wget https://apt.puppetlabs.com/puppetlabs-release-testing.deb
dpkg -i puppetlabs-release-testing.deb
apt-get update

green ">>> Installing Puppet."

apt-get install puppet

green ">>> Removing the repository again."

apt-get remove puppetlabs-release

green ">>> Bootstrapping."

puppet apply puppetmaster-bootstrap.pp

cat << EOF
***
Puppet bootstrapping completed (unless there were errors…).

Now, copy or create the eyaml keys to

    /etc/puppet/keys/private_key.pkcs7.pem
    /etc/puppet/keys/public_key.pkcs7.pem

and make sure it can be read by puppet.

    chown -R puppet:puppet /etc/puppet/keys/
    systemctl restart puppetmaster

Also, clone your site’s r10k repository to

    /opt/puppetenvironments/

Finally, deploy with

    r10k deploy environment -p

and test on your puppet master node:

    puppet agent -t

(Try a couple of times and throw in a bunch of reboots.)
***
EOF

