# Kubernetes Essential Training: Application Development

After downloading the files from linkedin:

```
~/projects/vagrant-centos7-k3s $ cp ~/Downloads/Ex_Files_Kubernetes_EssT_App_Dev.zip .
~/projects/vagrant-centos7-k3s $ vagrant reload
==> default: Attempting graceful shutdown of VM...
==> default: Clearing any previously set forwarded ports...
```

and now back inside the VM, unpack the files and give them a more reasonable path 


```
yum install -y unzip
unzip Ex_Files_Kubernetes_EssT_App_Dev.zip
mv Ex_Files_Kubernetes_EssT_App_Dev mt  
cd mt/
mv Exercise\ Files/ ex
```

I choose mt for Matt Turner (course author)

Starting with the exercise/demo files

```
[root@centos7k3s 01_03]# pwd
/vagrant/mt/ex/01_03
[root@centos7k3s 01_03]# ls
blue-green.yaml  blue.yaml  green.yaml
[root@centos7k3s 01_03]# head -50 *
==> blue-green.yaml <==
apiVersion: v1
kind: Service
metadata:
  name: blue-green
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: blue-green

==> blue.yaml <==
apiVersion: v1
kind: Pod
metadata:
  name: blue
  labels:
    app: blue-green
spec:
  containers:
    - name: blue
      image: docker.io/mtinside/blue-green:blue

==> green.yaml <==
apiVersion: v1
kind: Pod
metadata:
  name: green
  labels:
    app: blue-green
spec:
  containers:
    - name: green
      image: docker.io/mtinside/blue-green:green
```

and apply these the pods and new service come up cleanly
```
[root@centos7k3s 01_03]# /usr/local/bin/k3s kubectl apply -f .
service/blue-green created
pod/blue created
pod/green created
[root@centos7k3s 01_03]# /usr/local/bin/k3s kubectl get pods
NAME    READY   STATUS             RESTARTS      AGE
green   0/1     CrashLoopBackOff   1 (11s ago)   16s
blue    0/1     CrashLoopBackOff   1 (11s ago)   16s
[root@centos7k3s 01_03]# /usr/local/bin/k3s kubectl get services
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP   34m
blue-green   ClusterIP   10.43.165.47   <none>        80/TCP    26s
```

Here are the service details 
```
[root@centos7k3s 01_03]# /usr/local/bin/k3s kubectl describe services
Name:              kubernetes
Namespace:         default
Labels:            component=apiserver
                   provider=kubernetes
Annotations:       <none>
Selector:          <none>
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.43.0.1
IPs:               10.43.0.1
Port:              https  443/TCP
TargetPort:        6443/TCP
Endpoints:         10.0.2.15:6443
Session Affinity:  None
Events:            <none>


Name:              blue-green
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=blue-green
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.43.165.47
IPs:               10.43.165.47
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:
Session Affinity:  None
Events:            <none>
```

Here are the pods details 
```
[root@centos7k3s 01_03]# /usr/local/bin/k3s kubectl describe pods
Name:             blue
Namespace:        default
Priority:         0
Service Account:  default
Node:             centos7k3s/10.0.2.15
Start Time:       Tue, 07 Nov 2023 21:38:23 +0000
Labels:           app=blue-green
Annotations:      <none>
Status:           Running
IP:               10.42.0.14
IPs:
  IP:  10.42.0.14
Containers:
  blue:
    Container ID:   containerd://cb393f1b38bb8b4b3177b33cd5f0993fb3debcb4af2e56394b0ce68e99424261
    Image:          docker.io/mtinside/blue-green:blue
    Image ID:       docker.io/mtinside/blue-green@sha256:5fb83f49dd7001591fb1591a0d74596bf8264e527702dc78c0a06651fffd0c60
    Port:           <none>
    Host Port:      <none>
    State:          Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Tue, 07 Nov 2023 21:39:07 +0000
      Finished:     Tue, 07 Nov 2023 21:39:07 +0000
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Tue, 07 Nov 2023 21:38:42 +0000
      Finished:     Tue, 07 Nov 2023 21:38:42 +0000
    Ready:          False
    Restart Count:  3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mrdcz (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kube-api-access-mrdcz:
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
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  49s               default-scheduler  Successfully assigned default/blue to centos7k3s
  Normal   Pulling    48s               kubelet            Pulling image "docker.io/mtinside/blue-green:blue"
  Normal   Pulled     45s               kubelet            Successfully pulled image "docker.io/mtinside/blue-green:blue" in 3.469849938s (3.469863816s including waiting)
  Normal   Pulled     6s (x3 over 44s)  kubelet            Container image "docker.io/mtinside/blue-green:blue" already present on machine
  Normal   Created    6s (x4 over 45s)  kubelet            Created container blue
  Normal   Started    5s (x4 over 45s)  kubelet            Started container blue
  Warning  BackOff    5s (x5 over 43s)  kubelet            Back-off restarting failed container blue in pod blue_default(979b1434-0bbc-4bc2-8baf-6adc56045d6e)


Name:             green
Namespace:        default
Priority:         0
Service Account:  default
Node:             centos7k3s/10.0.2.15
Start Time:       Tue, 07 Nov 2023 21:38:23 +0000
Labels:           app=blue-green
Annotations:      <none>
Status:           Running
IP:               10.42.0.15
IPs:
  IP:  10.42.0.15
Containers:
  green:
    Container ID:   containerd://abb4d90a7951fffac5406666604a3112c7b97a32bc3c6e8fe2b3803cfefde849
    Image:          docker.io/mtinside/blue-green:green
    Image ID:       docker.io/mtinside/blue-green@sha256:b42b5a28c7118a3eda2f25703605c1fe88221d45645a6cbcdc04003dc6ee7798
    Port:           <none>
    Host Port:      <none>
    State:          Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Tue, 07 Nov 2023 21:39:08 +0000
      Finished:     Tue, 07 Nov 2023 21:39:08 +0000
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Tue, 07 Nov 2023 21:38:42 +0000
      Finished:     Tue, 07 Nov 2023 21:38:42 +0000
    Ready:          False
    Restart Count:  3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-2smtq (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kube-api-access-2smtq:
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
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  49s               default-scheduler  Successfully assigned default/green to centos7k3s
  Normal   Pulling    48s               kubelet            Pulling image "docker.io/mtinside/blue-green:green"
  Normal   Pulled     45s               kubelet            Successfully pulled image "docker.io/mtinside/blue-green:green" in 3.436985971s (3.437003656s including waiting)
  Normal   Pulled     4s (x3 over 45s)  kubelet            Container image "docker.io/mtinside/blue-green:green" already present on machine
  Normal   Created    4s (x4 over 45s)  kubelet            Created container green
  Normal   Started    4s (x4 over 45s)  kubelet            Started container green
  Warning  BackOff    3s (x5 over 43s)  kubelet            Back-off restarting failed container green in pod green_default(d7843f45-762f-4a06-922a-8a6278d3da9c)
```





