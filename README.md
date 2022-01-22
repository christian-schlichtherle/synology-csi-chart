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
+ `kubectl` installed on your localhost and configured to connect to the cluster (e.g. using `apt install kubectl`).
+ `iscsiadm` installed on every cluster node (e.g. using `apt install open-iscsi`).
+ Optional: [CSI Snapshotter](https://github.com/kubernetes-csi/external-snapshotter) installed in the cluster.

## Usage

Clone this repository and change into its directory.

### Editing the Configuration

Edit the file `values.yaml` and configure it to suit your requirements.
In particular, edit the section `connections` to match the connection parameters and credentials for accessing your
Synology Diskstation.
It's a good practice to create a dedicated user for accessing the Diskstation Manager (DSM) application.
Your user needs to be a member of the `administrator` group and have permission to access the DSM application.
You can reject any other permissions.

### Installing the Chart

You can run `helm install ...` as usual.
However, for convenience we recommend using the provided `Makefile` and run:

    $ make up

... or just:

    $ make

### Uninstalling the Chart

    $ make down

### Testing the Chart

Your Synology CSI Driver is ready to use.
Monitor the SAN Manager application on your Synology Diskstation while doing the following steps.

Setup:

    $ kubectl apply -f test.yaml

Test:

    $ kubectl exec iscsi-test -it -- /bin/sh
    # echo 'Hello world!' > /data/file
    # cat /data/file
    Hello world!
    # exit

Teardown:

    $ kubectl delete -f test.yaml

**SUCCESS - enjoy!**
