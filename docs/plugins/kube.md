---
layout: wmt/docs
title:  Kube Tasks, Kubectl, Kustomize and KubeInventory
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `kube` plugin supports usage of Kubectl with the `kubectl` task and
Kustomize with the `kustomize` task. It also contains a task, `kubeInventory`,
for working with the Kubernetes inventory.

The plugin automatically includes the `kustomize` and `kubectl` binaries and
invokes them as part of your Concord flow as configured:

- __kubectl v1.11.3__
- __helm 2.10.0__
- __kustomize v1.0.8.__

- [Usage](#usage)
- [Parameters](#parameters)
- [Kubectl Task](#kubectl-task)
- [Helm Task](#helm-task)
- [Kustomize Task](#kustomize-task)
- [KubeInventory Task](#kubeinventory-task)


## Usage

To be able to use the tasks in a Concord flow, the `kube` plugin must be added
as a [dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:kube:{{ site.concord_plugins_version }}
```

This adds the [Kubectl task](#kubectl-task), [Kustomize task]((#kustomize-task)
and the [KubeInventory task](#kubeinventory-task)to the classpath and allows you
to invoke the tasks in a flow.

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

The `helm` task will run `helm upgrade` commend with `--install` option.

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
- `dir`: The directory where the Kubernetes manifests are, defaults to `k8s` for
  kubectl and `k7e` for kustomize.
- `namespace`: the namespace to apply the kubectl manifests to.
- `namespaceSecretsPassword`: the namespace password.
- `target`: query object for selecting clusters. Commonly used values are:
    `cluster_id`, `cluster_seq`, `country`, `profile`, `provider`, and `site`.
    `cluster_id: <an_id>` targets a single cluster, while a `provider: azure`
    targets every azure cluster in the inventory.

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

<a name="#kubectl-task"/>

## Kubectl Task

Concord supports running the
[kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
command line tool for working with Kubernetes clusters with the `kubectl` task.
The task only supports two actions
[`apply`](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#kubectl-apply)
and 
[`delete`](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#bulk-operations-in-kubectl).


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
```

### Applying `manifests` Directory to a Single Cluster and Namespace

```
kubectl-apply-to-namespace:
  - log: "Running kubectl apply as namespace user"
  - task: kubectl
    in:
      admin: false
      adminSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      dir: manifests
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

### Deleting All Resources in `k8s` Directory to a Single Cluster and Namespace

```
kubectl-delete-from-namespace:
  - log: "Running kubectl delete as namespace user"
  - task: kubectl
    in:
      action: delete
      admin: false
      adminSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

<a name="#helm-task">

# helm Task

Concord supports management of kubernetes application using [Helm](https://helm.sh/). 
Helm has two parts: a client (helm) and a server (tiller). Concord host will run helm client. This task requires tiller install in kubernetes namespace.

### Helm task usage

```
  helm:
    - log: "Running Helm Upgrade"
    - task: helm
      in:
        namespace: my-namespace
        namespaceSecretsPassword: my-namespace-password
        helmchart: repo/helmchart
        appname: my-app
        target:
          cluster_id: us-central_dev
        config:
          key1: value1
          Key2: value2
          ...
```

### Parameters

- `helmchart`: is the name of the remote helm chart. By default configured to get walmart internal [helm repo](https://repository.walmart.com/repository/helm-hosted/).
- `config`: section can be used to add multilpe key value which can be substituted in helm charts
- `appname`: is used to derive helm release name

Additional helm values file can be added in `k8shelm` Directory. This file will be specified in `--values` option


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
      adminSecretsPassword: ${crypto.decryptString("encryptedPwd")}
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
      adminSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespaceSecretsPassword: ${crypto.decryptString("encryptedPwd")}
      namespace: tapir
      target:
        cluster_id: my_cluster
```

<a name="kubeinventory-task"/> 

## KubeInventory Task

The `kubeInventory` task is used for getting Kubernetes specific inventory data
from Concord. It supports two inventories, `clusters` and `infras`.

- `kubeInventory.clusters(target)` returns information about all clusters that
    match the target. It can be used to work with multiple clusters
    (`target.provider`), or a single cluster (`target.cluster_id`).

- `kubeInventory.infras(target)` returns information about the hosts that
    match the target. It should typically be used with a target that returns
    hosts for a single cluster, such as `target.cluster_id`.

### Parameters

- `target`: query object for selecting clusters. Commonly used values are:
    `cluster_id`, `cluster_seq`, `country`, `profile`, `provider`, and `site`.
    `cluster_id: <an_id>` targets a single cluster, while a `provider: azure`
    targets every azure cluster in the inventory.


### Example queries

```
inventory-clusters:
  - log: "Running inventory clusters"
  - expr: ${kubeInventory.clusters(target)}
    out: clusters
  - log: "Clusters: ${clusters}"

inventory-infras:
  - log: "Running inventory infras"
  - log: "Target ${target}"
  - expr: ${kubeInventory.infras(target)}
    out: infras
  - log: "Infras: ${infras}"

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
