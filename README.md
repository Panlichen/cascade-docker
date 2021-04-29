[toc]

# Install OFED software stack on the host machines

Choose proper OFED version according to your hardware(RoCE NIC or Infiniband HCA).

In our particular case(Mellanox ConnectX-4 Lx), we use 5.3-1.0.0.1:

```shell
export MOFED_VER=5.3-1.0.0.1
export OS_VER=ubuntu18.04
export PLATFORM=x86_64

wget http://content.mellanox.com/ofed/MLNX_OFED-$MOFED_VER/MLNX_OFED_LINUX-$MOFED_VER-$OS_VER-$PLATFORM.iso
sudo mount -o ro,loop MLNX_OFED_LINUX-$MOFED_VER-$OS_VER-$PLATFORM.iso /mnt
sudo /mnt/mlnxofedinstall --force

sudo reboot now
```

- According to the [doc](https://docs.mellanox.com/display/MLNXOFEDv531001/Installing+Mellanox+OFED#InstallingMellanoxOFED-InstallationProcedure), do not use `--add-kernel-support` option on Ubuntu and Debian distributions.

After installing, you should test via `ib_send_bw`, etc.

# Work with docker

Install Docker with version v19.03.

## Build images for cascade

Build image with OFED user-space librarys compatible to OFED stack on your host machine(5.3-1.0.0.1 here):

```shell
cd <path-to-this-project>
cd dockerfile
[sudo] docker build -f Dockerfile.ubuntu18.04.mofed-5.3 -t <tag> .
```

- Now this image is pushed as `poanpan/mlnx_ofed_linux-5.3-1.0.0.1-ubuntu18.04`

Build image with prerequisites for derecho and cascade, as well as the master branch for derecho and cascade:

```
cd <path-to-this-project>
cd dockerfile
[sudo] docker build -f Dockerfile -t <tag> .
```

- Now this image is pushed as `poanpan/cascade:master`

Before running cascade, we strongly suggest you rebuild the image with up-to-date cascade branch:

```shell
[sudo] docker build -f Dockerfile.upgrade-cascade --build-arg CASCADE_BRANCH=<branch> -t <tag> .
```

## Test cascade inside a single machine with docker container

We do this by inserting VFs created by SRIOV to containers.

For instructions on how to use Docker with SR-IOV, refer to [Docker RDMA SRIOV Networking with ConnectX4/ConnectX5/ConnectX6](https://community.mellanox.com/s/article/Docker-RDMA-SRIOV-Networking-with-ConnectX4-ConnectX5-ConnectX6) Community post.

- You can start from step 4.
- In step 8, use images built in the previous session.

# Work with Kubernetes.

Install golang.

- For now, golang version does not matter much. We use 1.16.3, FYI.

Install Kubernetes v1.17.4 cluster.

- Before installing, you may need:

  ```shell
  sudo swapoff -a
  sudo sysctl -w vm.overcommit_memory=1
  ```

Install default CNI plugin for your cluster, so that all nodes are `Ready`.

- Flannel, Calico, Cilium, or other plugins will all be OK, we use Flannel here.

Untaint and label your nodes:

```shell
kubectl taint node <the-master-node> node-role.kubernetes.io/master-
kubectl label node/<node-0> node-role.kubernetes.io/worker= beta.kubernetes.io/os=linux feature.node.kubernetes.io/network-sriov.capable=true --overwrite
kubectl label node/<node-1> node-role.kubernetes.io/worker= beta.kubernetes.io/os=linux feature.node.kubernetes.io/network-sriov.capable=true --overwrite
...
```

## Enable VF usage in containers managed by Kubernetes

> [nokia/danm](https://github.com/nokia/danm) is another mechanism to do so.

Install secondary CNI plugin:

```shell
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/images/multus-daemonset.yml
kubectl apply -f <path-to-this-repo>/whereabouts-install-test/whereabouts.cni.cncf.io_ippools.yaml -f /users/Poanpan/mydata/cascade-docker/whereabouts-install-test/daemonset-install.yaml
```

- multus-cni helps us to allocate IP for the VF inserted to a container; whereabouts helps us manage those IPs cluster-wise as an IP Address Manager.

Deploy [sriov-network-operator](https://github.com/k8snetworkplumbingwg/sriov-network-operator.git).

- We choose deploy it in the `default` namespace, instead of the `sriov-network-operator` namespace.

Create and configure VFs on all machines:

```shell
kubectl apply -f <path-to-this-repo>/sriov-network-operator/sriov-network-node-policy.yaml
```

- After this, you should see VF info on each node:

  ```shell
  kubectl get sriovnetworknodestates.sriovnetwork.openshift.io <node-name> -o yaml
  ```

  should print a yaml like(we just list important domain here):

  ```yaml
  apiVersion: sriovnetwork.openshift.io/v1
  kind: SriovNetworkNodeState
  metadata:
  	name: <node-name>
    ...
  spec:
    ...
  status:
    interfaces:
    - <list for PFs>
    - Vfs:
      - deviceID: "<deviceID>"
        driver: mlx5_core
        mac: <mac>
        mtu: <mtu>
        name: <iface name>
        pciAddress: "<pciAddress>"
        vendor: <vendor>
        vfID: 0
      - ...
      - deviceID: "<deviceID>"
        driver: mlx5_core
        mac: <mac>
        mtu: <mtu>
        name: <iface name>
        pciAddress: "<pciAddress>"
        vendor: <vendor>
        vfID: 7
      - ...
     	<other info>
    syncStatus: Succeeded
  ```

- You should also see a new kind of allocatable resource (VF) for each node:

  ```shell
  $ kubectl get no -o json | jq -r '[.items[] | {name:.metadata.name, allocable:.status.allocatable}]'
  ```

  should print allocatable resource for each node, with VF:

  ```json
  [
    {
      "name": "<node-0>",
      "allocable": {
        "cpu": "...",
        "ephemeral-storage": "...",
        "hugepages-1Gi": "0",
        "hugepages-2Mi": "0",
        "memory": "...",
        "openshift.io/mlx5_vf": "8",
        "pods": "110"
      }
    },
    {
      "name": "<node-1>",
      "allocable": {
        ...
      }
    },
    ...
  ]
  ```

  - We configure the resource prefix and name as "openshift.io" and "mlx5_vf" respectively when deploying sriov-network-operator.

## Run containers(pods) and allocate VF into them

Create sriov-network CR:

```shell
kubectl apply -f <path-to-this-repo>/sriov-network-operator/sriov-network.yaml
```

Deploy cascade containers:

```shell
kubectl apply -f <path-to-this-repo>/cascade-deploy/cascade-deploy.yaml
```

Now you can attach every cascade container via `kubectl exec`, where you get a VF CA name by `ibv_devices`. For example:

```shell
$ kubectl exec -it  cascade-deploy-79779f66bd-lsxj9 -- /bin/bash
root@cascade-deploy-79779f66bd-lsxj9:~# ibv_devices
    device                 node GUID
    ------              ----------------
    mlx5_10             e2b239fffe173d23
root@cascade-deploy-79779f66bd-lsxj9:~#
```

Now you can edit the derecho.cfg and run cascade applications.

> Inside the container, the path to cascade dir is `/root/cascade`.[toc]

# Install OFED software stack on the host machines

Choose proper OFED version according to your hardware(RoCE NIC or Infiniband HCA).

In our particular case(Mellanox ConnectX-4 Lx), we use 5.3-1.0.0.1:

```shell
export MOFED_VER=5.3-1.0.0.1
export OS_VER=ubuntu18.04
export PLATFORM=x86_64

wget http://content.mellanox.com/ofed/MLNX_OFED-$MOFED_VER/MLNX_OFED_LINUX-$MOFED_VER-$OS_VER-$PLATFORM.iso
sudo mount -o ro,loop MLNX_OFED_LINUX-$MOFED_VER-$OS_VER-$PLATFORM.iso /mnt
sudo /mnt/mlnxofedinstall --force

sudo reboot now
```

- According to the [doc](https://docs.mellanox.com/display/MLNXOFEDv531001/Installing+Mellanox+OFED#InstallingMellanoxOFED-InstallationProcedure), do not use `--add-kernel-support` option on Ubuntu and Debian distributions.

After installing, you should test via `ib_send_bw`, etc.

# Work with docker

Install Docker with version v19.03.

## Build images for cascade

Build image with OFED user-space librarys compatible to OFED stack on your host machine(5.3-1.0.0.1 here):

```shell
cd <path-to-this-project>
cd dockerfile
[sudo] docker build -f Dockerfile.ubuntu18.04.mofed-5.3 -t <tag> .
```

- Now this image is pushed as `poanpan/mlnx_ofed_linux-5.3-1.0.0.1-ubuntu18.04`

Build image with prerequisites for derecho and cascade, as well as the master branch for derecho and cascade:

```
cd <path-to-this-project>
cd dockerfile
[sudo] docker build -f Dockerfile -t <tag> .
```

- Now this image is pushed as `poanpan/cascade:master`

Before running cascade, we strongly suggest you rebuild the image with up-to-date cascade branch:

```shell
[sudo] docker build -f Dockerfile.upgrade-cascade --build-arg CASCADE_BRANCH=<branch> -t <tag> .
```

## Test cascade inside a single machine with docker container

We do this by inserting VFs created by SRIOV to containers.

For instructions on how to use Docker with SR-IOV, refer to [Docker RDMA SRIOV Networking with ConnectX4/ConnectX5/ConnectX6](https://community.mellanox.com/s/article/Docker-RDMA-SRIOV-Networking-with-ConnectX4-ConnectX5-ConnectX6) Community post.

- You can start from step 4.
- In step 8, use images built in the previous session.

# Work with Kubernetes.

Install golang.

- For now, golang version does not matter much. We use 1.16.3, FYI.

Install Kubernetes v1.17.4 cluster.

- Before installing, you may need:

  ```shell
  sudo swapoff -a
  sudo sysctl -w vm.overcommit_memory=1
  ```

Install default CNI plugin for your cluster, so that all nodes are `Ready`.

- Flannel, Calico, Cilium, or other plugins will all be OK, we use Flannel here.

Untaint and label your nodes:

```shell
kubectl taint node <the-master-node> node-role.kubernetes.io/master-
kubectl label node/<node-0> node-role.kubernetes.io/worker= beta.kubernetes.io/os=linux feature.node.kubernetes.io/network-sriov.capable=true --overwrite
kubectl label node/<node-1> node-role.kubernetes.io/worker= beta.kubernetes.io/os=linux feature.node.kubernetes.io/network-sriov.capable=true --overwrite
...
```

## Enable VF usage in containers managed by Kubernetes

> [nokia/danm](https://github.com/nokia/danm) is another mechanism to do so.

Install secondary CNI plugin:

```shell
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/images/multus-daemonset.yml
kubectl apply -f <path-to-this-repo>/whereabouts-install-test/whereabouts.cni.cncf.io_ippools.yaml -f /users/Poanpan/mydata/cascade-docker/whereabouts-install-test/daemonset-install.yaml
```

- multus-cni helps us to allocate IP for the VF inserted to a container; whereabouts helps us manage those IPs cluster-wise as an IP Address Manager.

Deploy [sriov-network-operator](https://github.com/k8snetworkplumbingwg/sriov-network-operator.git).

- We choose deploy it in the `default` namespace, instead of the `sriov-network-operator` namespace.

Create and configure VFs on all machines:

```shell
kubectl apply -f <path-to-this-repo>/sriov-network-operator/sriov-network-node-policy.yaml
```

- After this, you should see VF info on each node:

  ```shell
  kubectl get sriovnetworknodestates.sriovnetwork.openshift.io <node-name> -o yaml
  ```

  should print a yaml like(we just list important domain here):

  ```yaml
  apiVersion: sriovnetwork.openshift.io/v1
  kind: SriovNetworkNodeState
  metadata:
  	name: <node-name>
    ...
  spec:
    ...
  status:
    interfaces:
    - <list for PFs>
    - Vfs:
      - deviceID: "<deviceID>"
        driver: mlx5_core
        mac: <mac>
        mtu: <mtu>
        name: <iface name>
        pciAddress: "<pciAddress>"
        vendor: <vendor>
        vfID: 0
      - ...
      - deviceID: "<deviceID>"
        driver: mlx5_core
        mac: <mac>
        mtu: <mtu>
        name: <iface name>
        pciAddress: "<pciAddress>"
        vendor: <vendor>
        vfID: 7
      - ...
     	<other info>
    syncStatus: Succeeded
  ```

- You should also see a new kind of allocatable resource (VF) for each node:

  ```shell
  $ kubectl get no -o json | jq -r '[.items[] | {name:.metadata.name, allocable:.status.allocatable}]'
  ```

  should print allocatable resource for each node, with VF:

  ```json
  [
    {
      "name": "<node-0>",
      "allocable": {
        "cpu": "...",
        "ephemeral-storage": "...",
        "hugepages-1Gi": "0",
        "hugepages-2Mi": "0",
        "memory": "...",
        "openshift.io/mlx5_vf": "8",
        "pods": "110"
      }
    },
    {
      "name": "<node-1>",
      "allocable": {
        ...
      }
    },
    ...
  ]
  ```

  - We configure the resource prefix and name as "openshift.io" and "mlx5_vf" respectively when deploying sriov-network-operator.

## Run containers(pods), allocate VF into them, and configure derecho.cfg automatically

Create sriov-network CR:

```shell
kubectl apply -f <path-to-this-repo>/sriov-network-operator/sriov-network.yaml
```

For different applications, details about `derecho.cfg` may be different, thus we need to mount `derecho.cfg.template` to the container when it's launched via configMap.

```shell
kubectl apply -f <path-to-this-repo>/cascade-deploy/cascade-datapath-cmap.yaml
```

> If you need different derecho.cfg.template, create your configMap and edit `configMap.name` in cascade-deploy.yaml accordingly.

Deploy cascade pods:

```shell
kubectl apply -f <path-to-this-repo>/cascade-deploy/cascade-deploy.yaml
```

Now you can attach every cascade container via `kubectl exec`, where you get a VF CA name by `ibv_devices`. For example:

```shell
$ kubectl exec -it  cascade-deploy-79779f66bd-lsxj9 -- /bin/bash
root@cascade-deploy-79779f66bd-lsxj9:~# ibv_devices
    device                 node GUID
    ------              ----------------
    mlx5_10             e2b239fffe173d23
root@cascade-deploy-79779f66bd-lsxj9:~#
```


After cascade-deploy.yaml is deployed, just run `<path-to-this-repo>/cascade-deploy/config-cascade-pods.sh` and you can get `/root/derecho.cfg` inside the contaienr with `leader_ip`, `domain`, etc. configured properly.

> The `DERECHO_CONF_FILE` environment variable is set as `/root/derecho.cfg` in Dockerfiles.

Now you are free to run your cascade applications.
>  Inside the container, the path to cascade dir is `/root/cascade`.




