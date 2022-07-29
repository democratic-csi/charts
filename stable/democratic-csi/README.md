# democratic-csi

[democratic-csi](https://github.com/democratic-csi/democratic-csi) implements
the [csi](https://github.com/container-storage-interface/spec/blob/master/spec.md)
spec to facilitate stateful workloads.

Currently `democratic-csi` integrates with the following storage systems:

- [TrueNAS](https://www.truenas.com)
- ZFS on Linux (ZoL, ie: generic Ubuntu server)
- [Synology](https://www.synology.com)
- generic `nfs`, `smb`, and `iscsi` servers
- local storage directly on nodes

# usage

```
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update

if using k8s < 1.17 please use chart version 0.5.0
```

# links

- https://github.com/democratic-csi/democratic-csi
- https://github.com/democratic-csi/charts
- https://github.com/container-storage-interface/spec
- https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/

