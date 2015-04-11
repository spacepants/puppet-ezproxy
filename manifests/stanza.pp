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
define ezproxy::stanza (
  $hide      = false,
  $hide_flag = '-hide',
  $urls      = [],
  $hosts     = [],
  $domains   = [],
  $domain_js = [],
  $host_js   = [],
  $prepends  = [],
  $appends   = [],
  $order     = '1',
  ) {

  validate_bool($hide)
  validate_string($hide_flag)
  if $urls {
    validate_array($urls)
  }
  if $hosts {
    validate_array($hosts)
  }
  if $domains {
    validate_array($domains)
  }
  if $domain_js {
    validate_array($domain_js)
  }
  if $host_js {
    validate_array($host_js)
  }
  if $prepends {
    validate_array($prepends)
  }
  if $appends {
    validate_array($appends)
  }
  validate_string($order)

  concat::fragment { $name:
    ensure  => present,
    target  => 'ezproxy sites',
    content => template('ezproxy/stanza.erb'),
    order   => $order,
  }
}
