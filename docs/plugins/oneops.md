---
layout: wmt/docs
title:  OneOps Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports interactions with [OneOps](http://oneops.com/) with the
`oneops` task as part of any flow. This allows you to manage application
deployments with Concord.

- [Usage](#usage)
- [Get Compute IP Numbers](#compute)
- [Instances](#instances)
- [Scaling](#scaling)
- [Variables](#variables)
- [Tags](#tags)
- [Touch Component](#touch)
- [Commit and Deploy](#commit-deploy)
- [Source Reference](#source)

<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:oneops-tasks:0.33.0
```

This adds the task to the classpath and allows you to configure the main
parameters in a separate collection e.g. named `oneOpsConfig`:

```yaml
configuration:
  arguments:
    oneOpsConfig:
      baseUrl: https://oneops.example.com/
      apiToken: ${crypto.decryptString("encryptedApiTokenValue")}
      org: myOrganization
      asm: myAssembly
      env: myEnvironment
```

- `baseUrl` - URL of the OneOps server
- `apiToken` - the OneOps API token for authentication and authorization,
  typically this should be provided via usage of the [Crypto task](./crypto.html).
- `org` - the name of the organization in OneOps;
- `asm` - the name of the assembly in OneOps;
- `env` - the name of the environment of the assembly in OneOps;

With the configuration in place, you can call the various functions of the
oneops tasks using the configuration object with the potential addition of any
further required parameters.

```yaml
flows:
  default:
  - ${oneops.updatePlatformVariable(oneOpsConfig, "webappserver", "version", "1.0.0")}
  - ${oneops.touchComponent(oneOpsConfig, "webappserver", "fqdn")}
  - ${oneops.commitAndDeploy(oneOpsConfig)}
```

The following sections describe the available functions in more detail.


<a name="compute"/>

## Get Compute IP Numbers 

The OneOps task provides a number of functions to get a the IP addresses of
oeprating computes:

```yaml
oneops.getIPs()
oneops.getIPsForCloud()
oneops.getIPsByCloud()
```

<a name="instances"/>

## Instances

```yaml
oneops.getInstancesFromAssemblyAndPlatform()
```




<a name="scaling"/>

## Scaling

```yaml
oneops.updatePlatformScale()
```

<a name="variables"/>

## Variables

Modifying Platform Variables

```yaml
oneops.updatePlatformVariable()
```



<a name="tags"/>

## Tags

```yaml
oneops.getTagsFromAssembly()
```

<a name="instances"/>




<a name="touch"/>

## Touch Component

```yaml
oneops.touchComponent()
```


<a name="commit-deploy"/>

## Commit and Deploy 

```yaml
oneops.commit()
oneops.deploy()
oneops.commitAndDeploy()

oneops.isDeploying()
```

<a name="source"/>

## Source Reference

The [source code of the task implementation](${concord_plugins_source}tree/master/tasks/oneops)
can be used as the reference for the available functionality.
available functionality.
