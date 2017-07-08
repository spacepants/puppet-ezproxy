# ezproxy::install
#
# This class is called from ezproxy for install.
#
class ezproxy::install {

  $group = $::ezproxy::group
  $user = $::ezproxy::user
  $install_dir = $::ezproxy::install_dir
  $log_dir = $::ezproxy::log_dir
  $version = $::ezproxy::version
  $download_version = regsubst($version, '\.', '-', 'G')

  group { $group:
    ensure => present,
    system => true,
  }
  user { $user:
    ensure  => present,
    system  => true,
    home    => $install_dir,
    shell   => $::ezproxy::ezproxy_shell,
    gid     => $group,
    require => Group[$group]
  }

  file { $install_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => User[$user]
  }

  file { $::ezproxy::log_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => User[$user]
  }

  file { '/etc/logrotate.d/ezproxy':
    ensure  => file,
    content => template('ezproxy/logrotate.erb'),
  }

  exec { 'download ezproxy':
    command => "curl -o ${install_dir}/ezproxy ${::ezproxy::download_url}/${download_version}/ezproxy-linux.bin",
    creates => "${install_dir}/ezproxy",
    path    => '/sbin:/bin:/usr/sbin:/usr/bin',
    require => File[$install_dir]
  }

  file { "${install_dir}/ezproxy":
    ensure  => present,
    mode    => '0755',
    owner   => $user,
    group   => $group,
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
    command     => "${install_dir}/ezproxy -mg",
    refreshonly => true,
    returns     => '1',
  }

  if $::ezproxy::key {
    if versioncmp($version, '6.0.0') >= 0 {
      exec { 'authorize ezproxy wskey':
        command => "${install_dir}/ezproxy -k ${::ezproxy::key}",
        creates => "${install_dir}/wskey.key",
        require => Exec['bootstrap ezproxy'],
      }

      file { "${install_dir}/wskey.key":
        ensure  => file,
        owner   => $user,
        group   => $group,
        require => Exec['authorize ezproxy wskey'],
      }
    }
    else {
      file { "${install_dir}/ezproxy.key":
        ensure  => file,
        owner   => $user,
        group   => $group,
        require => Exec['bootstrap ezproxy'],
      }

      file_line { 'ezproxy key':
        ensure  => present,
        path    => "${install_dir}/ezproxy.key",
        line    => $::ezproxy::key,
        require => File["${install_dir}/ezproxy.key"],
      }
    }
  }
  else {
    fail('EZProxy requires a key or WS key for authorization.')
  }
}
