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

{{- define "democratic-csi.external-provisioner-container" -}}
# https://github.com/kubernetes-csi/external-provisioner
- name: external-provisioner
  image: {{ .Values.controller.externalProvisioner.image }}
  args:
  - --v=5
  - --leader-election
  - --leader-election-namespace={{ .Release.Namespace }}
  - --timeout=90s
  - --worker-threads=10
  - --extra-create-metadata
  - --csi-address=/csi-data/csi.sock
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
{{- end -}}


{{- define "democratic-csi.external-resizer-container" -}}
# https://github.com/kubernetes-csi/external-resizer
- name: external-resizer
  image: {{ .Values.controller.externalResizer.image }}
  args:
  - --v=5
  - --leader-election
  - --leader-election-namespace={{ .Release.Namespace }}
  - --timeout=90s
  - --workers=10
  - --csi-address=/csi-data/csi.sock
  volumeMounts:
  - mountPath: /csi-data
    name: socket-dir
{{- end -}}

{{- define "democratic-csi.external-snapshotter-container" -}}
# https://github.com/kubernetes-csi/external-snapshotter
# beware upgrading version:
#  - https://github.com/rook/rook/issues/4178
#  - https://github.com/kubernetes-csi/external-snapshotter/issues/147#issuecomment-513664310
- name: external-snapshotter
  image: {{ .Values.controller.externalSnapshotter.image }}
  args:
  - --v=5
  - --leader-election
  - --leader-election-namespace={{ .Release.Namespace }}
  - --timeout=90s
  - --worker-threads=10
  - --csi-address=/csi-data/csi.sock
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
  verbs: ['get', 'list', 'watch', 'update']
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
- apiGroups: ["csi.storage.k8s.io"]
  resources: ["csinodeinfos"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["coordination.k8s.io"]
  resources: ["leases"]
  verbs: ["get", "watch", "list", "delete", "update", "create"]
{{- end -}}

