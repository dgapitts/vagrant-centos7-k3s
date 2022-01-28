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


