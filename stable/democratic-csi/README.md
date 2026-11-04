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

## Credentials from kubernetes Secrets

The configuration under `driver.config` is able to read from environment variables, which makes it possible to load credentials from other sources instead of inline in the config.

The below example is for SSH, but this can be for any credential mentioned under `driver.config`.


### 1. Generate an SSH key and save it to a Kubernetes Secret

First we generate a new SSH key (we use an empty `echo` to disable setting a password).

```console
$ echo '' | ssh-keygen -f ./ssh-key
Generating public/private ed25519 key pair.
Your identification has been saved in ssh-key
Your public key has been saved in ssh-key.pub
The key fingerprint is:
SHA256:E70Ws7U1qjMSvBw8zEjejtolBO465Vrh59BBxu/XB3Y user@hostname
The key's randomart image is:
+--[ED25519 256]--+
|                 |
|     .   .       |
|    . = . + . o  |
|   . * O . * + . |
|    o = S + = E  |
|   o.+ * B + o   |
|   o= = B = . .  |
|  .o.* o o o .   |
|  oo. o          |
+----[SHA256]-----+
```

Then we save it in the kubernetes `Secret/ssh-key`
```console
$ kubectl create secret generic ssh-key --from-file=ssh-key=./ssh-key
secret/ssh-key created
```
Remove ssh private key from disk to make sure we do not add it to git
```console
$ rm ssh-key
```
### 2. Update configuration to use the new secret

```yaml
node:
  driver:
    extraEnv:
      - name: SSH_PRIVATE_KEY
        valueFrom:
          secretKeyRef:
            name: ssh-key
            key: ssh-key
controller:
  driver:
    extraEnv:
      - name: SSH_PRIVATE_KEY
        valueFrom:
          secretKeyRef:
            name: ssh-key
            key: ssh-key

driver:
  config:
    driver: your-driver-name  # e.g. zfs-generic-nvmeof
    # ...
    sshConnection:
      # ...
      privateKey: "${SSH_PRIVATE_KEY}"
```

### 3. Update credential on other side

You also need to update the credential on the service you are trying to connect to.

So for SSH, add the public key to the authorized_keys for the user mentioned at `driver.config.sshConnection.username`.

# links

- https://github.com/democratic-csi/democratic-csi
- https://github.com/democratic-csi/charts
- https://github.com/container-storage-interface/spec
- https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/

