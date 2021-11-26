# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", 2]
  end
  #config.vm.box = "centos/7"
  config.vm.box = "https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1804_02.VirtualBox.box"
  config.vm.hostname = "centos7k3s"
  config.vm.network :forwarded_port, guest: 8081, host: 8081
  config.vm.provision :shell, :path => "provision.sh"
end
