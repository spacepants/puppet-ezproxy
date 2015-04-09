# == Class ezproxy::service
#
# This class is meant to be called from ezproxy.
# It ensures the service is running.
#
class ezproxy::service {

  file { "/etc/init.d/${::ezproxy::service_name}":
    ensure  => file,
    mode    => '0755',
    content => template('ezproxy/startup.erb'),
  }
  service { $::ezproxy::service_name:
    ensure     => $::ezproxy::service_status,
    enable     => $::ezproxy::service_enable,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/ezproxy']
  }
}
