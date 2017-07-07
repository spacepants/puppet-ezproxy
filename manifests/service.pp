# == Class ezproxy::service
#
# This class is meant to be called from ezproxy.
# It ensures the service is running if it's managed.
#
class ezproxy::service {

  if $::ezproxy::manage_service {

    $user         = $::ezproxy::ezproxy_user
    $group        = $::ezproxy::ezproxy_group
    $install_path = $::ezproxy::install_path

    if $::ezproxy::service_type == 'systemd' {
      $service_file = "/lib/systemd/system/${::ezproxy::service_name}.service"
      $service_mode = '0644'
    }
    else {
      $service_file = "/etc/init.d/${::ezproxy::service_name}"
      $service_mode = '0755'
    }

    file { $service_file:
      ensure  => file,
      mode    => $service_mode,
      content => template("ezproxy/${::ezproxy::service_type}.erb"),
      before  => Service[$::ezproxy::service_name],
    }
    service { $::ezproxy::service_name:
      ensure     => $::ezproxy::service_status,
      enable     => $::ezproxy::service_enable,
      hasrestart => true,
      hasstatus  => true,
    }

  }

}
