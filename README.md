# vagrant-centos7-k3s

After running `vagrant up`

```
[~/projects/vagrant-centos7-k3s] # vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1804_02.VirtualBox.box'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: vagrant-centos7-k3s_default_1637946925870_92800
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat

```

the core of the k3s install is covered in provision.sh i.e. here
```
[~/projects/vagrant-centos7-k3s] # cat provision.sh | grep -A4 'time curl'
  time curl -sfL https://get.k3s.io | sh -
  #k3s server &
  # Kubeconfig is written to /etc/rancher/k3s/k3s.yaml
  uptime
  /usr/local/bin/k3s kubectl get node
```

and it takes a couple of mins to download and install

```
...
    default: [INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
    default: [INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
    default: [INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
    default: [INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
    default: [INFO]  systemd: Enabling k3s unit
    default: Created symlink from /etc/systemd/system/multi-user.target.wants/k3s.service to /etc/systemd/system/k3s.service.
    default: [INFO]  systemd: Starting k3s
    default: 
    default: real	1m59.714s
    default: user	0m44.150s
    default: sys	0m21.106s
    default:  17:17:56 up 2 min,  0 users,  load average: 0.57, 0.23, 0.09
    default: NAME         STATUS   ROLES                  AGE   VERSION
    default: centos7k3s   Ready    control-plane,master   14s   v1.21.5+k3s2
[~/projects/vagrant-centos7-k3s] # 
```

and as above the final step shows that k3s is indeed
```
    default: NAME         STATUS   ROLES                  AGE   VERSION
    default: centos7k3s   Ready    control-plane,master   14s   v1.21.5+k3s2
```

i.e. via running 


```
/usr/local/bin/k3s kubectl get node
```

Note I have to put the fullpath above, going to review why `/usr/local/bin/` is not in the default path 