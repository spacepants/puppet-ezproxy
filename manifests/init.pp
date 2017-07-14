# == Class: ezproxy
#
# This module manages EZProxy. Databases and other EZProxy sites are loaded in
# a custom config file called sites.txt out of the ezproxy::stanza defined type.
#
# @param group Group the ezproxy user should belong to.
# @param user User the ezproxy service should run as.
# @param install_dir Directory ezproxy should be installed in.
# @param log_dir Directory ezproxy should use for logging.
# @param version Version of EZProxy to install.
# @param key EZProxy authorization key.
# @param server_name EZProxy server name.
# @param download_url URL to download the ezproxy binary.
# @param proxy_by_hostname Boolean for whether or not to proxy by hostname.
# @param first_port First port to use when proxying by port.
# @param auto_login_ips Array of IPs to autologin for the default group.
# @param include_ips Array of IPs to include for the default group.
# @param exclude_ips Array of IPs to exclude for the default group.
# @param reject_ips Array of IPs to reject for the default group.
# @param login_port Port to listen for HTTP.
# @param ssl Boolean for whether or not to accept SSL connections.
# @param https_login Boolean for whether or not to force logins through SSL.
# @param https_admin Boolean for whether or not to force admin sessions through SSL.
# @param max_lifetime How long in minutes a session should remain valid after last access.
# @param max_sessions Maximum number of sessions that can exist concurrently.
# @param max_vhosts Maximum number of virtual hosts that ezproxy can create.
# @param log_filters Array of filters to exclude from the logs.
# @param log_format Array of filters to exclude from the logs.
# @param log_file Path that ezproxy should log to.
# @param local_users Array of local users to include.
# @param admins Array of ldap or cas users to pass to admin.
# @param user_groups Array of user groups to define.
# @param cas Boolean for whether or not to authenticate via CAS.
# @param cas_login_url CAS URL that should be used for login.
# @param cas_service_validate_url CAS URL that should be used for service validation.
# @param ldap Boolean for whether or not to authenticate via LDAP.
# @param ldap_options Array of LDAP options to include.
# @param ldap_url LDAP URL to use to authenticate users.
# @param cgi Boolean for whether or not to authenticate via CGI.
# @param cgi_url CGI URL to use to authenticate users.
# @param ticket_auth Boolean for whether or not to authenticate via ticket.
# @param ticket_acceptgroups Groups allowed to appear in tickets.
# @param ticket_validtime Minutes a ticket should be considered valid.
# @param ticket_timeoffset Offset in minutes when comparing ticket time.
# @param ticket_crypt_algorithm Hash algorithm for validating tickets.
# @param ticket_secretkey Shared key for validating tickets.
# @param expiredticket_url URL to use for expired tickets.
# @param default_stanzas Boolean for whether or not to include the default databases from OCLC.
# @param include_files Array of files to include in config.txt
# @param remote_configs Hash of remote config stanzas to include.
# @param stanzas Hash of database stanzas to include.
# @param groups Hash of database groups to include.
# @param manage_service Boolean for whether or not to manage the service.
# @param service_name Name of the startup script to use.
# @param service_status Should the service be running or stopped.
# @param service_enable Boolean for whether or not to start ezproxy on restart.
# @param login_cookie_name String for alternate cookie name for EZproxy session cookie
# @param http_proxy String for forward proxy configuration for http proxy_hostname:port
# @param https_proxy String for forward proxy configuration for https proxy_hostname:port
# @param log_type Whether to log user by username or session.
#
class ezproxy (
  String                                         $group                    = 'ezproxy',
  String                                         $user                     = 'ezproxy',
  Stdlib::Absolutepath                           $install_dir              = '/usr/local/ezproxy',
  Stdlib::Absolutepath                           $log_dir                  = '/var/log/ezproxy',
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
  String                                         $log_file                 = '/var/log/ezproxy/ezproxy.log',
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

  class { '::ezproxy::facts': }
  -> class { '::ezproxy::install': }
  -> class { '::ezproxy::config': }
  ~> class { '::ezproxy::service': }
  -> Class['::ezproxy']
}
