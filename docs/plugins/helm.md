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
which includes the helm binary - __helm 2.11.0__.

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
- `fail`

In addition, the following helm-specific parameters are supported.

- `appname`: a name for the application, it is is used to derive a helm release
  name
- `chart`: the name of the  helm chart to use. The chart is retrieved from
  the default, built-in repository at
  [https://kubernetes-charts.storage.googleapis.com](https://kubernetes-charts.storage.googleapis.com).
  An additional repository can be configured in the global configuration.
  If the chart starts with `./`, the chart is treated as a project local
  chart and is installed from the project filesystem.
- `debug`: sets the `helm --debug` flag. More information is available in the
  [Helm docs](https://github.com/helm/helm/blob/master/docs/helm/helm_upgrade.md#options-inherited-from-parent-commands).
- `force`: sets the `helm --force` flag. More information is available in the
  [Helm docs](https://github.com/helm/helm/blob/master/docs/helm/helm_upgrade.md#options).
- `values`: a section of multiple key value pairs. The values are substituted
  in helm charts before execution as `--set key='value'`
- `valuesFile`: a file with with properties that are used by helm. It's the
    same as specifying `--values` with the helm command.

<a name="#examples">

## Examples

helm as administrator:

```yaml
    - task: helm
      in:
        admin: true
        adminSecretsPassword: Kube4567
        target:
          - cluster_id: 'uscentral-dev-c1'
          - cluster_id: 'uswest-dev-c1'
        multi: true
        fail: after
        chart: repo/example-app
        appname: example-app
        values:
          imageRepository: hub.example.com
          imageRootPath: /example
          imageName: counter
```

Helm usage of a local `example` chart from the Concord project repository:

```yaml
    - task: helm
      in:
        target:
          provider: azure
          profile: [ dev, lab ]
        except:
          - cluster_id
              - uswest-lab-tapir
              - uswest-dev-tapir
        multi: true
        fail: after
        admin: true
        adminSecretsPassword: ${secrets_password}
        namespace: auth
        chart: ./charts/example
        appname: example
```

The example snippet below requires a working tiller installation on the
`example` namespace.

Helm usage with namespace configuration and values file:

```yaml
    - task: helm
      in:
        namespaceSecretsPassword: Kube1234
        namespace: example
        target:
          cluster_id: 'uscentral-dev-c1'
        chart: repo/example-app
        appname: example-app
        valuesFile: config.txt
        values:
          imageRepository: hub.docker.example.com
          imageRootPath: /andersjanmyr
          imageName: counter
```
