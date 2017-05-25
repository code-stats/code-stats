# © Lau Taanrskov
# Licensed under Apache License 2.0
# From https://github.com/lau/vagrant_elixir
# Modified for Code::Stats

# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

VM_NAME = "codestats_vm"
MEMORY_SIZE_MB = 2048
NUMBER_OF_CPUS = 3

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/zesty64"

  config.vm.define "elixir_box" do |elixir_box|
    elixir_box.vm.provider "virtualbox" do |v|
      v.name = VM_NAME
      v.customize ["modifyvm", :id, "--memory", MEMORY_SIZE_MB]
      v.customize ["modifyvm", :id, "--cpus", NUMBER_OF_CPUS]
    end
    elixir_box.vm.network :private_network, ip: "192.168.55.55"
    elixir_box.vm.network :forwarded_port, guest: 5432, host: 45432
    elixir_box.vm.network :forwarded_port, guest: 5000, host: 15000
    elixir_box.vm.provision :shell, :path => "vagrant_provision.sh"
  end
end
