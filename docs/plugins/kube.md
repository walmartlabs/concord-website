---
layout: wmt/docs
title:  Kubectl and Kustomize Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `kube` plugin supports usage of Kubectl with the `kubectl` task and
Kustomize with the `kustomize` task.

The plugin automatically includes the `kustomize` and `kubectl` binaries and
invokes them as part of your Concord flow as configured.

__Version used are: kubectl v1.11.3 and kustomize v1.0.8.__

- [Usage](#usage)
- [Parameters](#parameters)
- [Kubectl Task](#kubectl-task)
- [Kustomize Task](#kustomize-task)


## Usage

To be able to use the tasks in a Concord flow, the `kube` plugin must be added
as a [dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:kube:{{ site.concord_plugins_version }}
```

This adds the [Kubectl task](#kubectl-task) and the
[Kustomize task]((#kustomize-task) to the classpath and allows you to invoke the
tasks in a flow.

Typically this involves connecting to a cluster or namespace and then applying
your configuration.

When the plugin runs it does the following.

- It finds the relevant clusters via the `target` parameter.
- It finds the relevant keys and tokens for each cluster.
- It replaces all occurrences of cluster variables, such as
  `${cluster.ingress}`, in the yaml-files.

Then the `kubectl` task calls `kubectl <action> -f <dir>` on all clusters:

- `action` is apply (default) or delete
- `dir` is a directory holding your manifests (default is `k8s`)

The `kustomize` task on the other hand calls 
`kustomize build <dir> | kubectl <action> -f -` on all clusters:

- `action` is apply (default) or delete.
- `dir` is a directory holding your manifests (default is `k7e`).

## Parameters

All parameters (sorted alphabetically). Usage documentation can be found in the
following sections:

- `action`: the action to perform, defaults to `apply`.
- `admin`: connect as cluster administrator or not, defaults to `false`.
- `adminSecretsPassword`: the password for getting admin secrets from concord.
- `dir`: The directory where the Kubernetes manifests are, defaults to `k8s`.
- `namespace`: the namespace to apply the kubectl manifests.
- `namespaceSecretsPassword`: the password for getting namespace secrets from concord.
- `target`: query object for selecting clusters. Commonly used values are:
    `cluster_id`, `cluster_seq`, `country`, `profile`, `provider`, and `site`.
    `cluster_id: <an_id>` targets a single cluster, while a `provider: azure`
    targets every azure cluster in the inventory.


When the application is deployed all cluster variables from the inventory are
replaced in the yaml files. The most useful is `${cluster.ingress}`, but
other variables from the inventory may be useful too. Find the variables for
your cluster with `sledge get cluster --cluster_id <my-cluster-id>`

```
# Example data from inventory.
{
  "ingress": "lb-node.cluster1.cloud.s05584.us.wal-mart.com",
  "apiServer": "lb-master.cluster1.cloud.s05584.us.wal-mart.com",
  "name": "us05584c1",
  "site": "05584US",
  "zone": "vsh01.s05584.us",
  "region": "edge",
  "country": "us",
  "profile": "labs",
  "provider": "vmware",
  "cluster_id": "us_us05584c1",
  "cluster_seq": "cluster1",
  "team": "Stores",
  ...
}
```


<a name="#kubectl-task"/>

## Kubectl Task

Concord supports running the
[kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
command line tool for working with Kubernetes clusters with the `kubectl` task.
The task only supports two actions
[`apply`](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#kubectl-apply)
and 
[`delete`](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#bulk-operations-in-kubectl).


### Applying ./k8s directory to All Azure Clusters as Administrator

```
kubectl-apply-as-admin:
  - log: "Running kubectl apply as admin"
  - task: kubectl
    in:
      admin: true
      adminSecretsPassword: ${crypto.decryptString("4d1+ruCra6CLBboT7Wx5mw==")}
      target:
        provider: azure
```

### Applying ./manifests Directory to a Single Cluster and Namespace

```
kubectl-apply-to-namespace:
  - log: "Running kubectl apply as namespace user"
  - task: kubectl
    in:
      admin: false
      adminSecretsPassword: ${crypto.decryptString("4d1+6CLBboT7Wx5mw==")}
      dir: manifests
      namespaceSecretsPassword: ${crypto.decryptString("666+ruBboT7Wx5mw==")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

### Deleting All Resources in ./k8s Directory to a Single Cluster and Namespace

```
kubectl-delete-from-namespace:
  - log: "Running kubectl delete as namespace user"
  - task: kubectl
    in:
      action: delete
      admin: false
      adminSecretsPassword: ${crypto.decryptString("4d1+6CLBboT7Wx5mw==")}
      dir: manifests
      namespaceSecretsPassword: ${crypto.decryptString("666+ruBboT7Wx5mw==")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

<a name="#kustomize-task"/>

# Kustomize Task

Concord supports running the
[kustomize](https://github.com/kubernetes-sigs/kustomize#kustomize)
command line tool for working with Kubernetes clusters with the `kustomize`
task. Kustomize works by transforming the kustomize files and then applying them
to the cluster with `kubectl`.

The task only supports two actions
[apply](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#kubectl-apply)
and 
[delete](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#bulk-operations-in-kubectl).


### Applying ./k7e directory to All Azure Clusters as Administrator

```
kustomize-apply-as-admin:
  - log: "Running kustomize apply as admin"
  - task: kustomize
    in:
      admin: true
      adminSecretsPassword: ${crypto.decryptString("4d1+ruCra6CLBboT7Wx5mw==")}
      target:
        provider: azure
```

### Applying ./manifests Directory to a Single Cluster and Namespace

```
kustomize-apply-to-namespace:
  - log: "Running kustomize apply as namespace user"
  - task: kustomize
    in:
      admin: false
      adminSecretsPassword: ${crypto.decryptString("4d1+6CLBboT7Wx5mw==")}
      dir: manifests
      namespaceSecretsPassword: ${crypto.decryptString("666+ruBboT7Wx5mw==")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

### Deleting All Resources in ./k8s Directory to a Single Cluster and Namespace

```
kustomize-delete-from-namespace:
  - log: "Running kustomize delete as namespace user"
  - task: kustomize
    in:
      action: delete
      admin: false
      adminSecretsPassword: ${crypto.decryptString("4d1+6CLBboT7Wx5mw==")}
      dir: manifests
      namespaceSecretsPassword: ${crypto.decryptString("666+ruBboT7Wx5mw==")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

