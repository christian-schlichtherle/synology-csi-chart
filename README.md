# Synology CSI Chart for Kubernetes

This is a
[Helm](https://helm.sh) chart for installing the
[Synology CSI Driver](https://github.com/SynologyOpenSource/synology-csi) in a
[Kubernetes](https://kubernetes.io) cluster.
It has been forked from the original resource manifests bundled with the Synology CSI Driver in order to resolve some
issues and to benefit from the advanced resource management features of Helm.

## Features

+ Customizable images, image pull policies and image tags for all CSI containers.
+ Customizable parameters for `StorageClass` and `VolumeSnapshotClass` resources.
+ Automatic installation of two storage classes with `reclaimPolicy=Delete` and `reclaimPolicy=Retain`.
+ Automatic installation of a CSI Snapshotter if the `VolumeSnapshotClass` CRD is installed in your cluster.

## TODO

+ Package Helm chart and upload to ArtifactHub.

## Prerequisites

+ A Synology Diskstation with the SAN Manager package installed (the package name was changed in DSM 7).
+ A cluster with [Kubernetes](https://kubernetes.io) version 1.19 or later.
+ `iscsiadm` installed on every cluster node.
+ `kubectl` installed on your localhost and configured to connect to the cluster.
+ Optional: [CSI Snapshotter](https://github.com/kubernetes-csi/external-snapshotter) installed in the cluster.

## Usage

Clone this repository and change into its directory.

### Editing the Configuration

Edit the file `values.yaml` and configure it to suit your requirements.
In particular, edit the section `connections` to match the connection parameters and credentials for accessing your
Synology Diskstation.
It's a good practice to create a dedicated user for accessing the Diskstation Manager (DSM) application.
Your user needs to be a member of the `administrator` group and have permission to access the `DSM` application.
You can reject any other permissions.

### Installing the Chart

You can run `helm install ...` as usual.
However, for convenience we recommend using the provided `Makefile` and run:

    $ make up

... or just:

    $ make

### Testing the Chart

The Synology CSI Driver is now ready to use.
You can monitor the SAN Manager application on your Synology Diskstation while running the following tests.

#### Automated Testing

    $ make test

#### Manual Testing

Setup:

    $ kubectl apply -f test.yaml

Test:

    $ kubectl exec iscsi-test -it -- /bin/sh
    # echo 'Hello world!' > /data/file
    # cat /data/file
    Hello world!
    # ls -l /data/file
    -rw-r--r-- 1 root root 13 Jan 24 11:25 /data/file
    # df -h /data
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda        974M   28K  958M   1% /data
    # lsblk
    NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda           8:0    0    1G  0 disk /data
    mmcblk0     179:0    0 59.5G  0 disk
    |-mmcblk0p1 179:1    0  256M  0 part
    `-mmcblk0p2 179:2    0 59.2G  0 part /etc/resolv.conf
    # exit

Teardown:

    $ kubectl delete -f test.yaml

### Uninstalling the Chart

    $ make down

---

**SUCCESS - enjoy!**
