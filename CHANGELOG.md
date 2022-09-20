# 0.13.5

Released 2022-09-20

- add `priorityClassName` value for both node DaemonSet and controller Deployment

# 0.13.4

Released 2022-08-07

- enabel options for hostPID, iscsiDirHostPath and iscsiDirHostPathType for [Talos](https://talos.dev) iscsi support.

# 0.13.0

Released 2022-06-06

- support for windows nodes

# 0.12.0

- include `app.kubernetes.io/csi-role` in matchLabels on Deployment and DaemonSet
  - requires `helm uninstall` and `helm install` to upgrade from older versions

# 0.11.2

- bump `csi-grpc-proxy` for multiarch support and memory fixes

# 0.10.11

- csiProxy support
- bump `node-driver-registrar`
- ensure proper mounts for `node-driver-registrar`
- enable liveness probe for `node-driver-registrar`

# 0.9.0

- minimum k8s version now 1.20
- csi version defaults to 1.5.0
- support for trusting custom CA certficates
- bump the sidecars
- remove support for deprecated `external-health-monitor-agent`

# 0.8.2

- support for pod annotations/labels
- explicit registry (docker.io) for relevant images

# 0.6.3

- api version support for csidriver

# 0.6.2

- arm friendly busybox image

# 0.6.1

- support for openshift privileged

# 0.6.0

- update various sidecar images
  - multiarch support natively!
  - requires k8s 1.17+
- support an `existingConfigSecret` to be created out-of-band from the helm release
