---
layout: wmt/docs
title:  Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Triggers provide a way to automatically start specific Concord flows
as a response to external events.

## Common Syntax

All triggers works by the same principle: the external event's data
is matched using the specified patterns and for each matched trigger
a new process is started.

Triggers are defined in the `triggers` section of a `concord.yml`
file:

```yaml
triggers:
- eventSource:
    parameter1: ".*123.*"
    parameter2: false
    entryPoint: myFlow
    arguments:
      myValue: "..."
...
```

In the example above, `parameter1` and `parameter2` are the
parameters which are matched with the external event's parameters,
`entryPoint` is the name of the flow which will be started if
there is a match and `arguments` is the list of additional parameters
which are passed to the flow.

Parameters may contain YAML literals -- strings, numbers, boolean
values or regular expressions.

The `triggers` section can contain multiple trigger definitions. Each
matching triggers is processes individually, i.e. each match can
start a new process.

The trigger definition without match attributes will be activated for
any event received from the specified source.

In addition to the `arguments` list, a started flow will receive
the `event` parameter which contains attributes of the external
event. Depending on the source of the event, the exact structure of
the `event` object may vary.

## OneOps Events

The `oneops` event source allows Concord to receive events from
OneOps. The exact nature of those events depends on the configuration
of the notification sink in OneOps.

One of the possible event types is the deployment complete event: 
```yaml
flows:
  onDeployment:
  - log: "OneOps has done a deployment: ${event}"
  
triggers:
- oneops:
    org: "myOrganization"
    asm: "myAssembly"
    env: "myEnvironment"
    platform: "myPlatform"
    type: "deployment"
    deploymentState: "complete"    
    entryPoint: onDeployment
```

The `event` object's, in addition to the trigger parameters, contains
`payload` attribute -- the original event's data "as is". Which, for
example, provides the IP address of the deployed component:

```yaml
flows:
  onDeployment:
  - task: ansible2
    in:
      ...
      inventory:
        hosts:
          - "${event.payload.cis.public_ip}"
```

## GitHub Events

The `github` event source allows Concord to receive push
notifications from GitHub:

```yaml
flows:
  onPush:
  - log: "${event.author} pushed ${event.commitId} to ${event.project}/${event.repository}"
  
triggers:
- github:
    project: "myProject"
    repository: "myRepository"
    entryPoint: onReplace
```

The `event` object provides the following attributes:
- `project` and `repository` - the name of the Concord project and
repository which were updated in GitHub;
- `author` - GitHub user, the autor of the commit;
- `branch` - the GIT repository's branch;
- `commitId` - ID of the commit which triggered the notification.

## Generic Events

The generic event endpoint provides a simple way of integration with
Concord for 3rd-party systems.

*TBD*