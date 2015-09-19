# speedychains::install
#
# Performs common setup/validation tasks needed by all uses of the defined
# resource type, such as the directory for files and checking the OS.
#

class speedychains::install (
  $chain_scripts = '/etc/speedychains'
) {

  # We need a directory to home all our chain scripts in one place
  file { $chain_scripts:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    purge  => true,   # Ensures old scripts get discarded
  }

  # Make sure we're on a supported OS
  if ($::kernel != 'Linux') {
    fail('speedychains only supports the Linux kernel iptables and ip6tables providers currently')
  }

  # Make sure the puppetlabs-firewall module is present
  if (!defined(Class['firewall'])) {
    fail('This module is designed to run in conjunction with the puppetlabs-firewall module which needs to be included')
  }

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
