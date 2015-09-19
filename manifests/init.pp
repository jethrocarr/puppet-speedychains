# jethrocarr-speedychains puppet module
# Provides a defined resource type for creating firewall chains. This resource
# then generates a 

define speedychains (
  $chain_name      = $name,
  $chain_provider  = 'iptables',
  $rule_action     = 'ACCEPT',
  $rule_addresses  = [],
) {
  require speedychains::install

  # Make sure the provider is supported
  if !member(['iptables', 'ip6tables'], $chain_provider) {
    fail("The requested provider (${chain_provider}) does not exist/is not supported.")
  }

  # To get the "speediness" we generate a bash script with all the commands
  # to setup the firewall chain and then anytime it changes, we execute the
  # script to flush the current chain and reload it with new data.

  file { "speedychains-${chain_name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    path    => "${speedychains::install::chain_scripts}/${chain_name}.sh",
    content => template("speedychains/script_${chain_provider}.sh.erb"),
    notify  => Exec["speedychains-${chain_name}"],
  }

  exec { "speedychains-${chain_name}":
    command     => "${speedychains::install::chain_scripts}/${chain_name}.sh",
    refreshonly => true,
  }


}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
