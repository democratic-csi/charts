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
