# vagrant-centos7-k3s

Background:
* [k8s cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
* [learning-kubernetes](https://www.linkedin.com/learning/learning-kubernetes)

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


### Exposing service/helloworld

After running 
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl expose deployment helloworld --type=NodePort
service/helloworld exposed
```
we see a new service 
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                              READY   STATUS              RESTARTS   AGE
pod/helloworld-66f646b9bb-k52r5   0/1     ContainerCreating   0          93s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP        5h5m
service/helloworld   NodePort    10.43.114.77   <none>        80:30041/TCP   3s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld   0/1     1            0           93s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-66f646b9bb   1         1         0       93s
```
and now we can use curl to 
```
[root@centos7k3s ~]# curl http://10.43.114.77:80
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="A simple docker helloworld example.">
    <meta name="author" content="Karthik Gaekwad">
    <meta name="viewport" content="width=device-width, initial-scale=1">

	<!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<script type="text/javascript">
function init ( )
{
  timeDisplay = document.createTextNode ( "" );
  document.getElementById("clock").appendChild ( timeDisplay );
}

...
```




### kubectl get deployment/helloworld
here we have 
* apiVersion: apps/v1
* app: helloworld
* image: karthequian/helloworld:latest
* containerPort: 80
```
  console.log(counter);
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get deployment/helloworld -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: "2021-11-29T18:17:08Z"
  generation: 1
  name: helloworld
  namespace: default
  resourceVersion: "13509"
  uid: 90fb18ad-7c6c-4684-8d86-42e3fbc4c360
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: helloworld
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: helloworld
    spec:
      containers:
      - image: karthequian/helloworld:latest
        imagePullPolicy: Always
        name: helloworld
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2021-11-29T18:19:32Z"
    lastUpdateTime: "2021-11-29T18:19:32Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2021-11-29T18:17:08Z"
    lastUpdateTime: "2021-11-29T18:19:32Z"
    message: ReplicaSet "helloworld-66f646b9bb" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 1
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1
```
### kubectl get service/helloworld
here we have 
* cluster IP 10.43.114.77
* the ports, including the node port for 32124, linked to port 80 with a target port of 80, and we're using the protocol of TCP.

```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get service/helloworld -o yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2021-11-29T18:18:38Z"
  name: helloworld
  namespace: default
  resourceVersion: "13461"
  uid: d080d361-6691-4d34-bf86-43187cc811fc
spec:
  clusterIP: 10.43.114.77
  clusterIPs:
  - 10.43.114.77
  externalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 30041
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: helloworld
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```


### kubectl get pods --show-labels

```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
helloworld-66f646b9bb-k52r5   1/1     Running   1          4d3h
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE    LABELS
helloworld-66f646b9bb-k52r5   1/1     Running   1          4d3h   app=helloworld,pod-template-hash=66f646b9bb
```


### kubectl label - overwriting and removing labels

Starting with my earlier helloworld pod
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE   LABELS
helloworld-66f646b9bb-k52r5   1/1     Running   3          8d    app=helloworld,pod-template-hash=66f646b9bb
```

To change label `helloworld` to `helloworld-demo` using `--overwrite` 
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl label po/helloworld-66f646b9bb-k52r5 app=helloworld-demo --overwrite
pod/helloworld-66f646b9bb-k52r5 labeled
```

two things happened
* label `app=helloworld-demo` changed as expected
* as there is pod no labeled `app=helloworld`, a new one is automated started (15s old)
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE   LABELS
helloworld-66f646b9bb-k52r5   1/1     Running   3          8d    app=helloworld-demo,pod-template-hash=66f646b9bb
helloworld-66f646b9bb-nqdjx   1/1     Running   0          15s   app=helloworld,pod-template-hash=66f646b9bb
```

lastly removing the app label (app-)
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl label po/helloworld-66f646b9bb-k52r5 app-
pod/helloworld-66f646b9bb-k52r5 labeled
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE   LABELS
helloworld-66f646b9bb-nqdjx   1/1     Running   0          70s   app=helloworld,pod-template-hash=66f646b9bb
helloworld-66f646b9bb-k52r5   1/1     Running   3          8d    pod-template-hash=66f646b9bb
```

### Working with labels - sample-infrastructure-with-labels.yml

This is from the [linkedin.com learning-kubernetes course](https://www.linkedin.com/learning/learning-kubernetes)

```
[root@centos7k3s vagrant]# cat /vagrant/sample-infrastructure-with-labels.yml
apiVersion: v1
kind: Pod
metadata:
  name: homepage-dev
  labels:
    env: development
    dev-lead: karthik
    team: web
    application_type: ui
    release-version: "12.0"
spec:
  containers:
  - name: helloworld
    image: karthequian/helloworld:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: homepage-staging
  labels:
    env: staging
    team: web
    dev-lead: karthik
    application_type: ui
    release-version: "12.0"
spec:
  containers:
  - name: helloworld
    image: karthequian/helloworld:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: homepage-prod
  labels:
    env: production
    team: web
    dev-lead: karthik
    application_type: ui
    release-version: "12.0"
spec:
  containers:
  - name: helloworld
    image: karthequian/helloworld:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: login-dev
  labels:
    env: development
    team: auth
    dev-lead: jim
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: login
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: login-staging
  labels:
    env: staging
    team: auth
    dev-lead: jim
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: login
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: login-prod
  labels:
    env: production
    team: auth
    dev-lead: jim
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: login
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: cart-dev
  labels:
    env: development
    team: ecommerce
    dev-lead: carisa
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: cart
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: cart-staging
  labels:
    env: staging
    team: ecommerce
    dev-lead: carisa
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: cart
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: cart-prod
  labels:
    env: production
    team: ecommerce
    dev-lead: carisa
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: cart
    image: karthequian/ruby:latest
---

apiVersion: v1
kind: Pod
metadata:
  name: social-dev
  labels:
    env: development
    team: marketing
    dev-lead: carisa
    application_type: api
    release-version: "2.0"
spec:
  containers:
  - name: social
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: social-staging
  labels:
    env: staging
    team: marketing
    dev-lead: marketing
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: social
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: social-prod
  labels:
    env: production
    team: marketing
    dev-lead: marketing
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: social
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: catalog-dev
  labels:
    env: development
    team: ecommerce
    dev-lead: daniel
    application_type: api
    release-version: "4.0"
spec:
  containers:
  - name: catalog
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: catalog-staging
  labels:
    env: staging
    team: ecommerce
    dev-lead: daniel
    application_type: api
    release-version: "4.0"
spec:
  containers:
  - name: catalog
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: catalog-prod
  labels:
    env: production
    team: ecommerce
    dev-lead: daniel
    application_type: api
    release-version: "4.0"
spec:
  containers:
  - name: catalog
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: quote-dev
  labels:
    env: development
    team: ecommerce
    dev-lead: amy
    application_type: api
    release-version: "2.0"
spec:
  containers:
  - name: quote
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: quote-staging
  labels:
    env: staging
    team: ecommerce
    dev-lead: amy
    application_type: api
    release-version: "2.0"
spec:
  containers:
  - name: quote
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: quote-prod
  labels:
    env: production
    team: ecommerce
    dev-lead: amy
    application_type: api
    release-version: "1.0"
spec:
  containers:
  - name: quote
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: ordering-dev
  labels:
    env: development
    team: purchasing
    dev-lead: chen
    application_type: backend
    release-version: "2.0"
spec:
  containers:
  - name: ordering
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: ordering-staging
  labels:
    env: staging
    team: purchasing
    dev-lead: chen
    application_type: backend
    release-version: "2.0"
spec:
  containers:
  - name: ordering
    image: karthequian/ruby:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: ordering-prod
  labels:
    env: production
    team: purchasing
    dev-lead: chen
    application_type: backend
    release-version: "2.0"
spec:
  containers:
  - name: ordering
    image: karthequian/ruby:latest
```

and it only takes a minute or two to spin up all these services

```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl create -f /vagrant/sample-infrastructure-with-labels.yml
pod/homepage-dev created
pod/homepage-staging created
pod/homepage-prod created
pod/login-dev created
pod/login-staging created
pod/login-prod created
pod/cart-dev created
pod/cart-staging created
pod/cart-prod created
pod/social-dev created
pod/social-staging created
pod/social-prod created
pod/catalog-dev created
pod/catalog-staging created
pod/catalog-prod created
pod/quote-dev created
pod/quote-staging created
pod/quote-prod created
pod/ordering-dev created
pod/ordering-staging created
pod/ordering-prod created
[root@centos7k3s vagrant]#  /usr/local/bin/k3s kubectl get all
NAME                              READY   STATUS              RESTARTS   AGE
pod/helloworld-66f646b9bb-nqdjx   1/1     Running             1          106m
pod/helloworld-66f646b9bb-k52r5   1/1     Running             4          8d
pod/login-dev                     0/1     ContainerCreating   0          14s
pod/login-staging                 0/1     ContainerCreating   0          14s
pod/login-prod                    0/1     ContainerCreating   0          14s
pod/cart-dev                      0/1     ContainerCreating   0          14s
pod/cart-staging                  0/1     ContainerCreating   0          13s
pod/cart-prod                     0/1     ContainerCreating   0          13s
pod/social-dev                    0/1     ContainerCreating   0          13s
pod/social-staging                0/1     ContainerCreating   0          13s
pod/catalog-dev                   0/1     ContainerCreating   0          13s
pod/social-prod                   0/1     ContainerCreating   0          13s
pod/catalog-staging               0/1     ContainerCreating   0          13s
pod/catalog-prod                  0/1     ContainerCreating   0          13s
pod/quote-dev                     0/1     ContainerCreating   0          13s
pod/quote-staging                 0/1     ContainerCreating   0          13s
pod/quote-prod                    0/1     ContainerCreating   0          13s
pod/ordering-prod                 0/1     ContainerCreating   0          13s
pod/homepage-dev                  1/1     Running             0          14s
pod/ordering-staging              0/1     ContainerCreating   0          13s
pod/ordering-dev                  0/1     ContainerCreating   0          13s
pod/homepage-staging              1/1     Running             0          14s
pod/homepage-prod                 1/1     Running             0          14s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP        8d
service/helloworld   NodePort    10.43.114.77   <none>        80:30041/TCP   8d

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld   1/1     1            1           8d

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-66f646b9bb   1         1         1       8d
```

they are nicely labelled
```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE     LABELS
helloworld-66f646b9bb-nqdjx   1/1     Running   1          115m    app=helloworld,pod-template-hash=66f646b9bb
helloworld-66f646b9bb-k52r5   1/1     Running   4          8d      pod-template-hash=66f646b9bb
homepage-dev                  1/1     Running   0          9m38s   application_type=ui,dev-lead=karthik,env=development,release-version=12.0,team=web
homepage-staging              1/1     Running   0          9m38s   application_type=ui,dev-lead=karthik,env=staging,release-version=12.0,team=web
homepage-prod                 1/1     Running   0          9m38s   application_type=ui,dev-lead=karthik,env=production,release-version=12.0,team=web
login-prod                    1/1     Running   0          9m38s   application_type=api,dev-lead=jim,env=production,release-version=1.0,team=auth
login-dev                     1/1     Running   0          9m38s   application_type=api,dev-lead=jim,env=development,release-version=1.0,team=auth
social-dev                    1/1     Running   0          9m37s   application_type=api,dev-lead=carisa,env=development,release-version=2.0,team=marketing
social-prod                   1/1     Running   0          9m37s   application_type=api,dev-lead=marketing,env=production,release-version=1.0,team=marketing
cart-dev                      1/1     Running   0          9m38s   application_type=api,dev-lead=carisa,env=development,release-version=1.0,team=ecommerce
social-staging                1/1     Running   0          9m37s   application_type=api,dev-lead=marketing,env=staging,release-version=1.0,team=marketing
ordering-dev                  1/1     Running   0          9m37s   application_type=backend,dev-lead=chen,env=development,release-version=2.0,team=purchasing
catalog-staging               1/1     Running   0          9m37s   application_type=api,dev-lead=daniel,env=staging,release-version=4.0,team=ecommerce
catalog-prod                  1/1     Running   0          9m37s   application_type=api,dev-lead=daniel,env=production,release-version=4.0,team=ecommerce
catalog-dev                   1/1     Running   0          9m37s   application_type=api,dev-lead=daniel,env=development,release-version=4.0,team=ecommerce
ordering-staging              1/1     Running   0          9m37s   application_type=backend,dev-lead=chen,env=staging,release-version=2.0,team=purchasing
quote-dev                     1/1     Running   0          9m37s   application_type=api,dev-lead=amy,env=development,release-version=2.0,team=ecommerce
login-staging                 1/1     Running   0          9m38s   application_type=api,dev-lead=jim,env=staging,release-version=1.0,team=auth
cart-prod                     1/1     Running   0          9m37s   application_type=api,dev-lead=carisa,env=production,release-version=1.0,team=ecommerce
quote-prod                    1/1     Running   0          9m37s   application_type=api,dev-lead=amy,env=production,release-version=1.0,team=ecommerce
ordering-prod                 1/1     Running   0          9m37s   application_type=backend,dev-lead=chen,env=production,release-version=2.0,team=purchasing
quote-staging                 1/1     Running   0          9m37s   application_type=api,dev-lead=amy,env=staging,release-version=2.0,team=ecommerce
cart-staging                  1/1     Running   0          9m37s   application_type=api,dev-lead=carisa,env=staging,release-version=1.0,team=ecommerce
```

### kubectl get pods --selector env=production
```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --selector env=production
NAME            READY   STATUS    RESTARTS   AGE
homepage-prod   1/1     Running   0          15m
social-prod     1/1     Running   1          14m
cart-prod       1/1     Running   1          14m
login-prod      1/1     Running   1          15m
quote-prod      1/1     Running   1          14m
catalog-prod    1/1     Running   1          14m
ordering-prod   1/1     Running   1          14m
```

### kubectl more queries by --selector and -l (label) - plus then delete plots

Continuing yesterday's leson, a more complex `--selector` operations
```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --selector dev-lead=karthik
NAME               READY   STATUS    RESTARTS   AGE
homepage-dev       1/1     Running   0          22h
homepage-staging   1/1     Running   0          22h
homepage-prod      1/1     Running   0          22h
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --selector dev-lead=karthik,env=staging
NAME               READY   STATUS    RESTARTS   AGE
homepage-staging   1/1     Running   0          22h
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --selector dev-lead=karthik,env=staging --show-labels
NAME               READY   STATUS    RESTARTS   AGE   LABELS
homepage-staging   1/1     Running   0          22h   application_type=ui,dev-lead=karthik,env=staging,release-version=12.0,team=web
```

and then switching to the query by label IN list

```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods -l 'release-version in (1.0,4.0)' --show-labels
NAME              READY   STATUS    RESTARTS   AGE   LABELS
cart-prod         1/1     Running   59         22h   application_type=api,dev-lead=carisa,env=production,release-version=1.0,team=ecommerce
login-dev         1/1     Running   62         22h   application_type=api,dev-lead=jim,env=development,release-version=1.0,team=auth
social-staging    1/1     Running   55         22h   application_type=api,dev-lead=marketing,env=staging,release-version=1.0,team=marketing
social-prod       1/1     Running   55         22h   application_type=api,dev-lead=marketing,env=production,release-version=1.0,team=marketing
login-prod        1/1     Running   58         22h   application_type=api,dev-lead=jim,env=production,release-version=1.0,team=auth
quote-prod        1/1     Running   61         22h   application_type=api,dev-lead=amy,env=production,release-version=1.0,team=ecommerce
cart-dev          1/1     Running   62         22h   application_type=api,dev-lead=carisa,env=development,release-version=1.0,team=ecommerce
catalog-prod      1/1     Running   54         22h   application_type=api,dev-lead=daniel,env=production,release-version=4.0,team=ecommerce
login-staging     1/1     Running   55         22h   application_type=api,dev-lead=jim,env=staging,release-version=1.0,team=auth
catalog-dev       1/1     Running   53         22h   application_type=api,dev-lead=daniel,env=development,release-version=4.0,team=ecommerce
cart-staging      1/1     Running   61         22h   application_type=api,dev-lead=carisa,env=staging,release-version=1.0,team=ecommerce
catalog-staging   1/1     Running   60         22h   application_type=api,dev-lead=daniel,env=staging,release-version=4.0,team=ecommerce
```

and NOTIN

```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods -l 'release-version notin (1.0,4.0)' --show-labels
NAME                          READY   STATUS    RESTARTS   AGE   LABELS
helloworld-66f646b9bb-nqdjx   1/1     Running   1          24h   app=helloworld,pod-template-hash=66f646b9bb
helloworld-66f646b9bb-k52r5   1/1     Running   4          9d    pod-template-hash=66f646b9bb
homepage-dev                  1/1     Running   0          22h   application_type=ui,dev-lead=karthik,env=development,release-version=12.0,team=web
homepage-staging              1/1     Running   0          22h   application_type=ui,dev-lead=karthik,env=staging,release-version=12.0,team=web
homepage-prod                 1/1     Running   0          22h   application_type=ui,dev-lead=karthik,env=production,release-version=12.0,team=web
social-dev                    1/1     Running   63         22h   application_type=api,dev-lead=carisa,env=development,release-version=2.0,team=marketing
quote-dev                     1/1     Running   61         22h   application_type=api,dev-lead=amy,env=development,release-version=2.0,team=ecommerce
ordering-staging              1/1     Running   56         22h   application_type=backend,dev-lead=chen,env=staging,release-version=2.0,team=purchasing
ordering-dev                  1/1     Running   61         22h   application_type=backend,dev-lead=chen,env=development,release-version=2.0,team=purchasing
quote-staging                 1/1     Running   66         22h   application_type=api,dev-lead=amy,env=staging,release-version=2.0,team=ecommerce
ordering-prod                 1/1     Running   69         22h   application_type=backend,dev-lead=chen,env=production,release-version=2.0,team=purchasing
````

### kubectl more queries `--selector` queries and with `delete` pod operations

```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --selector dev-lead=karthik --show-labels
NAME               READY   STATUS    RESTARTS   AGE   LABELS
homepage-dev       1/1     Running   0          22h   application_type=ui,dev-lead=karthik,env=development,release-version=12.0,team=web
homepage-staging   1/1     Running   0          22h   application_type=ui,dev-lead=karthik,env=staging,release-version=12.0,team=web
homepage-prod      1/1     Running   0          22h   application_type=ui,dev-lead=karthik,env=production,release-version=12.0,team=web
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl delete pods --selector dev-lead=karthik
pod "homepage-dev" deleted
pod "homepage-staging" deleted
pod "homepage-prod" deleted
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --selector dev-lead=karthik --show-labels
No resources found in default namespace.
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE   LABELS
helloworld-66f646b9bb-nqdjx   1/1     Running   1          24h   app=helloworld,pod-template-hash=66f646b9bb
helloworld-66f646b9bb-k52r5   1/1     Running   4          9d    pod-template-hash=66f646b9bb
login-dev                     1/1     Running   62         22h   application_type=api,dev-lead=jim,env=development,release-version=1.0,team=auth
social-staging                1/1     Running   55         22h   application_type=api,dev-lead=marketing,env=staging,release-version=1.0,team=marketing
social-dev                    1/1     Running   63         22h   application_type=api,dev-lead=carisa,env=development,release-version=2.0,team=marketing
social-prod                   1/1     Running   55         22h   application_type=api,dev-lead=marketing,env=production,release-version=1.0,team=marketing
login-prod                    1/1     Running   58         22h   application_type=api,dev-lead=jim,env=production,release-version=1.0,team=auth
quote-prod                    1/1     Running   61         22h   application_type=api,dev-lead=amy,env=production,release-version=1.0,team=ecommerce
cart-dev                      1/1     Running   62         22h   application_type=api,dev-lead=carisa,env=development,release-version=1.0,team=ecommerce
catalog-prod                  1/1     Running   54         22h   application_type=api,dev-lead=daniel,env=production,release-version=4.0,team=ecommerce
login-staging                 1/1     Running   55         22h   application_type=api,dev-lead=jim,env=staging,release-version=1.0,team=auth
quote-dev                     1/1     Running   61         22h   application_type=api,dev-lead=amy,env=development,release-version=2.0,team=ecommerce
catalog-dev                   1/1     Running   53         22h   application_type=api,dev-lead=daniel,env=development,release-version=4.0,team=ecommerce
cart-staging                  1/1     Running   61         22h   application_type=api,dev-lead=carisa,env=staging,release-version=1.0,team=ecommerce
catalog-staging               1/1     Running   60         22h   application_type=api,dev-lead=daniel,env=staging,release-version=4.0,team=ecommerce
ordering-staging              1/1     Running   56         22h   application_type=backend,dev-lead=chen,env=staging,release-version=2.0,team=purchasing
ordering-dev                  1/1     Running   61         22h   application_type=backend,dev-lead=chen,env=development,release-version=2.0,team=purchasing
quote-staging                 1/1     Running   66         22h   application_type=api,dev-lead=amy,env=staging,release-version=2.0,team=ecommerce
ordering-prod                 1/1     Running   69         22h   application_type=backend,dev-lead=chen,env=production,release-version=2.0,team=purchasing
cart-prod                     1/1     Running   60         22h   application_type=api,dev-lead=carisa,env=production,release-version=1.0,team=ecommerce
```



### readinessProbe and livenessProbe - happy day setup


As per https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
* readinessProbe
> The kubelet uses readiness probes to know when a container is ready to start accepting traffic. A Pod is considered ready when all of its containers are ready. One use of this signal is to control which Pods are used as backends for Services. When a Pod is not ready, it is removed from Service load balancers.
* livenessProbe
> The kubelet uses liveness probes to know when to restart a container. For example, liveness probes could catch a deadlock, where an application is running, but unable to make progress.
* Caution:
> Liveness probes do not wait for readiness probes to succeed. If you want to wait before executing a liveness probe you should use initialDelaySeconds or a startupProbe.

Our webapp is accepting httpGet requests on port 80:
* readinessProbe
* livenessProbe 

```
[root@centos7k3s vagrant]# cat helloworld-with-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-deployment-with-probe
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
        readinessProbe:
          # length of time to wait for a pod to initialize
          # after pod startup, before applying health checking
          initialDelaySeconds: 5
          # Amount of time to wait before timing out
          timeoutSeconds: 1
          # Probe for http
          httpGet:
            # Path to probe
            path: /
            # Port to probe
            port: 80
        livenessProbe:
          # length of time to wait for a pod to initialize
          # after pod startup, before applying health checking
          initialDelaySeconds: 5
          # Amount of time to wait before timing out
          timeoutSeconds: 1
          # Probe for http
          httpGet:
            # Path to probe
            path: /
            # Port to probe
            port: 80
``` 

and everything starts nicely:

```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl create -f helloworld-with-probes.yaml
deployment.apps/helloworld-deployment-with-probe created
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get deployments
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
helloworld                         1/1     1            1           11d
helloworld-deployment-with-probe   1/1     1            1           49s
(reverse-i-search)`rep': curl http://10.43.114.77:80|g^Cp nav
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get replicasets
NAME                                          DESIRED   CURRENT   READY   AGE
helloworld-66f646b9bb                         1         1         1       11d
helloworld-deployment-with-probe-5b799b66cd   1         1         1       77s
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                                                READY   STATUS    RESTARTS   AGE     LABELS
helloworld-66f646b9bb-gwc86                         1/1     Running   0          2m55s   app=helloworld,pod-template-hash=66f646b9bb
helloworld-deployment-with-probe-5b799b66cd-56bnk   1/1     Running   0          2m55s   app=helloworld,pod-template-hash=5b799b66cd
```


### Failing readinessProbe demo

* Our webapp is still accepting httpGet requests on port 80
* But the readinessProbe is checking on port 90

```
[root@centos7k3s vagrant]# cat helloworld-with-bad-readiness-probe.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-deployment-with-bad-readiness-probe
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
        readinessProbe:
          # length of time to wait for a pod to initialize
          # after pod startup, before applying health checking
          initialDelaySeconds: 5
          # Amount of time to wait before timing out
          timeoutSeconds: 1
          # Probe for http
          httpGet:
            # Path to probe
            path: /
            # Port to probe
            port: 90[root@centos7k3s vagrant]#
```

and creating this new deployment:
```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl create -f helloworld-with-bad-readiness-probe.yaml
deployment.apps/helloworld-deployment-with-bad-readiness-probe created
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                                                             READY   STATUS    RESTARTS   AGE     LABELS
helloworld-66f646b9bb-gwc86                                      1/1     Running   0          4m47s   app=helloworld,pod-template-hash=66f646b9bb
helloworld-deployment-with-probe-5b799b66cd-56bnk                1/1     Running   0          4m47s   app=helloworld,pod-template-hash=5b799b66cd
helloworld-deployment-with-bad-readiness-probe-f49c77d55-tv5q9   0/1     Running   0          7s      app=helloworld,pod-template-hash=f49c77d55
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get deployments
NAME                                             READY   UP-TO-DATE   AVAILABLE   AGE
helloworld                                       1/1     1            1           11d
helloworld-deployment-with-probe                 1/1     1            1           7m50s
helloworld-deployment-with-bad-readiness-probe   0/1     1            0           12s
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get replicasets
NAME                                                       DESIRED   CURRENT   READY   AGE
helloworld-66f646b9bb                                      1         1         1       11d
helloworld-deployment-with-probe-5b799b66cd                1         1         1       7m57s
helloworld-deployment-with-bad-readiness-probe-f49c77d55   1         1         0       19s
```

and after 10mins...
```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                                                             READY   STATUS    RESTARTS   AGE   LABELS
helloworld-66f646b9bb-gwc86                                      1/1     Running   0          14m   app=helloworld,pod-template-hash=66f646b9bb
helloworld-deployment-with-probe-5b799b66cd-56bnk                1/1     Running   0          14m   app=helloworld,pod-template-hash=5b799b66cd
helloworld-deployment-with-bad-readiness-probe-f49c77d55-tv5q9   0/1     Running   0          10m   app=helloworld,pod-template-hash=f49c77d55
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get replicasets
NAME                                                       DESIRED   CURRENT   READY   AGE
helloworld-66f646b9bb                                      1         1         1       11d
helloworld-deployment-with-probe-5b799b66cd                1         1         1       17m
helloworld-deployment-with-bad-readiness-probe-f49c77d55   1         1         0       10m
```


### Failing livenessProbe demo

* Our webapp is still accepting httpGet requests on port 80
* But now the livenessProbe is checking on port 90

```
[root@centos7k3s vagrant]# cat helloworld-with-bad-liveness-probe.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-deployment-with-bad-liveness-probe
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
        livenessProbe:
          # length of time to wait for a pod to initialize
          # after pod startup, before applying health checking
          initialDelaySeconds: 5
          # How often (in seconds) to perform the probe.
          periodSeconds: 5
          # Amount of time to wait before timing out
          timeoutSeconds: 1
          # Kubernetes will try failureThreshold times before giving up and restarting the Pod
          failureThreshold: 2
          # Probe for http
          httpGet:
            # Path to probe
            path: /
            # Port to probe
            port: 90
[root@centos7k3s vagrant]#
```

Starting with deploying
```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl create -f helloworld-with-bad-liveness-probe.yaml
deployment.apps/helloworld-deployment-with-bad-liveness-probe created
```

reviewing 10mins after startup
* still not ready
* 7 restarts (CrashLoopBackOff)

```
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get replicasets
NAME                                                       DESIRED   CURRENT   READY   AGE
helloworld-66f646b9bb                                      1         1         1       11d
helloworld-deployment-with-probe-5b799b66cd                1         1         1       28m
helloworld-deployment-with-bad-readiness-probe-f49c77d55   1         1         0       20m
helloworld-deployment-with-bad-liveness-probe-65bc854c5b   1         1         0       10m
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get pods --show-labels
NAME                                                             READY   STATUS             RESTARTS   AGE   LABELS
helloworld-66f646b9bb-gwc86                                      1/1     Running            0          25m   app=helloworld,pod-template-hash=66f646b9bb
helloworld-deployment-with-probe-5b799b66cd-56bnk                1/1     Running            0          25m   app=helloworld,pod-template-hash=5b799b66cd
helloworld-deployment-with-bad-readiness-probe-f49c77d55-tv5q9   0/1     Running            0          21m   app=helloworld,pod-template-hash=f49c77d55
helloworld-deployment-with-bad-liveness-probe-65bc854c5b-jc5hs   0/1     CrashLoopBackOff   7          10m   app=helloworld,pod-template-hash=65bc854c5b
[root@centos7k3s vagrant]# /usr/local/bin/k3s kubectl get deployments
NAME                                             READY   UP-TO-DATE   AVAILABLE   AGE
helloworld                                       1/1     1            1           11d
helloworld-deployment-with-probe                 1/1     1            1           29m
helloworld-deployment-with-bad-readiness-probe   0/1     1            0           21m
helloworld-deployment-with-bad-liveness-probe    0/1     1            0           11m
```



## Deployment with `--record` option
```
[root@centos7k3s ~]#  /usr/local/bin/k3s kubectl create -f /vagrant/helloworld-black.yaml --record
deployment.apps/navbar-deployment created
service/navbar-service created
```
a few seconds later we see some services are ready but the pods are in STATUS=ContainerCreating
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                                     READY   STATUS              RESTARTS   AGE
pod/navbar-deployment-66db4977c8-dkhvq   0/1     ContainerCreating   0          3s
pod/navbar-deployment-66db4977c8-xswmb   0/1     ContainerCreating   0          3s
pod/navbar-deployment-66db4977c8-zchhn   0/1     ContainerCreating   0          3s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP        4m
service/navbar-service   NodePort    10.43.119.94   <none>        80:31620/TCP   3s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/navbar-deployment   0/3     3            0           3s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/navbar-deployment-66db4977c8   3         3         0       3s
```

after about 45secs, they switched to a Running status
```
[root@centos7k3s ~]# watch /usr/local/bin/k3s kubectl get all
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                                     READY   STATUS    RESTARTS   AGE
pod/navbar-deployment-66db4977c8-zchhn   1/1     Running   0          55s
pod/navbar-deployment-66db4977c8-xswmb   1/1     Running   0          55s
pod/navbar-deployment-66db4977c8-dkhvq   1/1     Running   0          55s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP        4m52s
service/navbar-service   NodePort    10.43.119.94   <none>        80:31620/TCP   55s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/navbar-deployment   3/3     3            3           55s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/navbar-deployment-66db4977c8   3         3         3       55s
```

we can use curl to query the page
```
[root@centos7k3s ~]# curl http://10.43.114.77:80|less

[root@centos7k3s ~]# curl http://10.43.119.94:80
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="A simple docker helloworld example.">
    <meta name="author" content="Karthik Gaekwad">
    <meta name="viewport" content="width=device-width, initial-scale=1">

	<!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<script type="text/javascript">
...

[root@centos7k3s ~]# curl http://10.43.119.94:80 > 001.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4216  100  4216    0     0  4384k      0 --:--:-- --:--:-- --:--:-- 4117k
```

### kubectl set image
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl set image deployment/navbar-deployment helloworld=karthequian/helloword:blue
deployment.apps/navbar-deployment image updated
[root@centos7k3s ~]# curl http://10.43.119.94:80 > 002.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4216  100  4216    0     0  1590k      0 --:--:-- --:--:-- --:--:-- 4117k
[root@centos7k3s ~]# diff 001.html 002.html
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                                     READY   STATUS             RESTARTS   AGE
pod/navbar-deployment-66db4977c8-zchhn   1/1     Running            0          8m13s
pod/navbar-deployment-66db4977c8-xswmb   1/1     Running            0          8m13s
pod/navbar-deployment-66db4977c8-dkhvq   1/1     Running            0          8m13s
pod/navbar-deployment-7b84c4c48f-4wjp2   0/1     ImagePullBackOff   0          56s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP        12m
service/navbar-service   NodePort    10.43.119.94   <none>        80:31620/TCP   8m13s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/navbar-deployment   3/3     1            3           8m13s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/navbar-deployment-66db4977c8   3         3         3       8m13s
replicaset.apps/navbar-deployment-7b84c4c48f   1         1         0       56s
[root@centos7k3s ~]# curl http://10.43.119.94:80 > 002a.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4216  100  4216    0     0  3084k      0 --:--:-- --:--:-- --:--:-- 4117k
[root@centos7k3s ~]# diff 001.html 002a.html
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                                     READY   STATUS             RESTARTS   AGE
pod/navbar-deployment-66db4977c8-zchhn   1/1     Running            0          8m46s
pod/navbar-deployment-66db4977c8-xswmb   1/1     Running            0          8m46s
pod/navbar-deployment-66db4977c8-dkhvq   1/1     Running            0          8m46s
pod/navbar-deployment-7b84c4c48f-4wjp2   0/1     ImagePullBackOff   0          89s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP        12m
service/navbar-service   NodePort    10.43.119.94   <none>        80:31620/TCP   8m46s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/navbar-deployment   3/3     1            3           8m46s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/navbar-deployment-66db4977c8   3         3         3       8m46s
replicaset.apps/navbar-deployment-7b84c4c48f   1         1         0       89s
[root@centos7k3s ~]# curl http://10.43.119.94:80 > 002a.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4216  100  4216    0     0  3729k      0 --:--:-- --:--:-- --:--:-- 4117k
[root@centos7k3s ~]# diff 001.html 002a.html
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get rs
NAME                           DESIRED   CURRENT   READY   AGE
navbar-deployment-66db4977c8   3         3         3       10m
navbar-deployment-7b84c4c48f   1         1         0       3m41s
```

### kubectl rollout history
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl rollout history deployment/navbar-deployment
deployment.apps/navbar-deployment
REVISION  CHANGE-CAUSE
1         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true
2         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true

[root@centos7k3s ~]#
```

### kubectl rollout undo
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl rollout undo deployment/navbar-deployment
deployment.apps/navbar-deployment rolled back
```

### kubectl rollout history
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl rollout history deployment/navbar-deployment
deployment.apps/navbar-deployment
REVISION  CHANGE-CAUSE
2         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true
3         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true

[root@centos7k3s ~]# /usr/local/bin/k3s kubectl rollout history deployment/navbar-deployment
deployment.apps/navbar-deployment
REVISION  CHANGE-CAUSE
2         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true
3         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true

[root@centos7k3s ~]# /usr/local/bin/k3s kubectl rollout history deployment/navbar-deployment
deployment.apps/navbar-deployment
REVISION  CHANGE-CAUSE
2         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true
3         kubectl create --filename=/vagrant/helloworld-black.yaml --record=true
```



### kubectl get all
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                                     READY   STATUS    RESTARTS   AGE
pod/navbar-deployment-66db4977c8-zchhn   1/1     Running   0          31m
pod/navbar-deployment-66db4977c8-xswmb   1/1     Running   0          31m
pod/navbar-deployment-66db4977c8-dkhvq   1/1     Running   0          31m

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP        35m
service/navbar-service   NodePort    10.43.119.94   <none>        80:31620/TCP   31m

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/navbar-deployment   3/3     3            3           31m

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/navbar-deployment-66db4977c8   3         3         3       31m
replicaset.apps/navbar-deployment-7b84c4c48f   0         0         0       23m
```



## Trouble shooting k3s

The clue is in the name 
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl create -f /vagrant/helloworld-with-bad-pod.yaml
deployment.apps/bad-helloworld-deployment created
```
and after 3s everything seems to be starting
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                                            READY   STATUS              RESTARTS   AGE
pod/navbar-deployment-66db4977c8-xswmb          1/1     Running             1          46h
pod/navbar-deployment-66db4977c8-zchhn          1/1     Running             1          46h
pod/navbar-deployment-66db4977c8-dkhvq          1/1     Running             1          46h
pod/bad-helloworld-deployment-b564cfb94-24k2k   0/1     ContainerCreating   0          3s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP        46h
service/navbar-service   NodePort    10.43.119.94   <none>        80:31620/TCP   46h

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/navbar-deployment           3/3     3            3           46h
deployment.apps/bad-helloworld-deployment   0/1     1            0           5s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/navbar-deployment-66db4977c8          3         3         3       46h
replicaset.apps/navbar-deployment-7b84c4c48f          0         0         0       46h
replicaset.apps/bad-helloworld-deployment-b564cfb94   1         1         0       4s
```
but pod in ErrImagePull state after 10secs
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                                            READY   STATUS         RESTARTS   AGE
pod/navbar-deployment-66db4977c8-xswmb          1/1     Running        1          46h
pod/navbar-deployment-66db4977c8-zchhn          1/1     Running        1          46h
pod/navbar-deployment-66db4977c8-dkhvq          1/1     Running        1          46h
pod/bad-helloworld-deployment-b564cfb94-24k2k   0/1     ErrImagePull   0          10s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP        46h
service/navbar-service   NodePort    10.43.119.94   <none>        80:31620/TCP   46h

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/navbar-deployment           3/3     3            3           46h
deployment.apps/bad-helloworld-deployment   0/1     1            0           11s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/navbar-deployment-66db4977c8          3         3         3       46h
replicaset.apps/navbar-deployment-7b84c4c48f          0         0         0       46h
replicaset.apps/bad-helloworld-deployment-b564cfb94   1         1         0       10s
```

### kubectl describe deployment
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl describe deployment bad-helloworld-deployment
Name:                   bad-helloworld-deployment
Namespace:              default
CreationTimestamp:      Tue, 21 Dec 2021 20:42:58 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=bad-helloworld
Replicas:               1 desired | 1 updated | 1 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=bad-helloworld
  Containers:
   helloworld:
    Image:        karthequian/unkown-pod:latest
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      False   MinimumReplicasUnavailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  <none>
NewReplicaSet:   bad-helloworld-deployment-b564cfb94 (1/1 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  4m14s  deployment-controller  Scaled up replica set bad-helloworld-deployment-b564cfb94 to 1
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get pods
NAME                                        READY   STATUS             RESTARTS   AGE
navbar-deployment-66db4977c8-xswmb          1/1     Running            1          46h
navbar-deployment-66db4977c8-zchhn          1/1     Running            1          46h
navbar-deployment-66db4977c8-dkhvq          1/1     Running            1          46h
bad-helloworld-deployment-b564cfb94-24k2k   0/1     ImagePullBackOff   0          4m58s
```
### kubectl describe pod
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl describe po/bad-helloworld-deployment-b564cfb94-24k2k
Name:         bad-helloworld-deployment-b564cfb94-24k2k
Namespace:    default
Priority:     0
Node:         centos7k3s/10.0.2.15
Start Time:   Tue, 21 Dec 2021 20:42:59 +0000
Labels:       app=bad-helloworld
              pod-template-hash=b564cfb94
Annotations:  <none>
Status:       Pending
IP:           10.42.0.21
IPs:
  IP:           10.42.0.21
Controlled By:  ReplicaSet/bad-helloworld-deployment-b564cfb94
Containers:
  helloworld:
    Container ID:
    Image:          karthequian/unkown-pod:latest
    Image ID:
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-fbppq (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kube-api-access-fbppq:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  5m47s                  default-scheduler  Successfully assigned default/bad-helloworld-deployment-b564cfb94-24k2k to centos7k3s
  Normal   Pulling    4m9s (x4 over 5m47s)   kubelet            Pulling image "karthequian/unkown-pod:latest"
  Warning  Failed     4m6s (x4 over 5m44s)   kubelet            Failed to pull image "karthequian/unkown-pod:latest": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/karthequian/unkown-pod:latest": failed to resolve reference "docker.io/karthequian/unkown-pod:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
  Warning  Failed     4m6s (x4 over 5m44s)   kubelet            Error: ErrImagePull
  Warning  Failed     3m54s (x6 over 5m43s)  kubelet            Error: ImagePullBackOff
  Normal   BackOff    41s (x20 over 5m43s)   kubelet            Back-off pulling image "karthequian/unkown-pod:latest"
```


### checking pod logs

Not much here as the pod never started

```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl logs po/bad-helloworld-deployment-b564cfb94-24k2k
Error from server (BadRequest): container "helloworld" in pod "bad-helloworld-deployment-b564cfb94-24k2k" is waiting to start: trying and failing to pull image
```

this works but the not logs are empty
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl logs po/navbar-deployment-66db4977c8-dkhvq
[root@centos7k3s ~]# 
```

hmm not the best two exammple? Will improve

### shell script access: kubectl exec -it ... /bin/bash 

```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl exec -it  po/navbar-deployment-66db4977c8-dkhvq /bin/bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@navbar-deployment-66db4977c8-dkhvq:/# uptime
 20:53:10 up  1:19,  0 users,  load average: 0.27, 0.25, 0.24
root@navbar-deployment-66db4977c8-dkhvq:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var  www
root@navbar-deployment-66db4977c8-dkhvq:/# exit
exit
```



## More complex guestbook app with frontend and redis backend

```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl create -f /vagrant/guestbook.yaml
deployment.apps/redis-master created
service/redis-master created
deployment.apps/redis-slave created
service/redis-slave created
deployment.apps/frontend created
service/frontend created
```

but it didn't seem to startup
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl get all
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          13s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          13s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          13s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          13s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          13s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          13s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        2m46s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       13s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       13s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   13s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           13s
deployment.apps/redis-slave    0/2     2            0           13s
deployment.apps/frontend       0/3     3            0           13s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       13s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       13s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       13s
[root@centos7k3s ~]# for i in {1..10};do /usr/local/bin/k3s kubectl get all;sleep 10;done
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          44s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          44s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          44s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          44s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          44s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          44s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        3m17s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       44s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       44s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   44s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           44s
deployment.apps/redis-slave    0/2     2            0           44s
deployment.apps/frontend       0/3     3            0           44s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       44s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       44s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       44s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          54s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          54s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          54s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          54s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          54s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          54s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        3m27s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       54s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       54s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   54s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           54s
deployment.apps/redis-slave    0/2     2            0           54s
deployment.apps/frontend       0/3     3            0           54s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       54s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       54s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       54s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          65s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          65s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          65s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          65s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          65s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          65s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        3m38s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       65s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       65s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   65s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           65s
deployment.apps/redis-slave    0/2     2            0           65s
deployment.apps/frontend       0/3     3            0           65s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       65s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       65s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       65s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          75s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          75s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          75s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          75s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          75s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          75s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        3m48s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       75s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       75s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   75s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           75s
deployment.apps/redis-slave    0/2     2            0           75s
deployment.apps/frontend       0/3     3            0           75s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       75s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       75s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       75s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          86s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          86s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          86s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          86s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          86s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          86s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        3m59s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       86s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       86s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   86s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           86s
deployment.apps/redis-slave    0/2     2            0           86s
deployment.apps/frontend       0/3     3            0           86s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       86s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       86s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       86s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          96s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          96s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          96s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          96s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          96s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          96s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        4m9s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       96s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       96s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   96s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           96s
deployment.apps/redis-slave    0/2     2            0           96s
deployment.apps/frontend       0/3     3            0           96s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       96s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       96s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       96s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          106s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          106s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          106s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          106s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          106s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          106s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        4m19s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       106s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       106s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   106s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           106s
deployment.apps/redis-slave    0/2     2            0           106s
deployment.apps/frontend       0/3     3            0           106s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       106s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       106s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       106s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          117s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          117s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          117s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          117s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          117s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          117s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        4m30s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       117s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       117s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   117s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           117s
deployment.apps/redis-slave    0/2     2            0           117s
deployment.apps/frontend       0/3     3            0           117s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       117s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       117s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       117s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          2m7s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          2m7s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          2m7s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          2m7s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          2m7s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          2m7s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        4m40s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       2m7s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       2m7s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   2m7s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           2m7s
deployment.apps/redis-slave    0/2     2            0           2m7s
deployment.apps/frontend       0/3     3            0           2m7s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       2m7s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       2m7s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       2m7s
NAME                               READY   STATUS              RESTARTS   AGE
pod/redis-master-f46ff57fd-4k86l   0/1     ContainerCreating   0          2m18s
pod/redis-slave-bbc7f655d-cc692    0/1     ContainerCreating   0          2m18s
pod/redis-slave-bbc7f655d-tntk6    0/1     ContainerCreating   0          2m18s
pod/frontend-6c6d6dfd4d-7qhxc      0/1     ContainerCreating   0          2m18s
pod/frontend-6c6d6dfd4d-zxdrx      0/1     ContainerCreating   0          2m18s
pod/frontend-6c6d6dfd4d-265z6      0/1     ContainerCreating   0          2m18s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        4m51s
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       2m18s
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       2m18s
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   2m18s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   0/1     1            0           2m18s
deployment.apps/redis-slave    0/2     2            0           2m18s
deployment.apps/frontend       0/3     3            0           2m18s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-f46ff57fd   1         1         0       2m18s
replicaset.apps/redis-slave-bbc7f655d    2         2         0       2m18s
replicaset.apps/frontend-6c6d6dfd4d      3         3         0       2m18s
```
describe deployment frontend
```
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl describe deployment frontend
Name:                   frontend
Namespace:              default
CreationTimestamp:      Thu, 23 Dec 2021 20:42:25 +0000
Labels:                 app=guestbook
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=guestbook,tier=frontend
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=guestbook
           tier=frontend
  Containers:
   php-redis:
    Image:      gcr.io/google-samples/gb-frontend:v4
    Port:       80/TCP
    Host Port:  0/TCP
    Requests:
      cpu:     100m
      memory:  100Mi
    Environment:
      GET_HOSTS_FROM:  dns
    Mounts:            <none>
  Volumes:             <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   frontend-6c6d6dfd4d (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  8m18s  deployment-controller  Scaled up replica set frontend-6c6d6dfd4d to 3
```
describe deployment redis-master:
```  
[root@centos7k3s ~]# /usr/local/bin/k3s kubectl describe deployment redis-master
Name:                   redis-master
Namespace:              default
CreationTimestamp:      Thu, 23 Dec 2021 20:42:25 +0000
Labels:                 app=redis
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=redis,role=master,tier=backend
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=redis
           role=master
           tier=backend
  Containers:
   master:
    Image:      k8s.gcr.io/redis:e2e
    Port:       6379/TCP
    Host Port:  0/TCP
    Requests:
      cpu:        100m
      memory:     100Mi
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   redis-master-f46ff57fd (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  10m   deployment-controller  Scaled up replica set redis-master-f46ff57fd to 1
```

checking logs still in ContainerCreating
```
[root@centos7k3s ~]#  /usr/local/bin/k3s kubectl logs po/frontend-6c6d6dfd4d-7qhxc
Error from server (BadRequest): container "php-redis" in pod "frontend-6c6d6dfd4d-7qhxc" is waiting to start: ContainerCreating
```

but eventually it spring to life

```
[root@centos7k3s ~]# for i in {1..10};do /usr/local/bin/k3s kubectl get all;sleep 10;done
NAME                               READY   STATUS    RESTARTS   AGE
pod/redis-slave-bbc7f655d-cc692    1/1     Running   0          11m
pod/redis-slave-bbc7f655d-tntk6    1/1     Running   0          11m
pod/redis-master-f46ff57fd-4k86l   1/1     Running   0          11m
pod/frontend-6c6d6dfd4d-265z6      1/1     Running   0          11m
pod/frontend-6c6d6dfd4d-7qhxc      1/1     Running   0          11m
pod/frontend-6c6d6dfd4d-zxdrx      1/1     Running   0          11m

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        13m
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       11m
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       11m
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   11m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-slave    2/2     2            2           11m
deployment.apps/redis-master   1/1     1            1           11m
deployment.apps/frontend       3/3     3            3           11m

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-slave-bbc7f655d    2         2         2       11m
replicaset.apps/redis-master-f46ff57fd   1         1         1       11m
replicaset.apps/frontend-6c6d6dfd4d      3         3         3       11m
^C
[root@centos7k3s ~]#  /usr/local/bin/k3s kubectl logs po/frontend-6c6d6dfd4d-7qhxc
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.42.0.10. Set the 'ServerName' directive globally to suppress this message
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.42.0.10. Set the 'ServerName' directive globally to suppress this message
[Thu Dec 23 20:48:30.933595 2021] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.10 (Debian) PHP/5.6.20 configured -- resuming normal operations
[Thu Dec 23 20:48:30.933640 2021] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
[root@centos7k3s ~]#  /usr/local/bin/k3s kubectl logs po/redis-master-f46ff57fd-4k86l
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 2.8.19 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in stand alone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 1
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

[1] 23 Dec 20:48:15.607 # Server started, Redis version 2.8.19
[1] 23 Dec 20:48:15.610 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
[1] 23 Dec 20:48:15.611 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
[1] 23 Dec 20:48:15.611 * The server is now ready to accept connections on port 6379
[1] 23 Dec 20:49:02.743 * Slave 10.42.0.8:6379 asks for synchronization
[1] 23 Dec 20:49:02.743 * Full resync requested by slave 10.42.0.8:6379
[1] 23 Dec 20:49:02.743 * Starting BGSAVE for SYNC with target: disk
[1] 23 Dec 20:49:02.745 * Background saving started by pid 8
[8] 23 Dec 20:49:02.771 * DB saved on disk
[8] 23 Dec 20:49:02.772 * RDB: 0 MB of memory used by copy-on-write
[1] 23 Dec 20:49:02.822 * Background saving terminated with success
[1] 23 Dec 20:49:02.822 * Synchronization with slave 10.42.0.8:6379 succeeded
[1] 23 Dec 20:49:05.772 * Slave 10.42.0.9:6379 asks for synchronization
[1] 23 Dec 20:49:05.772 * Full resync requested by slave 10.42.0.9:6379
[1] 23 Dec 20:49:05.772 * Starting BGSAVE for SYNC with target: disk
[1] 23 Dec 20:49:05.772 * Background saving started by pid 9
[9] 23 Dec 20:49:05.784 * DB saved on disk
[9] 23 Dec 20:49:05.784 * RDB: 0 MB of memory used by copy-on-write
[1] 23 Dec 20:49:05.860 * Background saving terminated with success
[1] 23 Dec 20:49:05.861 * Synchronization with slave 10.42.0.9:6379 succeeded
```
