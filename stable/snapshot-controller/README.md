# snapshot-controller

[Snapshot Controller](https://kubernetes-csi.github.io/docs/snapshot-controller.html)
is a `csi` component that should be installed once per cluster to enable
snapshot support for all `csi` drivers.

# usage

```
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update

helm upgrade --install --namespace kube-system --create-namespace snapshot-controller democratic-csi/snapshot-controller
kubectl -n kube-system logs -f -l app=snapshot-controller
```

To use experimental volume group snapshot enable the feature gate on the controller:

```
controller:
  extraArgs:
  - --feature-gates=CSIVolumeGroupSnapshot=true
```

You must also enable the feature gate on the csi-snapshotter sidecar: https://github.com/democratic-csi/charts/blob/525b3be495dffa79e01dece6ef2aa9215f475924/stable/democratic-csi/values.yaml#L142

```
controller:
  externalSnapshotter:
    extraArgs:
    - --feature-gates=CSIVolumeGroupSnapshot=true
```

# development

```
# get latest crds
# https://github.com/kubernetes-csi/external-snapshotter/tree/master/client/config/crd
cd crds
for file in snapshot.storage.k8s.io_volumesnapshotclasses.yaml snapshot.storage.k8s.io_volumesnapshotcontents.yaml snapshot.storage.k8s.io_volumesnapshots.yaml; do
  wget -O "${file}" "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/${file}"
done

helm template --namespace kube-system snapshot-controller .
```

# links

- https://kubernetes-csi.github.io/docs/snapshot-controller.html
- https://github.com/kubernetes-csi/external-snapshotter
- https://github.com/kubernetes-csi/external-snapshotter/tree/master/deploy/kubernetes/webhook-example
- https://github.com/kubernetes-csi/external-snapshotter/tree/master/deploy/kubernetes/snapshot-controller
- https://github.com/kubernetes-csi/external-snapshotter/tree/master/client/config/crd

