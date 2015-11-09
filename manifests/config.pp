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
  concat { 'ezproxy groups':
    ensure => present,
    path   => "${::ezproxy::install_path}/groups.txt",
    owner  => $::ezproxy::ezproxy_user,
    group  => $::ezproxy::ezproxy_group,
  }
  ezproxy::group { 'Default':
    auto_login_ips => $::ezproxy::auto_login_ips,
    include_ips    => $::ezproxy::include_ips,
    exclude_ips    => $::ezproxy::exclude_ips,
    reject_ips     => $::ezproxy::reject_ips,
    group_order    => '999999',
  }
  if $::ezproxy::default_stanzas {
    ezproxy::stanza { 'Worldcat.org':
      urls      => [ 'http://worldcat.org' ],
      domain_js => [ 'worldcat.org' ],
      order     => '1',
      group     => 'Default',
    }
    ezproxy::stanza { 'WhatIsMyIP':
      urls      => [ 'http://whatismyip.com' ],
      domain_js => [ 'whatismyip.com' ],
      order     => '1',
      group     => 'Default',
    }
    ezproxy::stanza { 'DOI System':
      urls    => [ 'http://dx.doi.org' ],
      domains => [ 'doi.org' ],
      order   => '1',
      group   => 'Default',
      hide    => true,
    }
  }
  create_resources(ezproxy::group, $::ezproxy::groups, {})
  create_resources(ezproxy::stanza, $::ezproxy::stanzas, {})
  create_resources(ezproxy::remote_config, $::ezproxy::remote_configs, {})
}
