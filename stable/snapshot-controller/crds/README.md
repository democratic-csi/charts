- https://github.com/kubernetes-csi/external-snapshotter/tree/v8.6.0/client/config/crd

```sh
for file in \
snapshot.storage.k8s.io_volumesnapshotclasses.yaml \
snapshot.storage.k8s.io_volumesnapshotcontents.yaml \
snapshot.storage.k8s.io_volumesnapshots.yaml \
groupsnapshot.storage.k8s.io_volumegroupsnapshots.yaml \
groupsnapshot.storage.k8s.io_volumegroupsnapshotcontents.yaml \
groupsnapshot.storage.k8s.io_volumegroupsnapshotclasses.yaml; \
do
  wget -O "${file}" "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/refs/tags/v8.6.0/client/config/crd/${file}"
done
```
