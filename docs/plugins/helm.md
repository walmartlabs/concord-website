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

The `helm` task follows the same process as the `kubectl` task and 
runs a `helm upgrade` command with `--install` option into all cluster or
namespaces.

## Parameters

The `helm` task uses the following parameters from 
[the kube plugin and its kubectl task](./kubectl.html#).

- `namespace`
- `namespaceSecretsPassword`
- `target`

In addition, the following helm-specific parameters are supported. 

- `appname`: a name for the application, it is is used to derive a helm release
  name
- `helmchart`: the name of the  helm chart to use. The chart is retrieved from
  the default, built-in repository at 
  [https://kubernetes-charts.storage.googleapis.com](https://kubernetes-charts.storage.googleapis.com).
  An additional repository can be configured in the global configuration.
- `config`: a section of multiple key value pairs. The values are substituted
  in helm charts before execution.

Additional helm values file can be added in the `k8shelm` directory. The
directory is specified in the `--values` option of the helm command.

<a name="#examples">

## Examples

The example snippet below requires a working tiller installation on the
`example` namespace. It runs the `repo/example-helmchart` helm chart against
the cluster `us-central_dev` in the `example` namespace.

```
  helm:
    - log: "Running Helm Upgrade"
    - task: helm
      in:
        namespace: example
        namespaceSecretsPassword: my-namespace-password
        helmchart: repo/example-helmchart
        appname: my-app
        target:
          cluster_id: us-central_dev
        config:
          key1: value1
          key2: value2
```

