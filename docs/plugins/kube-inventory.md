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
task as part of they initial setup, before running the actual commands. 

On its own the task supports two operations:

- `kubeInventory.clusters(target)` returns information about all clusters that
    match the target. It can be used to work with multiple clusters
    (`target.provider`), or a single cluster (`target.cluster_id`).

- `kubeInventory.infras(target)` returns information about the hosts that
    match the target. It should typically be used with a target that returns
    hosts for a single cluster, such as `target.cluster_id`.

The alternative task invocation uses the `name` parameter to switch between the
two queries - `clusters` and `infras`. By default, `name` is set to
`clusters`.

```yaml
  - task: kubeInventory
    in:
      target:
        provider: azure
      name: clusters
    out:
      clusters: ${items}
```

## Parameters

The `target` object, passed into the task, configures the query parameters
used for the cluster or infra query.

A cluster represents a Kubernetes cluster and includes parameters as visible
in the following example:

```json
{
  "ingress": "lb-node.cluster1.cloud.s05584.us.example.com",
  "apiServer": "lb-master.cluster1.cloud.s05584.us.example.com",
  "name": "aName",
  "site": "theSiteId",
  "zone": "zone1.us",
  "region": "edge",
  "country": "us",
  "profile": "qa",
  "provider": "azure",
  "cluster_id": "us_us03384c1",
  "cluster_seq": "cluster1",
  "team": "ApplicationA",
}
```

As a result a target of 

```yaml
target:
  country: us
  provider: azure
```
returns all clusters using a provider of `azure` and a country of `us`.

Commonly used values are `cluster_id`, `cluster_seq`, `country`, `profile`,
`provider`, and `site`. `cluster_id: <an_id>` targets a single cluster,
while a `provider: azure` targets every azure cluster in the inventory. 

When the application is deployed, all cluster variables from the inventory are
replaced in the yaml files. The most useful is `${cluster.ingress}`, but
other variables from the inventory may be useful too. 

A host can be queried from the infras section and includes the following
parameters: 

```json
{
    "name": "",
    "site": "theSideId",
    "zone": "zone1.us",
    "region": "",
    "country": "us",
    "profile": "qa",
    "provider": "azure",
    "cluster_id": "eastus2-lab-anders",
    "cluster_seq": "cluster1",
    "hostname": "cpeas49a6000000.lab.anders.eastus2.us.azure.k8s.example.com",
    "host": "",
    "type": [
      "cp"
    ],
    "_meta": {
      "state": {},
      "version": 1,
      "timestamp": ""
    },
    "ipaddress": "10.76.245.155",
    "ip": "",
    "clusterInventoryRef": "eastus2_lab",
    "instanceName": "cpeas49a6000333"
  }
```

Using a query to `target.ipaddress` allows you to retrieve all other
information for a specific host.

<a name="#examples">

## Examples

The inventory allows global read access.

Retrieve all clusters for a specified target:

```yaml
inventory-clusters:
  - expr: ${kubeInventory.clusters(target)}
    out: clusters
  - log: "Clusters: ${clusters}"
```

Retrieve all infras for a specified target:

```yaml
inventory-infras:
  - expr: ${kubeInventory.infras(target)}
    out: infras
  - log: "Infras: ${infras}"
```

Retrieve all clusters deployed on the `azure` provider.

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
