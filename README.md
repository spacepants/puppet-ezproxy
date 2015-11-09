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

## Setup

### What ezproxy affects

By default, this module will manage:
* the `ezproxy` user
* the EZProxy install directory exists (defaults to `/usr/local/ezproxy`)
* the `ezproxy` binary is downloaded with the correct mode and permissions
* any applicable dependency packages (i.e. `ialibs-32` or `glibc.i686` for 64-bit systems, `dos2unix` for config file sanitization)
* `$INSTALL_PATH/config.txt` which handles all of the EZProxy configuration
* `$INSTALL_PATH/user.txt`
* `$INSTALL_PATH/groups.txt` which sets the group include file load order
* `$INSTALL_PATH/group_Default.txt` which is built out of file fragments for each individual EZProxy entry
* the `/etc/init.d/ezproxy` script for service management

## Usage

This module contains a single public class:

```puppet
class { 'ezproxy': }
```

You'll probably want to provide a few basic parameters for your particular environment:

```puppet
class { 'ezproxy':
  ezproxy_url       => 'ezproxy.myinstitution.edu',
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

### Groups
If you want to set up groups, they're also available as defined types:

```puppet
ezproxy::group { 'Whatever':
  group_order => 1,
}
```

You can also specify which group any stanza should use like this:

```puppet
ezproxy::stanza { 'FirstSearch':
  urls    => [ 'http://firstsearch.oclc.org/FSIP' ],
  hosts   => [ 'firstsearch.oclc.org' ],
  domains => [ 'oclc.org' ],
  group   => 'Whatever',
}
```

## Authenticating via LDAP or CAS

Aside from local user authentication, you can also set up LDAP or CAS authentication with a couple of parameters.

### Configuring LDAP

If you want to set up basic anonymous LDAP authentication, you can do so like this:

```puppet
class { 'ezproxy':
  ezproxy_url => 'ezproxy.myinstitution.edu',
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
  ezproxy_url  => 'ezproxy.myinstitution.edu',
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
  ezproxy_url => 'ezproxy.myinstitution.edu',
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
  ezproxy_url              => 'ezproxy.myinstitution.edu',
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
  ezproxy_url              => 'ezproxy.myinstitution.edu',
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
ezproxy::ezproxy_url: 'ezproxy.myinstitution.edu'
ezproxy::proxy_by_hostname: true
ezproxy::login_port: '80'
ezproxy::max_sessions: '1000'
ezproxy::max_vhosts: '2500'
ezproxy::groups:
  Whatever:
    group_order: 1
ezproxy::local_users:
  - user1:supersecure:admin
ezproxy::remote_configs:
  Oxford Journals:
    download_link: 'http://www.oxfordjournals.org/help/techinfo/ezproxyconfig.txt'
    file_name: 'oxford_journals'
ezproxy::stanzas:
  FirstSearch:
    urls:
      - http://firstsearch.oclc.org/FSIP
    hosts:
      - firstsearch.oclc.org
    domains:
      - oclc.org
    group: 'Whatever'
```

## Limitations

This module is currently tested and working with EZProxy 5.7 and 6 on RedHat and CentOS 5, 6, and 7, Debian 6 and 7, and Ubuntu 12.04 and 14.04 systems.

## Development

Pull requests are totally welcome. If you'd like to contribute other features or anything else, check out the contributing guidelines in CONTRIBUTING.md.
