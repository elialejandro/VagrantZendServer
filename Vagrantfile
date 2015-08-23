# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  
  config.vm.network "private_network", ip: "192.168.56.105"
  # config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    #vb.gui = true
    vb.memory = "1024"
    vb.cpus = 2
  end
  
  config.vm.provision "shell", path: "provision.sh"
end
