#
# Cookbook Name:: rightscaleshim
#
# Copyright (c) 2013 Ryan J. Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

node.default['cloud']['provider'] = 'vagrant'
node.default['cloud']['private_ips'] = []
node.default['cloud']['public_ips'] = []

node.default['rightscale']['instance_uuid'] = 'UUID'
node.default['rightscale']['servers']['sketchy']['hostname'] = 'localhost'

# If it isn't set, set it
node.default['sys_firewall']['enabled'] = 'disabled'
# If it is set, overwrite it
node.normal['sys_firewall']['enabled'] = 'disabled'

node.default['sys']['swap_size'] = '0.5'
node.default['sys']['swap_file'] = '/mnt/ephemeral/swapfile'

private_ips = []
public_ips = []

# Fauxhai 1.1.1 (which ChefSpec 2 uses) doesn't have an interfaces network key
unless node['network'].key?('interfaces')
  node.set['network']['interfaces'] = {}
  node.set['network']['interfaces']['eth0'] = node['network']['eth0']
end

node['network']['interfaces'].each do |iface|
  iface[1]['addresses'].each do |addr|
    ip = addr[0]
    details = addr[1]
    if details['family'] == 'inet'
      case ip
      when /^10|172|192\./
        private_ips << ip
      when '127.0.0.1'
        # Intentionally don't do anything
      else
        public_ips << ip
      end
    end
  end
end

node.set['cloud']['private_ips'] = private_ips
node.set['cloud']['public_ips'] = public_ips
