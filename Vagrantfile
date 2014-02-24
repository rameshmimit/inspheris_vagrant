# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "precise64"
    ubuntu.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end

  config.vm.define "ubuntu", primary: true do |ubuntu|
    ubuntu.vm.box = "precise64"
    ubuntu.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end

  # For CentOS-5.9
  config.vm.define "centos" do |centos|
    centos.vm.box = "centos-5.9-x86-64-minimal"
    centos.vm.box_url = "http://tag1consulting.com/files/centos-5.9-x86-64-minimal.box"
  end

  config.vm.network :private_network, ip: "192.168.33.10"

  # argument is a set of non-required options.
  #config.vm.synced_folder "~/Workspace", "/Workspace", :nfs => true
  config.vm.synced_folder "~/Workspace", "/Workspace"

  # Example for VirtualBox:
  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  # Update puppet to version 3.2.2 before using puppet provisioning.
  config.vm.provision :shell, :path => "shell/update_puppet.sh"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file  = "init.pp"
    puppet.options = [
                      "--parser future",
                      "--fileserverconfig=/vagrant/puppet/fileserver.conf",
                      # "--verbose --debug"
                     ]
  end
end
