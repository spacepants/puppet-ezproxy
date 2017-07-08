# ezproxy::params
#
# This class sets variables according to platform.
#
class ezproxy::params {

  case $::osfamily {
    'Debian': {
      $ezproxy_shell = '/usr/sbin/nologin'
      case $::operatingsystemmajrelease {
        '8', '16.04': {
          $service_type = 'systemd'
        }
        default: {
          $service_type = 'init'
        }
      }

      if $::architecture == 'amd64' {
        $os_deps = 'lib32z1'
      }
      else {
        $os_deps = undef
      }
    }
    'RedHat': {
      $ezproxy_shell = '/sbin/nologin'
      if $::architecture == 'x86_64' {
        $os_deps = 'glibc.i686'
      }
      else {
        $os_deps = undef
      }
      case $::operatingsystemmajrelease {
        '7': {
          $service_type = 'systemd'
        }
        default: {
          $service_type = 'init'
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  if $os_deps {
    $dependencies = concat(['dos2unix'], $os_deps)
  }
  else {
    $dependencies = ['dos2unix']
  }

}
