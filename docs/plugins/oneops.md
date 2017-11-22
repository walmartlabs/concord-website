---
layout: wmt/docs
title:  OneOps Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord supports interactions with [OneOps](http://oneops.com/) with the
`oneops` task as part of any flow. This allows you to provision and manage 
application deployments with Concord.

- [Usage](#usage)
- [Parameters](#parameters)

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:oneops-tasks:0.35.0
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
  - task: oneops
    in:
      baseUrl: 
      apiToken:
      org:
      asm:
      env:
```

A full list of available parameters is described [below](#parameters).

## Parameters

Configuration object

- `baseUrl` - string, relative path to a playbook;
- `apiToken` - string, ;
- `org` - string, ;
- `asm` - string, ;
- `env` - string, ;



## Get IP Numbers of Compute

oneops.getIPs

oneops.getIPsForCloud

oneops.getIPsByCloud


## Scaling

oneops.updatePlatformScale


## Modifying Platform Variables

oneops.updatePlatformScale



## Deploying

oneops.isDeploying



## Tags

oneops.getTagsFromAssembly


## Instances

oneops.getInstancesFromAssemblyAndPlatform


## Touching

touchComponent


## Commit

oneops.commit

## Deploy

oneops.deploy


## Commit and Deploy 

oneops.commitAndDeploy


