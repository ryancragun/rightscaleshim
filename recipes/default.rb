#
# Cookbook Name:: rightscaleshim
# Recipe:: default
#
# Copyright (c) 2013 Ryan J. Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

############### START COMPILE TIME EXECUTION

# Hack up some filesystem things *right now*
#d = directory "/opt/rightscale/sandbox/bin" do
#  recursive true
#  action :nothing
#end

#d.run_action(:create)

#l = link "/opt/rightscale/sandbox/bin/gem" do
#  to "/opt/chef/embedded/bin/gem"
#  action :nothing
#end

#l.run_action(:create)

# RightImage dependencies
#%w{libxml2-devel libxslt-devel}.each do |p|
#  pack = package p do
#    action :nothing
#  end
#
#  pack.run_action(:install)
#end

chef_gem "chef-rewind"
require 'chef/rewind'

############### END COMPILE TIME EXECUTION

node_file = ::File.join("/vagrant/", node["rightscaleshim"]["shim_dir"], "node.js")
node_persister_name = "Persist node content to #{node_file}"

rightscaleshim_node_persister node_persister_name do
  action :nothing
end

file ::File.join(Chef::Config[:file_cache_path], "rightscaleshim_node_persister") do
  action :touch
  notifies :dehydrate, "rightscaleshim_node_persister[#{node_persister_name}]", :delayed
end

# TODO: Make this multi OS
template "/etc/yum.repos.d/Rightscale-epel.repo" do
  source "rightscale-epel.repo.erb"
end

# TODO: Figure out where this thing originates from, and get it from there.
cookbook_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-RightScale" do
  source "RPM-GPG-KEY-RightScale"
end

include_recipe "cron"

if node['platform_family'] == "rhel"
  include_recipe "yum::epel"
end

package "ruby"
package "collectd-rrdtool"
package "parted"

# TODO: Not sure why running this in the actual rightscale::setup_monitoring does not work
# But collectd is not installed on Cent 6.3
packages = node[:rightscale][:collectd_packages]
packages.each do |p|
  package "rightscaleshim install package #{p}" do
    package_name p
    action :install
  end
end

include_recipe "rightscale::setup_monitoring"

# Don't let rightscale::setup_monitoring bully us
rewind "package[collectd]" do
  only_if { false }
end

sys_firewall "2222"