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

By default the chain will do nothing until you direct traffic into that chain,
you can do this with `puppetlabs-firewall` as per the following example:

TODO




## GeoIP Example

A common case will be using this as a companion module to
[puppet-rirs](https://github.com/jethrocarr/puppet-rirs), the following shows
how to permit access to port 80 from country New Zealand/NZ only:

TODO



## Limitations

1. Currently limited to GNU/Linux platform due to it's iptables/ip6tables focus,
however I'm very open to accepting any pull requests that can add support for
other platforms and firewall systems.

2. When listing iptables rules on a server with large chains, it will take
ages as it tries to resolve reverse DNS. You can avoid this by calling it with
the `-n` option, eg `iptables -n -L`. This isn't a speedchains limitation but
rather just a default with the iptables tool on Linux.

3. You can't use the firewall module's feature to purge all chains since this
chain is technically unmanaged by Puppet, ie this will break this module:

    resources { 'firewallchain':
      purge => true,
    }

You can safely still use the purge option to purge contents of specific chains
if you're using the firewall module to define your own additional chains.


## License
This module is licensed under the Apache License, Version 2.0 (the "License").
See the LICENSE or http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

