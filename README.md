Description
===========

A cookbook which hopes to allow vagrant interoperability with RightScale Chef cookbooks, including support for the RightScale only functionality like remote_recipe, server_collection, and right_link_tag.

The persistent file is stored in /vagrant/rightscaleshim/#{config.vm.hostname}, so in a multi VM vagrant environment, make sure that the hostnames are unique!

Requirements
============

Attributes
==========

Features
========
* Writes collectd rrd data to /var/lib/collectd (or OS specific directory) so that you can verify custom monitoring configurations

Usage
=====

Add the default recipe as the first recipe in your runlist for vagrant.

A bare minimum sample Vagrantfile
    Vagrant.configure("2") do |config|
      config.vm.hostname = "centos"

      config.vm.box = "ri_centos6.3_v5.8.8"
      config.vm.box_url = "https://s3.amazonaws.com/rgeyer/pub/ri_centos6.3_v5.8.8_vagrant.box"

      config.vm.network :private_network, ip: "33.33.33.10"

      config.ssh.max_tries = 40
      config.ssh.timeout   = 120

      config.rightscaleshim.run_list_dir = "runlists/centos"
      config.rightscaleshim.shim_dir = "rightscaleshim/centos"
      config.vm.provision :chef_solo do |chef|
        # This intentionally left blank
      end
    end

sys_firewall mucks up something which makes it impossible to ssh into the vagrant box after startup.  I've tried enabling port 2222 but that does not seem to help.  So for now node['sys_firewall']['enabled'] gets hardcoded to 'disabled'

TODO
====

* Allow the use of
  * block_device::*, but particularly block_device::setup_ephemeral
  * sys::setup_swap


Stream of Consciousness
=======================

* host daemon
  * watches rightscaleshim/**/dispatch/ for new *.js files
  * upon finding one, runs `bundle exec vagrant provision <boxname>` for each box with the target tag specified in the dispatch *.js file
* vagrantfile
  * A library will be added to the vagrant file (I.E. require 'somelib') which will interrogate the dispatch directory and replace chef.json and chef.run_list with the correct stuff, or default to the boot runlist