# ezproxy::remote_config
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
# [*group*]
#   Group for the stanza.
#
define ezproxy::remote_config (
  String           $download_link,
  String           $file_name,
  String           $order         = '1',
  String           $group         = 'default',
  Optional[String] $maxdays       = undef,
) {

  if $maxdays {
    exec { "refreshing ${name} config: older than ${maxdays} days":
      command => "rm ${::ezproxy::install_dir}/${file_name}",
      path    => '/sbin:/bin:/usr/sbin:/usr/bin',
      onlyif  => "find ${::ezproxy::install_dir}/${file_name} -mtime +${maxdays} | grep ${file_name}",
      before  => Exec["download ${name} config"],
    }
  }

  exec { "download ${name} config":
    command => "curl -o ${::ezproxy::install_dir}/${file_name} ${download_link}",
    creates => "${::ezproxy::install_dir}/${file_name}",
    path    => '/sbin:/bin:/usr/sbin:/usr/bin',
    notify  => Exec["sanitize ${name} config"],
    require => File[$::ezproxy::install_dir]
  }

  exec { "sanitize ${name} config":
    command     => "dos2unix ${::ezproxy::install_dir}/${file_name}",
    path        => '/sbin:/bin:/usr/sbin:/usr/bin',
    refreshonly => true,
  }

  concat::fragment { $name:
    target  => "ezproxy group ${group}",
    source  => "${::ezproxy::install_dir}/${file_name}",
    order   => $order,
    require => Exec["sanitize ${name} config"]
  }
}
