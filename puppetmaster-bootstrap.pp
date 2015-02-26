
# Base packages
package { [
  'git',
  'ruby-dev',
  'make',
  'sudo',
  'puppetmaster',
  'hiera-eyaml',
  ]: }

# Librarian for Puppetfile management
package { 'librarian-puppet':
  ensure   => 'installed',
  provider => 'gem',
  require => [ Package["ruby-dev"], Package["make"] ],
}

# R10K for automated environments
package { 'r10k':
  ensure   => 'installed',
  provider => 'gem',
  require => [ Package["ruby-dev"], Package["make"] ],
}


# Set up hiera.
# This also requires the eyaml keys to be copied manually
file { '/etc/hiera.yaml':
  content => '
---
:backends:
  - eyaml
  - yaml
:logger: console
:hierarchy:
  - secure
  - "nodes/%{fqdn}"
  - "%{environment}"
  - common

:yaml:
   :datadir: /etc/puppet/environments/%{environment}/hiera

:eyaml:
   :datadir: /etc/puppet/environments/%{environment}/hiera
   :pkcs7_private_key: /etc/puppet/keys/private_key.pkcs7.pem
   :pkcs7_public_key:  /etc/puppet/keys/public_key.pkcs7.pem

',
  owner => root,
  group => root,
  mode => '0644',
  require => Package[ puppetmaster ],
}

file { '/etc/puppet/hiera.yaml':
  ensure => 'link',
  target => '/etc/hiera.yaml',
  require => File[ '/etc/hiera.yaml' ],
}


# Set up r10k
# Per default, the remote directory points to a local git repository.
# This may be changed manually
file { '/etc/r10k.yaml':
  require => Package[ r10k ],
  content => "
# The location to use for storing cached Git repos
:cachedir: '/var/cache/r10k'

# A list of git repositories to create
:sources:
  # This will clone the git repository and instantiate an environment per
  # branch in /etc/puppet/environments
  :main:
    remote: '/opt/puppetenvironments'
    basedir: '/etc/puppet/environments'
",
  owner => root,
  group => root,
  mode => '0644',
}

# Use future parser and enable the r10k environments
augeas { 'puppet.conf':
  context => '/files/etc/puppet/puppet.conf',
  changes => [
    'set main/parser future',
    'set master/environmentpath /etc/puppet/environments',
    'set master/basemodulepath /etc/puppet/environments/common:/etc/puppet/modules:/usr/share/puppet/modules',
  ],
  require => Package[ puppetmaster ],
}

