# == Define ezproxy::group
#
# This define builds a group fragment to be used in the sites config file.
# It also builds the default group which is always used even if you're not
# adding any additional groups. This is the default EZProxy behavior.
#
#
# === Parameters
#
# [*auto_login_ips*]
#   Array of IPs to autologin for this group.
#
# [*include_ips*]
#   Array of IPs to include for this group.
#
# [*exclude_ips*]
#   Array of IPs to exclude for this group.
#
# [*reject_ips*]
#   Array of IPs to reject for this group.
#
define ezproxy::group (
  $auto_login_ips = [],
  $include_ips    = [],
  $exclude_ips    = [],
  $reject_ips     = [],
  $group_order    = '0',
  ) {

  if $auto_login_ips {
    validate_array($auto_login_ips)
  }
  if $include_ips {
    validate_array($include_ips)
  }
  if $exclude_ips {
    validate_array($exclude_ips)
  }
  if $reject_ips {
    validate_array($reject_ips)
  }
  validate_string($order)

  concat { "ezproxy group ${name}":
    ensure => present,
    path   => "${::ezproxy::install_path}/group_${name}.txt",
    owner  => $::ezproxy::ezproxy_user,
    group  => $::ezproxy::ezproxy_group,
  }

  concat::fragment { "${name} header":
    target  => "ezproxy group ${name}",
    content => template('ezproxy/group.erb'),
    order   => '0',
  }

  concat::fragment { "${name} load order":
    target  => 'ezproxy groups',
    content => "IncludeFile group_${name}.txt\n",
    order   => $group_order,
  }
}
