#! /bin/bash
if [ ! -f /home/vagrant/already-installed-flag ]
then
  echo "ADD EXTRA ALIAS VIA .bashrc"
  cat /vagrant/bashrc.append.txt >> /home/vagrant/.bashrc

  #echo "GENERAL YUM UPDATE"
  #yum -y update
  #echo "INSTALL GIT"
  #yum -y install git
  #echo "INSTALL TREE"
  #yum -y install tree
  #echo "INSTALL unzip curl wget lsof"
  #yum  -y install unzip curl wget lsof 


  time curl -sfL https://get.k3s.io | sh -
  #k3s server &
  # Kubeconfig is written to /etc/rancher/k3s/k3s.yaml
  uptime
  /usr/local/bin/k3s kubectl get node

  # Add ShellCheck https://github.com/koalaman/shellcheck - a great tool for testing and improving the quality of shell scripts
  #yum -y install epel-release
  #yum -y install ShellCheck

else
  echo "already installed flag set : /home/vagrant/already-installed-flag"
fi

