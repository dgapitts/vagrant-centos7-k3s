
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
