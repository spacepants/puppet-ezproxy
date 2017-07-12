# ezproxy::install
#
# This class is called from ezproxy to add a custom fact for the EZProxy
# version. It's an external fact because we don't want to distribute this fact
# to all systems.
#
class ezproxy::facts(
  Enum['present','absent'] $ensure = 'present',
) {

  $install_dir = $::ezproxy::install_dir

  if $ensure == 'present' {
    $file_ensure = 'file'

    # PE has its own Facter directory
    if $::puppetversion =~ /Puppet Enterprise/ {
      $dir = 'puppetlabs/'
    } else {
      $dir = ''
    }

    # Make sure the external facts directory exists if it doesn't already.
    if ! defined(File["/etc/${dir}facter"]) {
      file { "/etc/${dir}facter":
        ensure  => directory,
      }
    }
    if ! defined(File["/etc/${dir}facter/facts.d"]) {
      file { "/etc/${dir}facter/facts.d":
        ensure  => directory,
      }
    }
  }
  else {
    $file_ensure = 'absent'
  }

  file { "/etc/${dir}facter/facts.d/ezproxy_facts.sh":
    ensure  => $file_ensure,
    content => template('ezproxy/facts.sh.erb'),
    mode    => '0755',
  }
}
