# == Class ezproxy::config
#
# This class is called from ezproxy for service config.
#
class ezproxy::config {
  file { "${::ezproxy::install_path}/user.txt":
    ensure  => file,
    owner   => $::ezproxy::ezproxy_user,
    group   => $::ezproxy::ezproxy_group,
    content => template('ezproxy/user.txt.erb')
  }
  file { "${::ezproxy::install_path}/config.txt":
    ensure  => file,
    owner   => $::ezproxy::ezproxy_user,
    group   => $::ezproxy::ezproxy_group,
    content => template('ezproxy/config.txt.erb')
  }
  concat { 'ezproxy sites':
    ensure => present,
    path   => "${::ezproxy::install_path}/sites.txt",
    owner  => $::ezproxy::ezproxy_user,
    group  => $::ezproxy::ezproxy_group,
  }
  if $::ezproxy::default_stanzas {
    ezproxy::stanza { 'Worldcat.org':
      urls      => [ 'http://worldcat.org' ],
      domain_js => [ 'worldcat.org' ],
      order     => '0',
    }
    ezproxy::stanza { 'WhatIsMyIP':
      urls      => [ 'http://whatismyip.com' ],
      domain_js => [ 'whatismyip.com' ],
      order     => '0',
    }
    ezproxy::stanza { 'DOI System':
      urls    => [ 'http://dx.doi.org' ],
      domains => [ 'doi.org' ],
      order   => '0',
      hide    => true,
    }
  }
  create_resources(ezproxy::stanza, $::ezproxy::stanzas, {})
  create_resources(ezproxy::remote_config, $::ezproxy::remote_configs, {})
}
