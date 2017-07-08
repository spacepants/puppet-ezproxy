# ezproxy::group
#
# This define builds a group fragment to be used in the sites config file.
# It also builds the default group which is always used even if you're not
# adding any additional groups. This is the default EZProxy behavior.
#
# @param auto_login_ips Array of IPs to autologin for this group.
# @param include_ips Array of IPs to include for this group.
# @param exclude_ips Array of IPs to exclude for this group.
# @param reject_ips Array of IPs to reject for this group.
# @param group_order Sets the load order for this group.
#
define ezproxy::group (
  Array  $auto_login_ips = [],
  Array  $include_ips    = [],
  Array  $exclude_ips    = [],
  Array  $reject_ips     = [],
  String $group_order    = '0',
) {

  concat { "ezproxy group ${title}":
    ensure => present,
    path   => "${::ezproxy::install_dir}/group_${title}.txt",
    owner  => $::ezproxy::user,
    group  => $::ezproxy::group,
  }

  concat::fragment { "${title} header":
    target  => "ezproxy group ${title}",
    content => template('ezproxy/group.erb'),
    order   => '0',
  }

  concat::fragment { "${title} load order":
    target  => 'ezproxy groups',
    content => "IncludeFile group_${title}.txt\n",
    order   => $group_order,
  }
}
