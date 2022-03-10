{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "democratic-csi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "democratic-csi.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "democratic-csi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "democratic-csi.mount-iscsi" -}}
{{- if contains "iscsi" .Values.driver.config.driver }}
{{- printf "%s" "true" -}}
{{- else }}
{{- printf "%s" "false" -}}
{{- end }}
{{- end -}}

{{- define "democratic-csi.external-attacher-container" -}}
{{- $root := . -}}
# https://github.com/kubernetes-csi/external-attacher
- name: external-attacher
  image: {{ .Values.controller.externalAttacher.image }}
  args:
  {{- range .Values.controller.externalAttacher.args }}
  - {{ tpl . $root }}
  {{- end }}
  {{- range .Values.controller.externalAttacher.extraArgs }}
  - {{ tpl . $root }}
  {{- end }}
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
{{- end -}}

{{- define "democratic-csi.external-provisioner-container" -}}
{{- $root := . -}}
# https://github.com/kubernetes-csi/external-provisioner
- name: external-provisioner
  image: {{ .Values.controller.externalProvisioner.image }}
  args:
  {{- range .Values.controller.externalProvisioner.args }}
  - {{ tpl . $root }}
  {{- end }}
  {{- range .Values.controller.externalProvisioner.extraArgs }}
  - {{ tpl . $root }}
  {{- end }}
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
  env:
  - name: NODE_NAME
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: spec.nodeName
  - name: NAMESPACE
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.namespace
  - name: POD_NAME
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.name
{{- end -}}


{{- define "democratic-csi.external-resizer-container" -}}
{{- $root := . -}}
# https://github.com/kubernetes-csi/external-resizer
- name: external-resizer
  image: {{ .Values.controller.externalResizer.image }}
  args:
  {{- range .Values.controller.externalResizer.args }}
  - {{ tpl . $root }}
  {{- end }}
  {{- range .Values.controller.externalResizer.extraArgs }}
  - {{ tpl . $root }}
  {{- end }}
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
  env:
  - name: NODE_NAME
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: spec.nodeName
  - name: NAMESPACE
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.namespace
  - name: POD_NAME
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.name
{{- end -}}

{{- define "democratic-csi.external-snapshotter-container" -}}
{{- $root := . -}}
# https://github.com/kubernetes-csi/external-snapshotter
# beware upgrading version:
#  - https://github.com/rook/rook/issues/4178
#  - https://github.com/kubernetes-csi/external-snapshotter/issues/147#issuecomment-513664310
- name: external-snapshotter
  image: {{ .Values.controller.externalSnapshotter.image }}
  args:
  {{- range .Values.controller.externalSnapshotter.args }}
  - {{ tpl . $root }}
  {{- end }}
  {{- range .Values.controller.externalSnapshotter.extraArgs }}
  - {{ tpl . $root }}
  {{- end }}
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
  env:
  - name: NODE_NAME
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: spec.nodeName
  - name: NAMESPACE
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.namespace
  - name: POD_NAME
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.name
{{- end -}}

{{- define "democratic-csi.external-health-monitor-controller" -}}
{{- $root := . -}}
# https://github.com/kubernetes-csi/external-health-monitor
- name: external-health-monitor-controller
  image: {{ .Values.controller.externalHealthMonitorController.image }}
  args:
  {{- range .Values.controller.externalHealthMonitorController.args }}
  - {{ tpl . $root }}
  {{- end }}
  {{- range .Values.controller.externalHealthMonitorController.extraArgs }}
  - {{ tpl . $root }}
  {{- end }}
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
{{- end -}}

{{- define "democratic-csi.csi-proxy" -}}
{{- $root := . -}}
- name: csi-proxy
  image: {{ .Values.csiProxy.image }}
  env:
  - name: BIND_TO
    value: "unix:///csi-data/csi.sock"
  - name: PROXY_TO
    value: "unix:///csi-data/csi.sock.internal"
  resources:
    limits:
      cpu: 10m
      memory: 20Mi
    requests:
      cpu: 2m
      memory: 12Mi
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
{{- end -}}

{{- define "democratic-csi.controller-rbac-rules" -}}
# Allow listing and creating CRDs
- apiGroups: ['apiextensions.k8s.io']
  resources: ['customresourcedefinitions']
  verbs: ['list', 'create']
- apiGroups: ['']
  resources: ['persistentvolumes']
  verbs: ['create', 'delete', 'get', 'list', 'watch', 'update', 'patch']
- apiGroups: ['']
  resources: ['secrets']
  verbs: ['get', 'list']
- apiGroups: ['']
  resources: ['pods']
  verbs: ['get', 'list', 'watch']
- apiGroups: ['']
  resources: ['persistentvolumeclaims']
  verbs: ['get', 'list', 'watch', 'update', 'patch']
- apiGroups: ['']
  resources: ['persistentvolumeclaims/status']
  verbs: ['get', 'list', 'watch', 'update', 'patch']
- apiGroups: ['']
  resources: ['nodes']
  verbs: ['get', 'list', 'watch']
- apiGroups: ['storage.k8s.io']
  resources: ['volumeattachments']
  verbs: ['get', 'list', 'watch', 'update', 'patch']
- apiGroups: ["storage.k8s.io"]
  resources: ["volumeattachments/status"]
  verbs: ["patch"]
- apiGroups: ['storage.k8s.io']
  resources: ['storageclasses']
  verbs: ['get', 'list', 'watch']
- apiGroups: ['csi.storage.k8s.io']
  resources: ['csidrivers']
  verbs: ['get', 'list', 'watch', 'update', 'create']
- apiGroups: ['']
  resources: ['events']
  verbs: ['list', 'watch', 'create', 'update', 'patch']
- apiGroups: ["snapshot.storage.k8s.io"]
  resources: ["volumesnapshotclasses"]
  verbs: ["get", "list", "watch"]
- apiGroups: ['snapshot.storage.k8s.io']
  resources: ['volumesnapshots/status']
  verbs: ["create", "get", "list", "watch", "update", "patch", "delete"]
- apiGroups: ["snapshot.storage.k8s.io"]
  resources: ["volumesnapshotcontents"]
  verbs: ["create", "get", "list", "watch", "update", "patch", "delete"]
- apiGroups: ["snapshot.storage.k8s.io"]
  resources: ["volumesnapshotcontents/status"]
  verbs: ["create", "get", "list", "watch", "update", "patch", "delete"]
- apiGroups: ["snapshot.storage.k8s.io"]
  resources: ["volumesnapshots"]
  verbs: ["create", "get", "list", "watch", "update", "patch", "delete"]
- apiGroups: ["storage.k8s.io"]
  resources: ["csinodes"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["csi.storage.k8s.io"]
  resources: ["csinodeinfos"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["coordination.k8s.io"]
  resources: ["leases"]
  verbs: ["get", "watch", "list", "delete", "update", "create"]
# capacity rbac
- apiGroups: ["storage.k8s.io"]
  resources: ["csistoragecapacities"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]
- apiGroups: ["apps"]
  resources: ["daemonsets", "deployments", "replicasets", "statefulsets"]
  verbs: ["get"]
{{- if .Values.controller.rbac.openshift.privileged }}
- apiGroups: ["security.openshift.io"]
  resources: ["securitycontextconstraints"]
  resourceNames: ["privileged"]
  verbs: ["use"]
{{- end }}

{{- end -}}

