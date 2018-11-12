---
layout: wmt/docs
title:  KubeInventory Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `kubeInventory` task is used for getting Kubernetes-specific inventory
data from Concord. 

- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)

## Usage

To be able to use the `kubeInventory` task in a Concord flow, the
[`kube` plugin must be added as a dependency](./kubectl.html#usage).

It is used automatically by the kubectl task, the kustomize task and the helm
task as part of they initial setup, before running the actual commands. It
populates the `target` parameter.

On its own the task supports two operations:

- `kubeInventory.clusters(target)` returns information about all clusters that
    match the target. It can be used to work with multiple clusters
    (`target.provider`), or a single cluster (`target.cluster_id`).

- `kubeInventory.infras(target)` returns information about the hosts that
    match the target. It should typically be used with a target that returns
    hosts for a single cluster, such as `target.cluster_id`.


## Parameters

The `kubeInventory` task uses the following parameters from 
[the kube plugin and its kubectl task](./kubectl.html#).

- `target`

In addition, the following inventory-specific parameters are supported. 

- `name`

<a name="#examples">

## Examples

The inventory allows global read access.

Retrieve all clusters for a specified target:

```yaml
inventory-clusters:
  - log: "Running inventory clusters"
  - expr: ${kubeInventory.clusters(target)}
    out: clusters
  - log: "Clusters: ${clusters}"
```

Retrieve all infras for a specified target:

```yaml
inventory-infras:
  - log: "Running inventory infras"
  - log: "Target ${target}"
  - expr: ${kubeInventory.infras(target)}
    out: infras
  - log: "Infras: ${infras}"
```

Retrieve all clusters deployed on the azure provider.

```yaml
inventory-execute:
  - log: "Running inventory execute"
  - task: kubeInventory
    in:
      target:
        provider: azure
      name: clusters
    out:
      clusters: ${items}
  - log: "Clusters ${clusters}"
```
