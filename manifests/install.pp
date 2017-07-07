# == Class ezproxy::install
#
# This class is called from ezproxy for install.
#
class ezproxy::install {

  $version = $::ezproxy::version
  $download_version = regsubst($version, '\.', '-', 'G')

  group { $::ezproxy::ezproxy_group:
    ensure => present,
    system => true,
  }
  user { $::ezproxy::ezproxy_user:
    ensure  => present,
    system  => true,
    home    => $::ezproxy::install_path,
    shell   => $::ezproxy::ezproxy_shell,
    gid     => $::ezproxy::ezproxy_group,
    require => Group[$::ezproxy::ezproxy_group]
  }

  file { $::ezproxy::install_path:
    ensure  => directory,
    owner   => $::ezproxy::ezproxy_user,
    group   => $::ezproxy::ezproxy_group,
    recurse => true,
    require => User[$::ezproxy::ezproxy_user]
  }

  exec { 'download ezproxy':
    command => "curl -o ${::ezproxy::install_path}/ezproxy ${::ezproxy::download_url}/${download_version}/ezproxy-linux.bin",
    creates => "${::ezproxy::install_path}/ezproxy",
    path    => '/sbin:/bin:/usr/sbin:/usr/bin',
    require => File[$::ezproxy::install_path]
  }

  file { "${::ezproxy::install_path}/ezproxy":
    ensure  => present,
    mode    => '0755',
    owner   => $::ezproxy::ezproxy_user,
    group   => $::ezproxy::ezproxy_group,
    require => Exec['download ezproxy'],
    notify  => Exec['bootstrap ezproxy']
  }

  $::ezproxy::dependencies.each |$dependency| {
    package { $dependency:
      ensure => installed,
      notify => Exec['bootstrap ezproxy']
    }
  }

  exec { 'bootstrap ezproxy':
    command     => "${::ezproxy::install_path}/ezproxy -mg",
    refreshonly => true,
    returns     => '1',
  }

  if $::ezproxy::key {
    if versioncmp($version, '6.0.0') >= 0 {
      exec { 'authorize ezproxy wskey':
        command => "${::ezproxy::install_path}/ezproxy -k ${::ezproxy::key}",
        creates => "${::ezproxy::install_path}/wskey.key",
        require => Exec['bootstrap ezproxy'],
      }

      file { "${::ezproxy::install_path}/wskey.key":
        ensure  => file,
        owner   => $::ezproxy::ezproxy_user,
        group   => $::ezproxy::ezproxy_group,
        require => Exec['authorize ezproxy wskey'],
      }
    }
    else {
      file { "${::ezproxy::install_path}/ezproxy.key":
        ensure  => file,
        owner   => $::ezproxy::ezproxy_user,
        group   => $::ezproxy::ezproxy_group,
        require => Exec['bootstrap ezproxy'],
      }

      file_line { 'ezproxy key':
        ensure  => present,
        path    => "${::ezproxy::install_path}/ezproxy.key",
        line    => $::ezproxy::key,
        require => File["${::ezproxy::install_path}/ezproxy.key"],
      }
    }
  }
  else {
    fail('EZProxy requires a key or WS key for authorization.')
  }
}
