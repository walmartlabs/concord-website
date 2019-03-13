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
  - mvn://com.walmartlabs.concord.plugins:oneops-tasks:{{ site.concord_plugins_walmart_version }}
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
      includePlatforms: ['platform-1', 'platform-2']
```

- `baseUrl` - URL of the OneOps server
- `apiToken` - the OneOps API token for authentication and authorization,
  typically this should be provided via usage of the [Crypto task](./crypto.html).
- `org` - the name of the organization in OneOps;
- `asm` - the name of the assembly in OneOps;
- `env` - the name of the environment of the assembly in OneOps;
- `includePlatforms` - list of included platforms for commit;

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
- [Clouds](#clouds)
- [Scaling](#scaling)
  - [Platform](#platform-scaling) 
  - [Cloud](#cloud-scaling)
    - [Active vs Inactive](#active-vs-inactive)
    - [Primary vs Secondary](#primary-vs-secondary)
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

**Note:** This method is `Deprecated`, use `getComputeIPs()` or `getFqdnIPs()` methods instead of this.

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
${oneops.getIPsByCloud(oneOpsConfig, platform, component)}
${oneops.getIPsByCloud(oneOpsConfig, asm, env, platform, component)}
```

Get Compute IPs:

```yaml
${oneops.getComputeIPs(oneOpsConfig, platform)}
${oneops.getComputeIPs(oneOpsConfig, asm, env, platform)}
```

Get FQDN IPs:

```yaml
${oneops.getFqdnIPs(oneOpsConfig, platform)}
${oneops.getFqdnIPs(oneOpsConfig, asm, env, platform)}
```

Get IPs for a specific cloud priority value:
```yaml
${oneops.getIPsByCloudPriority(oneOpsConfig, platform, priority)}
${oneops.getIPsByCloudPriority(oneOpsConfig, asm, env, platform, priority)}
```
Typically, primary clouds have priority value `1` and secondary - `2`:
```yaml
- set:
    myPrimaryIPs: ${oneops.getIPsByCloudPriority(oneOpsConfig, platform, 1)}
    mySecondaryIPs: ${oneops.getIPsByCloudPriority(oneOpsConfig, platform, 2)}
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

<a name="clouds"/>

## Clouds

The OneOps task can be used to retrieve the list of cloud for a specific 
platform in an environment.

```yaml
- expr: ${oneops.getTransitionPlatformClouds(oneOpsConfig, platform)}
  out: clouds
```

As a results clouds `variable` contains a list of all clouds identifiers, which
can subsequently used for [scaling](#scaling) and other operations.

<a name="scaling"/>

## Scaling

<a name="platform-scaling"/>

### Platform

The OneOps task can be used to update the scaling parameters for a specific
platform as defined in transition.

```yaml
- ${oneops.updatePlatformScale(oneOpsConfig, platform, component, min, current, max, stepUp, stepDown, percentDeploy)}
- ${oneops.updatePlatformScale(oneOpsConfig, asm, env, platform, component, min, current, max, stepUp, stepDown, percentDeploy)}
```

<a name="cloud-scaling"/>

### Cloud

The OneOps task can be used to update the cloud specific parameters for specific
platform as defined in transaction.

```yaml
- ${oneops.updatePlatformCloudScale(oneOpsConfig, platform, cloudId, attributesMap)}
```

The attributes map can contain `adminstatus` with values `active` or `inactive`
and `priority` with values `1` or `2` as described below in detail.


#### Active vs Inactive

Cloud status can be set to active or inactive by using the `adminstatus`. To
make your cloud inactive, you must set the `adminstatus` to `inactive`. This is
equivalent to ignoring a cloud from OneOps ui. To make your cloud active again,
set `adminstatus` back to `active` .

```yaml
- ${oneops.updatePlatformCloudScale(oneOpsConfig, platform, cloudId, {adminStatus: 'inactive'})}
```

#### Primary vs Secondary

`priority` can be used to mark Cloud as primary or secondary. `priority` with
value `1` mark the cloud as primary and `2` for secondary.

```yaml
- ${oneops.updatePlatformCloudScale(oneOpsConfig, platform, cloudId, {priority: 2})}
```

<a name="variables"/>

## Variables

The OneOps task can be used to get all platform or global variables and subsequently
access them from the returned output. These variables can be updated as well using OneOps task.

List platform variables:

```yaml
- expr: ${oneops.getPlatformVariables(oneOpsConfig, platform)}
  out: platform_variables1
- log: "Variable value: ${platform_variables1.testVariable}"
```

List global variables:

```yaml
- expr: ${oneops.getGlobalVariables(oneOpsConfig)}
  out: global_Variables
- log: "Variable value: ${global_Variables.variableName}"
```

You can specify the assembly and environment directly in the call:

```yaml
- expr: ${oneops.getPlatformVariables(oneOpsConfig, asm, env, platform)}
  out: platform_variables2
- log: "Variable value: ${platform_variables2.variableName}"
```

```yaml
- expr: ${oneops.getGlobalVariables(oneOpsConfig, asm, env)}
  out: global_variables2
- log: "Variable value: ${global_variables2.variableName}"
```

If a variable name contains a hyphen, the `get` method can be used to retrieve
the value:

```yaml
- log: "Variable value: ${platform_variables2.get('variable-name')}"
```

Update platform variable:

```yaml
- ${oneops.updatePlatformVariable(oneOpsConfig, platform, key, value)}
```

Update global variable:

```yaml
- ${oneops.updateGlobalVariable(oneOpsConfig, key, value)}
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
of an assembly. You can also commit selected platforms by providing the `includePlatforms` list.

```yaml
- ${oneops.commit(oneOpsConfig)}
- ${oneops.commit(oneOpsConfig, asm, env)}
- ${oneops.commit(oneOpsConfig, asm, env, includedPlatforms)}
- ${oneops.deploy(oneOpsConfig)}
- ${oneops.deploy(oneOpsConfig, asm, env)}
- ${oneops.commitAndDeploy(oneOpsConfig)}
- ${oneops.commitAndDeploy(oneOpsConfig, asm, env)}
- ${oneops.commitAndDeploy(oneOpsConfig, asm, env, ['platform1', 'platform2'])}
```

You can also verify if a deployment is currently in progress or failed:

```yaml
- expr: ${oneops.isDeploying(oneOpsConfig, asm, env)}
  out: isDeploying
```

```yaml
- expr: ${oneops.isDeploymentFailed(oneOpsConfig, asm, env)}
  out: isFailed
```

Oneops provides a method to wait for completion of the current deployment.

```yaml
- expr:  ${oneops.waitForActiveDeployment(oneOpsConfig, asm, env, timeout)}
```

`timeout` - Number of milliseconds to wait before executing the next step 
in flow, regardless of deployment completion. If set to less than zero, it will wait for 
completion of deployment.

<a name="source"/>

## Source Reference

The
[source code of the task implementation]({{site.concord_plugins_source}}tree/master/tasks/oneops)
can be used as the reference for the available functionality.

