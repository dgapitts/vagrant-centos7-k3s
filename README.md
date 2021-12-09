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

To change label `helloworld` to `helloworld-demo`
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


