# == Define ezproxy::stanza
#
# This define builds a stanza fragment to be used in the sites config file.
#
# === Parameters
#
# [*hide*]
#   Boolean for whether or not to include the hide flag in the title line.
#
# [*hide_flag*]
#   String to include in the title line if $hide is true.
#
# [*urls*]
#   Array of URLs for the stanza.
#
# [*hosts*]
#   Array of hosts for the stanza.
#
# [*domains*]
#   Array of domains for the stanza.
#
# [*domain_js*]
#   Array of domainjavascript entries for the stanza.
#
# [*host_js*]
#   Array of hostjavascript entries for the stanza.
#
# [*prepends*]
#   Array of stanza options to include at the beginning of the stanza.
#
# [*appends*]
#   Array of stanza options to include at the end of the stanza.
#
# [*order*]
#   Include order for the stanza.
#
# [*group*]
#   Group for the stanza.
#
define ezproxy::stanza (
  Boolean $hide      = false,
  String  $hide_flag = '-hide',
  Array   $urls      = [],
  Array   $hosts     = [],
  Array   $domains   = [],
  Array   $domain_js = [],
  Array   $host_js   = [],
  Array   $prepends  = [],
  Array   $appends   = [],
  String  $order     = '2',
  String  $group     = 'default',
) {

  concat::fragment { $name:
    target  => "ezproxy group ${group}",
    content => template('ezproxy/stanza.erb'),
    order   => $order,
  }
}
