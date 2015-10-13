# == Class ezproxy::params
#
# This class is meant to be called from ezproxy.
# It sets variables according to platform.
#
class ezproxy::params {
  $ezproxy_group            = 'ezproxy'
  $ezproxy_user             = 'ezproxy'
  $install_path             = '/usr/local/ezproxy'
  $ezproxy_url              = $::fqdn
  $download_url             = 'https://www.oclc.org/content/dam/support/ezproxy/documentation/download/binaries/5-7-44/ezproxy-linux.bin'
  $proxy_by_hostname        = false
  $first_port               = '5000'
  $auto_login_ips           = []
  $include_ips              = []
  $exclude_ips              = []
  $login_port               = '80'
  $ssl                      = false
  $https_login              = false
  $https_admin              = false
  $max_lifetime             = '120'
  $max_sessions             = '500'
  $max_vhosts               = '1000'
  $log_filters              = []
  $log_format               = '%h %l %u %t "%r" %s %b'
  $log_file                 = '-strftime ezp%Y%m.log'
  $local_users              = []
  $admins                   = []
  $cas                      = false
  $cas_login_url            = undef
  $cas_service_validate_url = undef
  $ldap                     = false
  $ldap_options             = []
  $ldap_url                 = undef
  $default_stanzas          = true
  $stanzas                  = {}
  $remote_configs           = {}
  $manage_service           = true
  $service_status           = running
  $service_enable           = true
  $service_name             = 'ezproxy'
  $http_proxy               = undef
  $https_proxy              = undef
  $login_cookie_name        = undef
  $log_user                 = false

  if $::architecture == 'amd64' {
    case $::operatingsystemrelease {
      '13.04', '14.04': {
        $dependencies = [ 'lib32z1', 'dos2unix' ]
      }
      default: {
        $dependencies = [ 'ia32-libs', 'dos2unix' ]
      }
    }
  } elsif $::architecture == 'x86_64' {
    $dependencies = [ 'glibc.i686', 'dos2unix' ]
  } else {
    $dependencies = [ 'dos2unix' ]
  }

  case $::osfamily {
    'Debian': {
      $ezproxy_shell = '/usr/sbin/nologin'
    }
    'RedHat': {
      $ezproxy_shell = '/sbin/nologin'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
