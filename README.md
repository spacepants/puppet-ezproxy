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
* `$INSTALL_PATH/sites.txt` which is built out of file fragments for each individual EZProxy entry
* the `/etc/init.d/ezproxy` script for service management

### Beginning with ezproxy

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

## Limitations

This module is currently tested and working with EZProxy 5.7 and 6 on RedHat and CentOS 5, 6, and 7, Debian 6 and 7, and Ubuntu 12.04 and 14.04 systems.

## Development

Pull requests are totally welcome. If you'd like to contribute other features or anything else, check out the contributing guidelines in CONTRIBUTING.md.
