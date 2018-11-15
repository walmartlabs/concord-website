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

- `admin`
- `adminSecretsPassword`
- `namespace`
- `namespaceSecretsPassword`
- `multi`
- `target`

In addition, the following helm-specific parameters are supported.

- `appname`: a name for the application, it is is used to derive a helm release
  name
- `chart`: the name of the  helm chart to use. The chart is retrieved from
  the default, built-in repository at
  [https://kubernetes-charts.storage.googleapis.com](https://kubernetes-charts.storage.googleapis.com).
  An additional repository can be configured in the global configuration.
  If the chart starts with `./`, the chart will be treated as a project local
  chart and will be installed from the project filesystem.
- `values`: a section of multiple key value pairs. The values are substituted
  in helm charts before execution as `--set key='value'`
- `valuesFile`: a file with with properties that are used by helm. It's the
    same as specifying `--values` with the helm command.

<a name="#examples">

## Examples

The example snippet below requires a working tiller installation on the
`example` namespace. It runs the `repo/example-helmchart` helm chart against
the cluster `us-central_dev` in the `example` namespace.

```yaml
  helm-admin:
    - log: "Running Helm Upgrade as admin"
    - task: helm
      in:
        admin: true
        adminSecretsPassword: Kube4567
        target:
          cluster_id: 'anders'
        chart: wmt/webapp-basic
        appname: my-webapp
        values:
          imageRepository: hub.docker.prod.walmart.com
          imageRootPath: /andersjanmyr
          imageName: counter

  helm-namespace:
    - log: "Running Helm Upgrade as admin"
    - task: helm
      in:
        namespaceSecretsPassword: Kube1234
        namespace: tapir
        target:
          cluster_id: 'anders'
        chart: wmt/webapp-basic
        appname: my-webapp
        valuesFile: dingo.text
        values:
          imageRepository: hub.docker.prod.walmart.com
          imageRootPath: /andersjanmyr
          imageName: counter

  helm-local-chart
    - task: helm
      in:
        target:
          cluster_id: 'anders'
        admin: true
        adminSecretsPassword: ${secrets_password}
        namespace: auth
        chart: ./charts/wce-dex
        appname: my-webapp
        values:
          ingress_url: ${ item.ingress }
          api_server: ${ item.apiServer }
          ingress_tls_cert: ${ tls_key }
          ingress_tls_key: ${ tls_cert }
          ldap_bind_user: CN=Kubernetes ManagedServices\,OU=Process IDs\,OU=Service Accounts\,DC=homeoffice\,DC=Wal-Mart\,DC=com
          ldap_bind_pw: ${ldap_password}
```

