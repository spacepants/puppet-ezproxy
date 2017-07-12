# EZProxy Puppet Module

[![Build Status](https://secure.travis-ci.org/spacepants/puppet-ezproxy.svg)](https://travis-ci.org/spacepants/puppet-ezproxy)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ezproxy](#setup)
    * [What ezproxy affects](#what-ezproxy-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ezproxy](#beginning-with-ezproxy)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Puppet module for installing, configuring, and managing [OCLC's EZProxy](https://www.oclc.org/ezproxy.en.html).

## Module Description

This module manages the installation and configuration of EZProxy and any dependencies and allows you to work with proxy stanzas in a more structured format.

Individual databases and sites are built into file fragments which are then concatenated together. You can also specify a remote url to use as a source for things like Sage or Oxford Journals.

## Upgrading

### Changes from 1.x
* This module now requires Puppet version >= 4. The last release with Puppet 3 support is `1.1.0`.
* The EZProxy key is now a required parameter, as the module manages key authorization.
* The EZProxy service runs under systemd, depending on platform.
* EZProxy now logs to the `/var/log/ezproxy` directory by default now, and a logrotate rule is set for it.
* All 64-bit Debian family operating systems now use `lib32z1` for compatibility.
* The default group has been downcased.
* The installed EZProxy version is now available as a custom external fact: `ezproxy_version`
* EZProxy can be upgraded in place if the desired version of EZProxy is different from the current version.

#### Parameter Changes
* `key` sets the EZProxy authorization or WS key
* `ezproxy_group` is now `group`
* `ezproxy_user` is now `user`
* `install_path` is now `install_dir`
* `ezproxy_url` is now `server_name`
* `log_user` has been deprecated
* `log_type` now sets wither to log by session or username
* `dependencies` as an overridable parameter has been deprecated

## Setup

### What ezproxy affects

* A daemon user. Default: `ezproxy`
* The install directory. Default: `/usr/local/ezproxy`
* The ezproxy binary.
* EZProxy key authorization (WSKey in EZProxy 6+).
* A log directory. Default: `/var/log/ezproxy`
* A logrotate rule.
* installs `lib32z1` or `glibc.i686` (depending on platform) for 64-bit compatibility
* installs `dos2unix` for config file sanitization
* `$INSTALL_DIR/config.txt` which handles all of the EZProxy configuration
* `$INSTALL_DIR/user.txt` which handles user management
* `$INSTALL_DIR/groups.txt` which sets the order of the group include files
* `$INSTALL_DIR/group_default.txt` which is built out of file fragments for each individual EZProxy entry
* An init or systemd service, depending on platform. Note: Service management can be disabled.

## Usage

This module contains a single public class with a single required parameter, the EZProxy key:

```puppet
class { 'ezproxy':
  key => 'my-ezproxy-key',
}
```

You'll probably want to provide a few basic parameters for your particular environment:

```puppet
class { 'ezproxy':
  key               => 'my-ezproxy-key',
  server_name       => 'ezproxy.myinstitution.edu',
  proxy_by_hostname => true,
  login_port        => '80',
  max_sessions      => '1000',
  max_vhosts        => '2500',
  local_users       => [ 'user1:supersecure:admin', ],
}
```

There are also two defined types for creating EZProxy stanzas depending on whether you want to provide the values yourself or grab a provided config file from a URL.

```puppet
ezproxy::remote_config { 'Oxford Journals':
  download_link => 'http://www.oxfordjournals.org/help/techinfo/ezproxyconfig.txt',
  file_name     => 'oxford_journals',
  max_days      => '30',
}
```

Note that the downloaded config fill will get passed through `dos2unix` in order to strip out any potential Windows file artifacts.

```puppet
ezproxy::stanza { 'FirstSearch':
  urls    => [ 'http://firstsearch.oclc.org/FSIP' ],
  hosts   => [ 'firstsearch.oclc.org' ],
  domains => [ 'oclc.org' ],
}
```

### EZProxy upgrades
EZProxy can be upgraded by incrementing this version number. This will STOP the running instance of EZProxy and attempt to upgrade.

```puppet
class { 'ezproxy':
  key     => 'my-ezproxy-key',
  version => '6.2.2',
}
```

### Groups
If you want to set up groups, they're also available as defined types:

```puppet
ezproxy::group { 'whatever':
  group_order => 1,
}
```

You can also specify which group any stanza should use like this:

```puppet
ezproxy::stanza { 'FirstSearch':
  urls    => [ 'http://firstsearch.oclc.org/FSIP' ],
  hosts   => [ 'firstsearch.oclc.org' ],
  domains => [ 'oclc.org' ],
  group   => 'whatever',
}
```

## Authenticating via LDAP or CAS

Aside from local user authentication, you can also set up LDAP or CAS authentication with a couple of parameters.

### Configuring LDAP

If you want to set up basic anonymous LDAP authentication, you can do so like this:

```puppet
class { 'ezproxy':
  key => 'my-ezproxy-key',
  server_name => 'ezproxy.myinstitution.edu',
  ldap        => true,
  ldap_url    => 'ldap://ldap.myinstitution.edu/CN=users,DC=myinstitution,DC=edu?uid?sub?(objectClass=person)',
}
```

This would add the following to the `user.txt` file:

```
::LDAP
URL ldap://ldap.myinstitution.edu/CN=users,DC=myinstitution,DC=edu?uid?sub?(objectClass=person)
IfUnauthenticated; Stop
/LDAP
```

If you need to add some additional LDAP options, you can do so like this:

```puppet
class { 'ezproxy':
  key          => 'my-ezproxy-key',
  server_name  => 'ezproxy.myinstitution.edu',
  ldap         => true,
  ldap_options => [ 'BindUser CN=ezproxy,CN=users,DC=myinstitution,DC=edu', 'BindPassword verysecret' ],
  ldap_url     => 'ldap://ldap.myinstitution.edu/CN=users,DC=myinstitution,DC=edu?uid?sub?(objectClass=person)',
}
```

This would add the following to the `user.txt` file:

```
::LDAP
BindUser CN=ezproxy,CN=users,DC=myinstitution,DC=edu
BindPassword verysecret
URL ldap://ldap.myinstitution.edu/CN=users,DC=myinstitution,DC=edu?uid?sub?(objectClass=person)
IfUnauthenticated; Stop
/LDAP
```

If you need to add any LDAP-authenticated admins, you can do so like this:

```puppet
class { 'ezproxy':
  key         => 'my-ezproxy-key',
  server_name => 'ezproxy.myinstitution.edu',
  ldap        => true,
  ldap_url    => 'ldap://ldap.myinstitution.edu/CN=users,DC=myinstitution,DC=edu?uid?sub?(objectClass=person)',
  admins      => [ 'admin1', 'admin2' ],
}
```

This would add the following to the `user.txt` file:

```
::LDAP
URL ldap://ldap.myinstitution.edu/CN=users,DC=myinstitution,DC=edu?uid?sub?(objectClass=person)
IfUnauthenticated; Stop
IfUser admin1; Admin
IfUser admin2; Admin
/LDAP
```

### Configuring CAS

If you want to set up CAS authentication, you can do so like this:

```puppet
class { 'ezproxy':
  key                      => 'my-ezproxy-key',
  server_name              => 'ezproxy.myinstitution.edu',
  cas                      => true,
  cas_login_url            => 'https://cas.myinstitution.edu/cas-web/login',
  cas_service_validate_url => 'https://cas.myinstitution.edu/cas-web/serviceValidate',
}
```

This would add the following to the `user.txt` file:

```
::CAS
LoginURL https://cas.myinstitution.edu/cas-web/login
ServiceValidateURL https://cas.myinstitution.edu/cas-web/serviceValidate
/CAS
```

If you need to add any CAS-authenticated admins, you can do so like this:

```puppet
class { 'ezproxy':
  key                      => 'my-ezproxy-key',
  server_name              => 'ezproxy.myinstitution.edu',
  cas                      => true,
  cas_login_url            => 'https://cas.myinstitution.edu/cas-web/login',
  cas_service_validate_url => 'https://cas.myinstitution.edu/cas-web/serviceValidate',
  admins                   => [ 'admin1', 'admin2' ],
}
```

This would add the following to the `user.txt` file:

```
::CAS
LoginURL https://cas.myinstitution.edu/cas-web/login
ServiceValidateURL https://cas.myinstitution.edu/cas-web/serviceValidate
IfUser admin1; Admin
IfUser admin2; Admin
/CAS
```

## Usage with Hiera
You can do any of the above through Hiera as well as pass in a hash of EZProxy stanzas or remote configs. That would look like this:

```yaml
---
ezproxy::key: 'my-ezproxy-key'
ezproxy::server_name: 'ezproxy.myinstitution.edu'
ezproxy::proxy_by_hostname: true
ezproxy::login_port: '80'
ezproxy::max_sessions: '1000'
ezproxy::max_vhosts: '2500'
ezproxy::groups:
  whatever:
    group_order: 1
ezproxy::local_users:
  - user1:supersecure:admin
ezproxy::remote_configs:
  Oxford Journals:
    download_link: 'http://www.oxfordjournals.org/help/techinfo/ezproxyconfig.txt'
    file_name: 'oxford_journals'
    max_days: '30'
ezproxy::stanzas:
  FirstSearch:
    urls:
      - http://firstsearch.oclc.org/FSIP
    hosts:
      - firstsearch.oclc.org
    domains:
      - oclc.org
    group: 'whatever'
```

## Reference

### Classes

#### Public Classes

* `ezproxy`: Main class, manages the installation and configuration of EZProxy

#### Private Classes

* `ezproxy::facts`: Enable external facts for running instance of EZProxy. This class is required to handle upgrades of ezproxy.
* `ezproxy::install`: Installs EZProxy
* `ezproxy::config`: Modifies EZProxy configuration files
* `ezproxy::service`: Manages the EZProxy service

#### Defined types

* `ezproxy::group`: Creates a user group in EZProxy
* `ezproxy::remote_config`: Adds an EZProxy configuration file from a remote URL
* `ezproxy::stanza`: Creates an EZProxy config stanza for a resource

### Parameters


#### `group`

Group the ezproxy user should belong to. Default: `ezproxy`

#### `user`

User the ezproxy service should run as. Default: `ezproxy`

#### `install_dir`

Directory ezproxy should be installed in. Default: `/usr/local/ezproxy`

#### `log_dir`

Directory ezproxy should use for logging. Default: `/var/log/ezproxy`

#### `version`

Version of EZProxy to install. Default: `5.7.44`

#### `key`

EZProxy authorization key. Required.

#### `server_name`

EZProxy server name. Default: `$::fqdn`

#### `download_url`

URL to download the ezproxy binary. Default: `https://www.oclc.org/content/dam/support/ezproxy/documentation/download/binaries`

#### `proxy_by_hostname`

Boolean for whether or not to proxy by hostname. Default: `false`

#### `first_port`

First port to use when proxying by port. Default: `5000`

#### `auto_login_ips`

Array of IPs to autologin for the default group. Optional.

#### `include_ips`

Array of IPs to include for the default group. Optional.

#### `exclude_ips`

Array of IPs to exclude for the default group. Optional.

#### `reject_ips`

Array of IPs to reject for the default group. Optional.

#### `login_port`

Port to listen for HTTP. Default: `80`

#### `ssl`

Boolean for whether or not to accept SSL connections. Default: `false`

#### `https_login`

Boolean for whether or not to force logins through SSL. Default: `false`

#### `https_admin`

Boolean for whether or not to force admin sessions through SSL. Default: `false`

#### `max_lifetime`

How long in minutes a session should remain valid after last access. Default: `120`

#### `max_sessions`

Maximum number of sessions that can exist concurrently. Default: `500`

#### `max_vhosts`

Maximum number of virtual hosts that ezproxy can create. Default: `1000`

#### `log_filters`

Array of filters to exclude from the logs. Optional.

#### `log_format`

Array of filters to exclude from the logs. Default: `%h %l %u %t "%r" %s %b`

#### `log_file`

Path that ezproxy should log to. Default: `/var/log/ezproxy/ezproxy.log`

#### `local_users`

Array of local users to include. Optional.

#### `admins`

Array of ldap or cas users to pass to admin. Optional.

#### `user_groups`

Array of user groups to define. Optional.

#### `cas`

Boolean for whether or not to authenticate via CAS. Default: `false`

#### `cas_login_url`

CAS URL that should be used for login. Optional.

#### `cas_service_validate_url`

CAS URL that should be used for service validation. Optional.

#### `ldap`

Boolean for whether or not to authenticate via LDAP. Default: `false`

#### `ldap_options`

Array of LDAP options to include. Optional.

#### `ldap_url`

LDAP URL to use to authenticate users. Optional.

#### `cgi`

Boolean for whether or not to authenticate via CGI. Default: `false`

#### `cgi_url`

CGI URL to use to authenticate users. Optional.

#### `ticket_auth`

Boolean for whether or not to authenticate via ticket. Default: `false`

#### `ticket_acceptgroups`

Groups allowed to appear in tickets. Optional.

#### `ticket_validtime`

Minutes a ticket should be considered valid. Optional.

#### `ticket_timeoffset`

Offset in minutes when comparing ticket time. Optional.

#### `ticket_crypt_algorithm`

Hash algorithm for validating tickets. Optional.

#### `ticket_secretkey`

Shared key for validating tickets. Optional.

#### `expiredticket_url`

URL to use for expired tickets. Default: `expired.html`

#### `default_stanzas`

Boolean for whether or not to include the default databases from OCLC. Default: `true`

#### `include_files`

Array of files to include in config.txt. Optional.

#### `remote_configs`

Hash of remote config stanzas to include. Optional.

#### `stanzas`

Hash of database stanzas to include. Optional.

#### `groups`

Hash of database groups to include. Optional.

#### `manage_service`

Boolean for whether or not to manage the service. Default: `true`

#### `service_name`

Name of the startup script to use. Default: `ezproxy`

#### `service_status`

Should the service be running or stopped. Default: `running`

#### `service_enable`

Boolean for whether or not to start ezproxy on restart. Default: `true`

#### `login_cookie_name`

String for alternate cookie name for EZproxy session cookie. Optional.

#### `http_proxy`

String for forward proxy configuration for http proxy_hostname:port. Optional.

#### `https_proxy`

String for forward proxy configuration for https proxy_hostname:port. Optional.

#### `log_type`

Whether to log user by username or session. Default: `Session`


## Limitations

This module is currently tested and working with EZProxy 5.7.44 and 6.2.2 on RedHat and CentOS 5, 6, and 7, Debian 6, 7, and 8, and Ubuntu 12.04, 14.04, and 16.04 systems.

## Development

Pull requests are totally welcome. If you'd like to contribute other features or anything else, check out the contributing guidelines in CONTRIBUTING.md.
