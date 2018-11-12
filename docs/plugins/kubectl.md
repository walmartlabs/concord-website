---
layout: wmt/docs
title:  KubeCtl Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}


Concord supports running the
[kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
command line tool for working with Kubernetes clusters with the `kubectl` task.

The `kube` plugin bundles a number of Kubernetes-related tasks.

- [KubeCtl](#usage)
- [Kustomize](./kustomize.html)
- [KubeInventory](./kube-inventory.html)
- [Helm](./helm.html)

The plugin automatically includes the `kubectl` binary - __kubectl v1.11.3__.

- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)



## Usage

To be able to use the tasks in a Concord flow, the `kube` plugin must be added
as a [dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:kube:{{ site.concord_plugins_version }}
```

This adds all tasks to the classpath and allows you to invoke them in any flow.

Typically this involves connecting to a cluster or namespace and then applying
your configuration.

When the plugin runs it does the following.

- It finds the relevant clusters via the `target` parameter.
- It finds the relevant keys and tokens for each cluster.
- It replaces all occurrences of `${namespace}` in the files in `dir`.
- It replaces all occurrences of cluster variables, such as
  `${cluster.ingress}`, in the files in `dir`
- Then the `kubectl` task calls `kubectl <action> -f <dir>` on all clusters.
- The `kustomize` task on the other hand calls 
`kustomize build <dir> | kubectl <action> -f -` on all clusters:

The `kubectl` action returns data in two variables:

- `${results}`, a list of results from all clusters.
- `${result}`, the result from the first cluster. 

The `helm` task runs run `helm upgrade` commend with `--install` option.

The `kustomize` task on the other hand calls 
`kustomize build <dir> | kubectl <action> -f -` on all clusters:

If the data returned from `kubectl` is using JSON as format, it is converted to
an object automatically and the values can be used and manipulated in Concord.

## Parameters

All parameters (sorted alphabetically). Usage documentation can be found in the
following sections:

- `action`: the action to perform, defaults to `apply`. For `kubectl` it may
    be an arbitrary `kubectl` command such as `get pods -o json`. For
    `kustomize`, it must be `apply` or `delete`.
- `admin`: connect as cluster administrator or not, defaults to `false`.
- `adminSecretsPassword`: the password for getting admin secrets from concord.
    Only required when `admin` is `true`
- `dir`: The directory where the Kubernetes manifests are, defaults to `k8s` for
  kubectl and `k7e` for kustomize. It is only used if the action is `apply` or
  `delete`.
- `namespace`: the namespace to apply the kubectl manifests to.
- `namespaceSecretsPassword`: the namespace password.
- `target`: query object for selecting clusters. Commonly used values are:
    `cluster_id`, `cluster_seq`, `country`, `profile`, `provider`, and `site`.
    `cluster_id: <an_id>` targets a single cluster, while a `provider: azure`
    targets every azure cluster in the inventory.
- `multi` must be set to `true`, if you want to run this task in more than
    one cluster. This is to prevent running commands on multiple clusters by
    mistake.

When the application is deployed, all cluster variables from the inventory are
replaced in the yaml files. The most useful is `${cluster.ingress}`, but
other variables from the inventory may be useful too. Find the variables for
your cluster with `sledge get cluster --cluster_id <my-cluster-id>`.

Example data from inventory:

```
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
}
```

<a name="#examples">

## Examples

The task supports actions
[`apply`](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#kubectl-apply)
and
[`delete`](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#bulk-operations-in-kubectl).
directly. Any other command submitted as action is simply forwarded.

### Applying `k8s` directory to All Azure Clusters as Administrator

```
kubectl-apply-as-admin:
  - log: "Running kubectl apply as admin"
  - task: kubectl
    in:
      admin: true
      adminSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      target:
        provider: azure
      multi: true
```

### Applying `manifests` Directory to a Single Cluster and Namespace

```
kubectl-apply-to-namespace:
  - log: "Running kubectl apply as namespace user"
  - task: kubectl
    in:
      admin: false
      dir: manifests
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

### Query Cluster, If a Namespace Exists

```
kubectl-query-for-existing-namespace:
  - log: "Running kubectl-query-for-existing-namespace"
  - task: kubectl
    in:
      admin: true
      adminSecretsPassword: Kube4567
      target:
        cluster_id: my-cluster
      action: "get namespace tapir"
    out:
      found: true
    error:
      - log: "Namespace does not exist."
      - set:
          found: false
  - log: "Namespace tapir found: ${found}"
```

### Query Cluster for All Pods in a Namespace

```
kubectl-query-json:
  - log: "Get pods from namespace tapir"
  - task: kubectl
    in:
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my-cluster
      action: "get pods -o json"
    out:
      cluster: ${result}
  - call: list-pod-name
    withItems: ${cluster.items}
```

### Query All Azure Clusters for All Namespaces

```
kubectl-query-json:
  - log: "Get namespaces from all azure clusters"
  - task: kubectl
    in:
      admin: true
      adminSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      target:
        provider: azure
      multi: true
      action: "get namespaces -o json"
    out:
      clusters: ${results}
  - call: list-namespaces
    withItems: ${clusters}
```


### Deleting All Resources in `k8s` Directory in a Single Cluster and Namespace

```
kubectl-delete-from-namespace:
  - log: "Running kubectl delete as namespace user"
  - task: kubectl
    in:
      action: delete
      admin: false
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```


