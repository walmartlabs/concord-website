---
layout: wmt/docs
title:  Helm Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports management of applications in a Kubernetes cluster using
[Helm](https://helm.sh/). Usage of the client side _helm_ tool requires the
server-side _tiller_ to be installed in the Kubernetes cluster. With the `helm`
task Concord is capable of running the helm client and therefore interact with 
`tiller` in a Kubernetes cluster or namespace.

The `helm` task is available as part of the [`kube` plugin](./kubectl.html),
which includes the helm binary - __helm 2.10.0__.

- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)


## Usage

To be able to use the `helm` task in a Concord flow, the
[`kube` plugin must be added as a dependency](./kubectl.html#usage).


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

