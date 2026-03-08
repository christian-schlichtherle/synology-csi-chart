# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Helm chart for the [Synology CSI Driver](https://github.com/SynologyOpenSource/synology-csi) — deploys the CSI driver into Kubernetes to provision iSCSI, NFS, and SMB volumes on a Synology Diskstation. Forked from the upstream resource manifests to add Helm templating and customization.

## Common Commands

```bash
make                # helm upgrade --install (default target)
make up             # same as above
make down           # helm uninstall
make template       # render templates locally (dry-run)
make diff           # diff against deployed release (requires helm-diff plugin)
make test           # run helm test (creates PVCs + fio pods for storage classes with test: true)
make dist           # package chart + build repo index for GitHub Pages release
```

All make targets use `NAMESPACE=synology-csi` and `RELEASE=$(NAMESPACE)` by default. Override with `NAMESPACE=foo make up`. The Makefile merges `.values.yaml` (gitignored local overrides) via `--values .values.yaml`; `custom.yaml` is also gitignored.

## Architecture

### Workloads (3 components, each with its own ServiceAccount + ClusterRole + ClusterRoleBinding)

- **controller** (`controller.yaml`): StatefulSet running csi-provisioner, csi-attacher, csi-resizer, and the Synology csi-plugin. Handles volume create/delete/attach/resize.
- **node** (`node.yaml`): DaemonSet running csi-node-driver-registrar and csi-plugin with host mounts. Handles volume mount/unmount on each node. Supports configurable `kubeletPath` and `plugin.extraArgs` (e.g., for Talos Linux `--iscsiadm-path`).
- **snapshotter** (`snapshotter.yaml`): StatefulSet running csi-snapshotter and csi-plugin. Only deployed when the `VolumeSnapshotClass` CRD exists in the cluster (`$.Capabilities.APIVersions.Has` guard).

### Resources

- **secret.yaml**: Creates `client-info` and `smb-user` secrets only on install when `create: true`. The client-info secret holds DSM connection credentials.
- **storage-class.yaml**: Iterates over `storageClasses` map in values. Automatically wires SMB secret refs when `protocol: smb`.
- **volume-snapshot-class.yaml**: Iterates over `volumeSnapshotClasses` map. Also guarded by VolumeSnapshotClass CRD presence.
- **csidriver.yaml**: Registers the `csi.san.synology.com` CSIDriver. Controlled by `installCSIDriver` flag.
- **test.yaml**: Helm test hook — for each storage class with `test: true`, creates a PVC + Pod running fio benchmarks.
- **_helpers.tpl**: Standard Helm helpers (name, fullname, labels, selectorLabels) plus `clientInfoSecretVolume` helper.

### Image Configuration

All sidecar images (attacher, provisioner, resizer, snapshotter, nodeDriverRegistrar) and the main plugin image are independently configurable under `images.*` in values.yaml. The plugin image tag defaults to `Chart.AppVersion`.

## Release Process

Pushing a semver tag (`v*.*.*`) triggers `.github/workflows/release.yaml`, which packages the chart and publishes to GitHub Pages via `gh-pages` branch.

## Key Conventions

- Chart version in `Chart.yaml` uses `-SNAPSHOT` suffix during development
- Templates use `{{- with $.Values }}` at the top level, then scope into sub-sections
- Selector labels include `helm.sh/template` for identifying resources by source template
- All workloads run with `hostNetwork: true` and privileged security contexts (CSI driver requirement)
- The `fio/` directory contains the Dockerfile and config for the test benchmark image (`christianschlichtherle/fio`)