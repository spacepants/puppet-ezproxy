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
#   Array of local users to include.
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
# [*stanzas*]
#   Hash of database stanzas to include.
#   More info in manifests/stanza.pp.
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
class ezproxy (
  $ezproxy_group            = $::ezproxy::params::ezproxy_group,
  $ezproxy_user             = $::ezproxy::params::ezproxy_user,
  $install_path             = $::ezproxy::params::install_path,
  $ezproxy_url              = $::ezproxy::params::ezproxy_url,
  $download_url             = $::ezproxy::params::download_url,
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
  $default_stanzas          = $::ezproxy::params::default_stanzas,
  $stanzas                  = $::ezproxy::params::stanzas,
  $service_name             = $::ezproxy::params::service_name,
  $service_status           = $::ezproxy::params::service_status,
  $service_enable           = $::ezproxy::params::service_enable,
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
  validate_bool($default_stanzas)
  validate_hash($stanzas)
  validate_string($service_name)
  validate_re($service_status, [ '^running', '^stopped' ])
  validate_bool($service_enable)

  class { '::ezproxy::install': } ->
  class { '::ezproxy::config': } ~>
  class { '::ezproxy::service': } ->
  Class['::ezproxy']
}
