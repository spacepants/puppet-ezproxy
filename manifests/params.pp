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
  $download_url             = 'https://www.oclc.org/content/dam/support/ezproxy/documentation/download/binaries/6/ezproxy-linux.bin'
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

  case $::osfamily {
    'Debian': {
      $ezproxy_shell = '/usr/sbin/nologin'
      $service_name  = 'ezproxy'
      if $::architecture == 'x86_64' {
        $dependencies = [ 'ia32-libs' ]
      }
    }
    'RedHat', 'Amazon': {
      $ezproxy_shell = '/sbin/nologin'
      $service_name = 'ezproxy'
      if $::architecture == 'x86_64' {
        $dependencies = [ 'glibc.i686' ]
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
