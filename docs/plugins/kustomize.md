---
layout: wmt/docs
title:  Kustomize Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports running the
[kustomize](https://github.com/kubernetes-sigs/kustomize#kustomize)
command line tool for working with Kubernetes clusters with the `kustomize`
task. Kustomize works by transforming the kustomize files and then applying them
to the cluster with `kubectl`.

The `kustomize` task is available as part of the [`kube` plugin](./kubectl.html),
which includes the helm binary - __kustomize v1.0.8__.

- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)

## Usage

To be able to use the `kustomize` task in a Concord flow, the
[`kube` plugin must be added as a dependency](./kubectl.html#usage).

The `kustomize` task only supports the two actions
[apply](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#kubectl-apply)
and 
[delete](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#bulk-operations-in-kubectl).

The `kustomize` task follows the same process as the `kubectl` task and 
runs  `kustomize build <dir> | kubectl <action> -f -` on all clusters.

## Parameters

The `kustomize` task uses all parameters from 
[the kube plugin and its kubectl task](./kubectl.html#).

The `dir` parameters defaults to `k7e` for kustomize. 

<a name="#examples">

## Examples

### Applying `k7e` directory to All Azure Clusters as Administrator

```
kustomize-apply-as-admin:
  - log: "Running kustomize apply as admin"
  - task: kustomize
    in:
      admin: true
      adminSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      target:
        provider: azure
```

### Applying `manifests` Directory to a Single Cluster and Namespace

```
kustomize-apply-to-namespace:
  - log: "Running kustomize apply as namespace user"
  - task: kustomize
    in:
      admin: false
      dir: manifests
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

### Deleting All Resources in `k7e` Directory to a Single Cluster and Namespace

```
kustomize-delete-from-namespace:
  - log: "Running kustomize delete as namespace user"
  - task: kustomize
    in:
      action: delete
      admin: false
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

