---
layout: wmt/docs
title:  OneOps Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports interactions with [OneOps](http://oneops.com/) with the
`oneops` task as part of any flow. This allows you to manage application
deployments with Concord.

Modifications via Concord follow the same change process from design to 
transition and to operate via commit and deploy operations as any other usage
of OneOps.


<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:oneops-tasks:0.35.0
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

The following sections describe the available functions in more detail:

- [Get IP Numbers](#ip)
- [Instances](#instances)
- [Scaling](#scaling)
- [Variables](#variables)
- [Tags](#tags)
- [Touch Component](#touch)
- [Commit and Deploy](#commit-deploy)
- [Source Reference](#source)


<a name="ip"/>

## Get IP Numbers 

The OneOps task provides a number of functions to get a the IP numbers of
operating `compute` component instances or other components such as `lb` from a
specific platform.  Typically an argument is populated and later used:

```yaml
configuration:
  arguments:
    ipNumbers: ${oneops.getIPs(oneOpsConfig, platform, component)}
    moreIpNumbers: ${oneops.getIPs(oneOpsConfig, asm, env, platform, component)}
```

You can also use the expression or set syntax:

```yaml
- expr: ${oneops.getIPs(oneOpsConfig, platform, component)}
  out: ipNumbers
- set:
    moreIipNumbers: ${oneops.getIPs(oneOpsConfig, platform, component)}
```

This can also be narrowed down to the IP numbers of a specific cloud:

```yaml
${oneops.getIPsForCloud(oneOpsConfig, platform, component, cloud)}
${oneops.getIPsForCloud(oneOpsConfig, asm, env, platform, component, cloud)}
````

Or grouped by cloud:

```yaml
${oneops.getIPsByCloud(oneOpsConfig, platform, component, cloud)}
${oneops.getIPsByCloud(oneOpsConfig, asm, env, platform, component, cloud)}
```

<a name="instances"/>

## Instances

The OneOps task can return all operating instances of a component
in a platform and their attributes:

```yaml
- expr: ${oneops.getInstancesFromAssemblyAndPlatform(oneOpsConfig, platform, component)}
  out: instances
- expr: ${oneops.getInstancesFromAssemblyAndPlatform(oneOpsConfig, asm, env, platform, component)}
  out: moreInstances
```


<a name="scaling"/>

## Scaling

The OneOps task can be used to update the scaling parameters for a specific
platform as defined in transition.

```yaml
- ${oneops.updatePlatformScale(oneOpsConfig, platform, component, min, current, max, stepUp, stepDown, percentDeploy)}
- ${oneops.updatePlatformScale(oneOpsConfig, asm, env, platform, component, min, current, max, stepUp, stepDown, percentDeploy)}
```

<a name="variables"/>

## Variables

The OneOps task can be used to update a platform variable.

```yaml
- ${oneops.updatePlatformVariable((oneOpsConfig, platform, key, value)}
```

<a name="tags"/>

## Tags

The OneOps task can retrieve all tags for a specific assembly as a map of
key/value pairs.

```yaml
- expr: ${oneops.getTagsFromAssembly(oneOpsConfig, asm)}
  out: tags
```


<a name="touch"/>

## Touch Component

The OneOps task can be used to perform a touch action on a component.

```yaml
- ${oneops.touchComponent(oneOpsConfig, platform, component)}
- ${oneops.touchComponent(oneOpsConfig, asm, env, platform, component)}
```


<a name="commit-deploy"/>

## Commit and Deploy 

The OneOps task can be used to commit as well as deploy a specific environment
of an assembly.

```yaml
- ${oneops.commit(oneOpsConfig)}
- ${oneops.commit(oneOpsConfig, asm, env)}
- ${oneops.deploy(oneOpsConfig)}
- ${oneops.deploy(oneOpsConfig, asm, env)}
- ${oneops.commitAndDeploy(oneOpsConfig)}
- ${oneops.commitAndDeploy(oneOpsConfig, asm, env)}
```

You can also verify if a deployment is currently in progress:

```yaml
- expr: - ${oneops.isDeploying(oneOpsConfig, asm, env)}
  out: isDeploying
```

<a name="source"/>

## Source Reference

The [source code of the task implementation](${concord_plugins_source}tree/master/tasks/oneops)
can be used as the reference for the available functionality.

