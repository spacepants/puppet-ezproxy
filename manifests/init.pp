# == Class: ezproxy
#
# This module manages EZProxy. Databases and other EZProxy sites are loaded in
# a custom config file called sites.txt out of the ezproxy::stanza defined type.
#
# === Parameters
#
# [*ezproxy_group*]
#   Group the ezproxy user should belong to.
#
# [*ezproxy_user*]
#   User the ezproxy service should run as.
#
# [*install_path*]
#   Path ezproxy should be installed in.
#
# [*ezproxy_url*]
#   EZProxy URL.
#
# [*download_url*]
#   URL to download the ezproxy binary.
#
# [*proxy_by_hostname*]
#   Boolean for whether or not to proxy by hostname.
#
# [*first_port*]
#   First port to use when proxying by port.
#
# [*auto_login_ips*]
#   Array of IPs to autologin for the default group.
#
# [*include_ips*]
#   Array of IPs to include for the default group.
#
# [*exclude_ips*]
#   Array of IPs to exclude for the default group.
#
# [*reject_ips*]
#   Array of IPs to reject for the default group.
#
# [*login_port*]
#   Port to listen for HTTP.
#
# [*ssl*]
#   Boolean for whether or not to accept SSL connections.
#
# [*https_login*]
#   Boolean for whether or not to force logins through SSL.
#
# [*https_admin*]
#   Boolean for whether or not to force admin sessions through SSL.
#
# [*max_lifetime*]
#   How long in minutes a session should remain valid after last access.
#
# [*max_sessions*]
#   Maximum number of sessions that can exist concurrently.
#
# [*max_vhosts*]
#   Maximum number of virtual hosts that ezproxy can create.
#
# [*log_filters*]
#   Array of filters to exclude from the logs.
#
# [*local_users*]
#   Array of local users to include.
#
# [*admins*]
#   Array of ldap or cas users to pass to admin.
#
# [*cas*]
#   Boolean for whether or not to authenticate via CAS.
#
# [*cas_login_url*]
#   CAS URL that should be used for login.
#
# [*cas_service_validate_url*]
#   CAS URL that should be used for service validation.
#
# [*ldap*]
#   Boolean for whether or not to authenticate via LDAP.
#
# [*ldap_options*]
#   Array of LDAP options to include.
#
# [*ldap_url*]
#   LDAP URL to use to authenticate users.
#
# [*default_stanzas*]
#   Boolean for whether or not to include the default databases from OCLC.
#
# [*include_files*]
#   Array of files to include in config.txt
#
# [*remote_configs*]
#   Hash of remote config stanzas to include.
#   More info in manifests/remote_config.pp.
#
# [*stanzas*]
#   Hash of database stanzas to include.
#   More info in manifests/stanza.pp.
#
# [*groups*]
#   Hash of database groups to include.
#   More info in manifests/group.pp.
#
# [*manage_service*]
#   Boolean for whether or not to manage the service.
#
# [*service_name*]
#   Name of the startup script to use.
#
# [*service_status*]
#   Should the service be running or stopped.
#
# [*service_enable*]
#   Boolean for whether or not to start ezproxy on restart.
#
# [*login_cookie_name*]
# String for alternate cookie name for EZproxy session cookie
#
# [*http_proxy*]
# String for forward proxy configuration for http proxy_hostname:port
#
# [*https_proxy*]
# String for forward proxy configuration for https proxy_hostname:port
#
# [*log_user*]
#   Boolean for whether or not logging of username should be done. This disables
#   logging of session, if you require both then %{ezproxy-session} can be included
#   in the log_format parameter
#
class ezproxy (
  String                                         $group                    = 'ezproxy',
  String                                         $user                     = 'ezproxy',
  Stdlib::Absolutepath                           $install_dir              = '/usr/local/ezproxy',
  String                                         $version                  = '5.7.44',
  Optional[String]                               $key                      = undef,
  String                                         $server_name              = $::fqdn,
  String                                         $download_url             = 'https://www.oclc.org/content/dam/support/ezproxy/documentation/download/binaries',
  Boolean                                        $proxy_by_hostname        = false,
  String                                         $first_port               = '5000',
  Array                                          $auto_login_ips           = [],
  Array                                          $include_ips              = [],
  Array                                          $exclude_ips              = [],
  Array                                          $reject_ips               = [],
  String                                         $login_port               = '80',
  Boolean                                        $ssl                      = false,
  Boolean                                        $https_login              = false,
  Boolean                                        $https_admin              = false,
  String                                         $max_lifetime             = '120',
  String                                         $max_sessions             = '500',
  String                                         $max_vhosts               = '1000',
  Array                                          $log_filters              = [],
  String                                         $log_format               = '%h %l %u %t "%r" %s %b',
  String                                         $log_file                 = '-strftime ezp%Y%m.log',
  Array                                          $local_users              = [],
  Array                                          $admins                   = [],
  Array                                          $user_groups              = [],
  Boolean                                        $cas                      = false,
  Optional[String]                               $cas_login_url            = undef,
  Optional[String]                               $cas_service_validate_url = undef,
  Boolean                                        $ldap                     = false,
  Array                                          $ldap_options             = [],
  Optional[String]                               $ldap_url                 = undef,
  Boolean                                        $cgi                      = false,
  Optional[String]                               $cgi_url                  = undef,
  Boolean                                        $ticket_auth              = false,
  Optional[String]                               $ticket_acceptgroups      = undef,
  Optional[Integer]                              $ticket_validtime         = undef,
  Optional[Integer]                              $ticket_timeoffset        = undef,
  Optional[Enum['MD5','SHA1','SHA256','SHA512']] $ticket_crypt_algorithm   = undef,
  Optional[String]                               $ticket_secretkey         = undef,
  String                                         $expiredticket_url        = 'expired.html',
  Boolean                                        $default_stanzas          = true,
  Array                                          $include_files            = [],
  Hash                                           $remote_configs           = {},
  Hash                                           $stanzas                  = {},
  Hash                                           $groups                   = {},
  Boolean                                        $manage_service           = true,
  String                                         $service_name             = 'ezproxy',
  Enum['running','stopped']                      $service_status           = 'running',
  Boolean                                        $service_enable           = true,
  Optional[String]                               $login_cookie_name        = undef,
  Optional[String]                               $http_proxy               = undef,
  Optional[String]                               $https_proxy              = undef,
  Enum['User','Session']                         $log_type                 = 'Session',
) inherits ::ezproxy::params {

  class { '::ezproxy::install': }
  -> class { '::ezproxy::config': }
  ~> class { '::ezproxy::service': }
  -> Class['::ezproxy']
}
