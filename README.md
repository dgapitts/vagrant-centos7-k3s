# vagrant-centos7-k3s

## Setup new VM

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

## Helloworld

Okay so I setup my base install (as above a few days ago)
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get node
NAME         STATUS   ROLES                  AGE    VERSION
centos7k3s   Ready    control-plane,master   2d3h   v1.21.5+k3s2
```

Now I'm following the learning-kubernetes linkedin course and I've added the helloworld.yaml to the project


```
[~/projects/vagrant-centos7-k3s] # vagrant reload
==> vagrant: A new version of Vagrant is available: 2.2.19!
==> vagrant: To upgrade visit: https://www.vagrantup.com/downloads.html

==> default: Attempting graceful shutdown of VM...
==> default: Clearing any previously set forwarded ports...
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 8081 (guest) => 8081 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
vagrant ssh
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
    default: No guest additions were detected on the base box for this VM! Guest
    default: additions are required for forwarded ports, shared folders, host only
    default: networking, and more. If SSH fails on this machine, please install
    default: the guest additions and repackage the box to continue.
    default: 
    default: This is not an error message; everything may continue to work properly,
    default: in which case you may ignore this message.
==> default: Setting hostname...
==> default: Rsyncing folder: /home/dpitts/projects/vagrant-centos7-k3s/ => /vagrant
==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> default: flag to force provisioning. Provisioners marked to run always will still run.
[~/projects/vagrant-centos7-k3s] # vagrant ssh

```

and now, after the `Rsyncing folder` step above,

```
==> default: Rsyncing folder: /home/dpitts/projects/vagrant-centos7-k3s/ => /vagrant
```

we can see the file from witin the vagrant 

```
[root@centos7k3s ~]# cat /vagrant/helloworld.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld
spec:
  selector:
    matchLabels:
      app: helloworld
  replicas: 1 # tells deployment to run 1 pods matching the template
  template: # create pods using pod definition in this template
    metadata:
      labels:
        app: helloworld
    spec:
      containers:
      - name: helloworld
        image: karthequian/helloworld:latest
        ports:
        - containerPort: 80
```

now using `kubectl create`
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl create -f /vagrant/helloworld.yaml 
deployment.apps/helloworld created
```
and now 
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get node
NAME         STATUS   ROLES                  AGE    VERSION
centos7k3s   Ready    control-plane,master   2d3h   v1.21.5+k3s2
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                              READY   STATUS              RESTARTS   AGE
pod/helloworld-66f646b9bb-mjqgz   0/1     ContainerCreating   0          17s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   2d3h

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld   0/1     1            0           17s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-66f646b9bb   1         1         0       17s
```