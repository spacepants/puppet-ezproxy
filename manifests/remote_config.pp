# == Define ezproxy::remote_config
#
# This define downloads a config file from a remote host and
# includes it in the sites.txt config file.
#
# === Parameters
#
# [*download_link*]
#   URL of the config file to download.
#
# [*file_name*]
#   File name to download as. Also used as the source for the
#   concat fragment.
#
# [*order*]
#   Include order for the stanza.
#
define ezproxy::remote_config (
  $download_link = undef,
  $file_name     = undef,
  $order         = '1',
  ) {
  validate_string($download_link)
  validate_string($file_name)
  validate_absolute_path("${::ezproxy::install_path}/${file_name}")
  validate_string($order)

  $cmd = "curl -o ${::ezproxy::install_path}/${file_name} ${download_link}"
  exec { "download ${name} config":
    command => $cmd,
    creates => "${::ezproxy::install_path}/${file_name}",
    path    => '/sbin:/bin:/usr/sbin:/usr/bin',
    require => File[$::ezproxy::install_path]
  }

  concat::fragment { $name:
    ensure  => present,
    target  => 'ezproxy sites',
    source  => "${::ezproxy::install_path}/${file_name}",
    order   => $order,
    require => Exec["download ${name} config"]
  }
}
