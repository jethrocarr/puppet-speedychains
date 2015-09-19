# puppet-speedychains

## Overview

A companion module for puppetlabs-firewall that generates iptables/ip6tables
chains and applies them in seconds, even with thousands of entries.

Ideal for dealing with massive GeoIP rulesets, blocklists or explicit client
access lists.


## Module Description

With the [puppet-rirs](https://github.com/jethrocarr/puppet-rirs) module it
becomes possible to easily get lists of geographic IP address ranges to use in
various firewalls or application policies.

However whilst application rulesets can generally be generated in mere seconds
using ERB templates, applying thousands of iptables/ip6tables rules can take
many HOURS using the [puppetlabs-firewall](https://github.com/puppetlabs/puppetlabs-firewall)
module as it treats every entry as an independent resource that needs to be
checked, compared and then saved.

This makes the use of any massive firewall rulesets such as GeoIP but also
huge block lists or explicit client-permit lists almost impossible to manage
with Puppet.

This module provides a solution where arrays of IP addresses can be provided to
the module and used to generate iptables/ip6tables chains which can then be easily
referenced with the `puppetlabs-firewall` module.


## Usage

Use the speedychains defined resource to generate and apply an array of IP
addresses that you provide, and provide the name of the chain and the action
(ACCEPT|REJECT|DROP) that you want applied to the address in the chain.

    speedychains { 'home-lan':
      chain_provider => 'iptables',
      rule_action    => 'accept',
      rule_addresses => ['192.168.0.0/16', '172.16.0.0/12'],
    }

Valid parameters are:

* `chain_name`: (optional) Name of the chain, defaults to `$name`

* `chain_provider`: The provider used, currently limited to either 'iptables' or 'ip6tables'

* `rule_action`: The action to take for each address added to the rules.

* `rule_addresses`: An array of IP addresses to go into the chain.


By default the chain will do nothing until you direct traffic into that chain,
you can do this with `puppetlabs-firewall` as per the following example:

    firewall { "100 Example Rule":
      provider => 'iptables',
      proto    => 'tcp',
      port     => '9000',
      jump     => 'home-lan',
      require  => Speedychains['home-lan'],
    }



## GeoIP Example

A common case will be using this as a companion module to
[puppet-rirs](https://github.com/jethrocarr/puppet-rirs), the following shows
how to permit access to port 9000 from country New Zealand/NZ only:

    speedychains { 'geoip-nz-v4':
      chain_provider => 'iptables',
      rule_action    => 'accept',
      rule_addresses => rir_allocations('apnic', 'ipv4', 'nz'),
    }

    firewall { "100 V4 Permit Port 9k":
      provider => 'iptables',
      proto    => 'tcp',
      port     => '9000',
      jump     => 'geoip-nz-v4',
      require  => Speedychains['geoip-nz-v4'],
    }

Remember that the chain can be defined once and then used by multiple firewall
rules anywhere in your manifests/modules, as long as you remember to set the
require statement.


## Purging

Some users like to have the firewall module purge all unmanaged rules, so that
rather than needing to ensure unwanted rules => absent, only the rules
explicitly defined will ever be on the system. This config looks like:

    resources { 'firewall':
      purge => true
    }

Unfortunatly this is no longer possible when using Speedychains since the rules
we add are technically unmanaged by Puppet (that's why it's fast!). Now in theory
our rules shouldn't get purged since we tell the firewall module specifically
NOT to purge our chain, but this code seems buggy and just purges everything
regardless of `ignore => 'string'` or `purge => false` rules on chains.

Thankfully we can get the desired behavior, by moving to defining all the
default/system chains as purgable, thus leaving other chains to be managed as
per their specific settings.

    # Blow away any existing rules in standard chains. We have to use this more
    # verbose approach, since the usual approach of:
    #
    # resources {'firewall':
    #   purge => true
    # }
    #
    # Is buggy and will purge all records from all chains, even if the other
    # chains are set to purge => false, or use ignore => "comment" :-(
    
    firewallchain { ['INPUT:filter:IPv4', 'FORWARD:filter:IPv4', 'OUTPUT:filter:IPv4']:
      purge => true,
    }
    
    firewallchain { ['INPUT:filter:IPv6', 'FORWARD:filter:IPv6', 'OUTPUT:filter:IPv6']:
      purge => true,
    }
    
    # Purge any unmanaged firewall chains
    resources { 'firewallchain':
      purge => true,
    }

When speedychains creates it's chains, it uses the Puppet firewall module to
do so, however it manages the purge/update of the rules in it's chains itself.


## Limitations

1. Currently limited to GNU/Linux platform due to it's iptables/ip6tables focus,
however I'm very open to accepting any pull requests that can add support for
other platforms and firewall systems.

2. When listing iptables rules on a server with large chains, it will take
ages as it tries to resolve reverse DNS. You can avoid this by calling it with
the `-n` option, eg `iptables -n -L`. This isn't a speedchains limitation but
rather just a default with the iptables tool on Linux. You can also decide to
list specific chains, eg just the INPUT rules with `iptables -n -L INPUT`.

3. See comments in Purging section above for limitations around purging.

4. Persistency isn't handled by this module. Generally what happens is that
the rules generated by this module get saved when `puppetlabs-firewall` next
does a save, generally this always happens after defining the chains, since most
users will have an firewall record that calls the chain and triggers an update
of the saved copy. But it does mean if the chain itself changes and nothing
else does, it doesn't get saved back to disk. Ideally need a way to hook into
the firewall module's save functionality, don't really want to clone it all...


## License
This module is licensed under the Apache License, Version 2.0 (the "License").
See the LICENSE or http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

