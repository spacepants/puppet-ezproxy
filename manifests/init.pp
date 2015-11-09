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
#   Array of IPs to autologin.
#
# [*include_ips*]
#   Array of IPs to include.
#
# [*exclude_ips*]
#   Array of IPs to exclude.
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
  $ezproxy_group            = $::ezproxy::params::ezproxy_group,
  $ezproxy_user             = $::ezproxy::params::ezproxy_user,
  $install_path             = $::ezproxy::params::install_path,
  $ezproxy_url              = $::ezproxy::params::ezproxy_url,
  $download_url             = $::ezproxy::params::download_url,
  $dependencies             = $::ezproxy::params::dependencies,
  $proxy_by_hostname        = $::ezproxy::params::proxy_by_hostname,
  $first_port               = $::ezproxy::params::first_port,
  $auto_login_ips           = $::ezproxy::params::auto_login_ips,
  $include_ips              = $::ezproxy::params::include_ips,
  $exclude_ips              = $::ezproxy::params::exclude_ips,
  $login_port               = $::ezproxy::params::login_port,
  $ssl                      = $::ezproxy::params::ssl,
  $https_login              = $::ezproxy::params::https_login,
  $https_admin              = $::ezproxy::params::https_admin,
  $max_lifetime             = $::ezproxy::params::max_lifetime,
  $max_sessions             = $::ezproxy::params::max_sessions,
  $max_vhosts               = $::ezproxy::params::max_vhosts,
  $log_filters              = $::ezproxy::params::log_filters,
  $log_format               = $::ezproxy::params::log_format,
  $log_file                 = $::ezproxy::params::log_file,
  $local_users              = $::ezproxy::params::local_users,
  $admins                   = $::ezproxy::params::admins,
  $cas                      = $::ezproxy::params::cas,
  $cas_login_url            = $::ezproxy::params::cas_login_url,
  $cas_service_validate_url = $::ezproxy::params::cas_service_validate_url,
  $ldap                     = $::ezproxy::params::ldap,
  $ldap_options             = $::ezproxy::params::ldap_options,
  $ldap_url                 = $::ezproxy::params::ldap_url,
  $cgi                      = $::ezproxy::params::cgi,
  $cgi_url                  = $::ezproxy::params::cgi_url,
  $ticket_auth              = $::ezproxy::params::ticket_auth,
  $ticket_acceptgroups      = $::ezproxy::params::ticket_acceptgroups,
  $ticket_validtime         = $::ezproxy::params::ticket_validtime,
  $ticket_timeoffset        = $::ezproxy::params::ticket_timeoffset,
  $ticket_crypt_algorithm   = $::ezproxy::params::ticket_crypt_algorithm,
  $ticket_secretkey         = $::ezproxy::params::ticket_secretkey,
  $expiredticket_url        = $::ezproxy::params::expiredticket_url,
  $default_stanzas          = $::ezproxy::params::default_stanzas,
  $include_files            = $::ezproxy::params::include_files,
  $remote_configs           = $::ezproxy::params::remote_configs,
  $stanzas                  = $::ezproxy::params::stanzas,
  $manage_service           = $::ezproxy::params::manage_service,
  $service_name             = $::ezproxy::params::service_name,
  $service_status           = $::ezproxy::params::service_status,
  $service_enable           = $::ezproxy::params::service_enable,
  $login_cookie_name        = $::ezproxy::params::login_cookie_name,
  $http_proxy               = $::ezproxy::params::http_proxy,
  $https_proxy              = $::ezproxy::params::https_proxy,
  $log_user                 = $::ezproxy::params::log_user,
) inherits ::ezproxy::params {

  validate_string($ezproxy_group)
  validate_string($ezproxy_user)
  validate_absolute_path($install_path)
  if $ezproxy_url {
    validate_string($ezproxy_url)
  }
  validate_string($download_url)
  validate_bool($proxy_by_hostname)
  validate_string($first_port)
  if $auto_login_ips {
    validate_array($auto_login_ips)
  }
  if $include_ips {
    validate_array($include_ips)
  }
  if $exclude_ips {
    validate_array($exclude_ips)
  }
  validate_string($login_port)
  validate_bool($ssl)
  validate_bool($https_login)
  validate_bool($https_admin)
  validate_string($max_lifetime)
  validate_string($max_sessions)
  validate_string($max_vhosts)
  if $log_filters {
    validate_array($log_filters)
  }
  validate_string($log_format)
  validate_string($log_file)
  if $local_users {
    validate_array($local_users)
  }
  if $admins {
    validate_array($admins)
  }
  validate_bool($cas)
  if $cas {
    if $cas_login_url {
      validate_string($cas_login_url)
    } else {
      fail('CAS authentication requires a valid CAS login URL string.')
    }
    if $cas_service_validate_url {
      validate_string($cas_service_validate_url)
    } else {
      fail('CAS authentication requires a valid service validate URL string.')
    }
  }
  validate_bool($ldap)
  if $ldap {
    if $ldap_options {
      validate_array($ldap_options)
    }
    if $ldap_url {
      validate_string($ldap_url)
    } else {
      fail('LDAP authentication requires a valid LDAP URL string.')
    }
  }
  validate_bool($cgi)
  if $cgi {
    if $cgi_url {
      validate_string($cgi_url)
    } else {
      fail('CGI authentication requires a valid CGI URL string.')
    }
  }
  validate_bool($ticket_auth)
  if $ticket_auth {
    if $ticket_acceptgroups {
      validate_string($ticket_acceptgroups)
    }
    if $ticket_validtime {
      if !is_integer($ticket_validtime) {
        fail('The ticket TimeValid setting must be numeric.')
      }
    }
    if $ticket_timeoffset {
      if !is_integer($ticket_timeoffset) {
        fail('The ticket TimeOffset setting must be numeric.')
      }
    }
    if $ticket_crypt_algorithm {
      validate_string($ticket_crypt_algorithm)
      #$_ticket_crypt_algorithm = upcase($ticket_crypt_algorithm)
      if !(upcase($ticket_crypt_algorithm) in ['MD5', 'SHA1', 'SHA256', 'SHA512']) {
        fail('The supported cryptography algorithms for ticket authentication are MD5, SHA1, SHA256, and SHA512.')
      }
    } else {
      fail('You much provide a ticket authentication cryptography algorithm.')
    }
    if $ticket_secretkey {
      validate_string($ticket_secretkey)
    } else {
      fail('You much provide the secret key for ticket authentication.')
    }
    if $expiredticket_url {
      validate_string($expiredticket_url)
    } else {
      fail('You must provide a valid URL string for the ticket expiration warning.')
    }
  }
  validate_bool($default_stanzas)
  validate_array($include_files)
  validate_hash($stanzas)
  validate_hash($remote_configs)
  validate_bool($manage_service)
  validate_string($service_name)
  validate_re($service_status, [ '^running', '^stopped' ])
  validate_bool($service_enable)
  validate_string($login_cookie_name)
  validate_string($http_proxy)
  validate_string($https_proxy)
  validate_bool($log_user)

  class { '::ezproxy::install': } ->
  class { '::ezproxy::config': } ~>
  class { '::ezproxy::service': } ->
  Class['::ezproxy']
}
