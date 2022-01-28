# cleanup

This from old exercises

```
[root@centos7k3s scripts]# /usr/local/bin/k3s kubectl get all
NAME                               READY   STATUS    RESTARTS      AGE
pod/redis-master-f46ff57fd-4k86l   1/1     Running   1 (23h ago)   35d
pod/frontend-6c6d6dfd4d-zxdrx      1/1     Running   1 (23h ago)   35d
pod/frontend-6c6d6dfd4d-265z6      1/1     Running   1 (23h ago)   35d
pod/redis-slave-bbc7f655d-cc692    1/1     Running   1 (23h ago)   35d
pod/redis-slave-bbc7f655d-tntk6    1/1     Running   1 (23h ago)   35d
pod/frontend-6c6d6dfd4d-7qhxc      1/1     Running   1 (23h ago)   35d

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        35d
service/redis-master   ClusterIP   10.43.39.159   <none>        6379/TCP       35d
service/redis-slave    ClusterIP   10.43.45.75    <none>        6379/TCP       35d
service/frontend       NodePort    10.43.103.23   <none>        80:30950/TCP   35d

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-slave    2/2     2            2           35d
deployment.apps/redis-master   1/1     1            1           35d
deployment.apps/frontend       3/3     3            3           35d

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-slave-bbc7f655d    2         2         2       35d
replicaset.apps/redis-master-f46ff57fd   1         1         1       35d
replicaset.apps/frontend-6c6d6dfd4d      3         3         3       35d
```

as per https://stackoverflow.com/questions/33509194/command-to-delete-all-pods-in-all-kubernetes-namespaces

> to get rid of them pesky replication controllers too.
```
kubectl delete daemonsets,replicasets,services,deployments,pods,rc --all
```

and this appears to work:
```
[root@centos7k3s scripts]# /usr/local/bin/k3s kubectl delete daemonsets,replicasets,services,deployments,pods,rc --all
replicaset.apps "redis-slave-bbc7f655d" deleted
replicaset.apps "redis-master-f46ff57fd" deleted
replicaset.apps "frontend-6c6d6dfd4d" deleted
service "kubernetes" deleted
service "redis-master" deleted
service "redis-slave" deleted
service "frontend" deleted
deployment.apps "frontend" deleted
deployment.apps "redis-slave" deleted
deployment.apps "redis-master" deleted
pod "frontend-6c6d6dfd4d-7qhxc" deleted
pod "frontend-6c6d6dfd4d-265z6" deleted
pod "frontend-6c6d6dfd4d-zxdrx" deleted
pod "redis-slave-bbc7f655d-tntk6" deleted
pod "redis-master-f46ff57fd-4k86l" deleted
pod "redis-slave-bbc7f655d-cc692" deleted
pod "redis-slave-bbc7f655d-qd56q" deleted
pod "frontend-6c6d6dfd4d-rcbqb" deleted
pod "frontend-6c6d6dfd4d-lrqft" deleted
pod "redis-slave-bbc7f655d-b6zxt" deleted
pod "frontend-6c6d6dfd4d-8t8db" deleted
pod "redis-master-f46ff57fd-5qcxh" deleted
```
roughly as expected
```
[root@centos7k3s scripts]# /usr/local/bin/k3s kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   77s
```
