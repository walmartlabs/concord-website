---
layout: wmt/docs
title:  Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Triggers provide a way to automatically start specific Concord flows as a
response to external events.

- [Common Syntax](#common)
- [OneOps Events](#oneops)
- [GitHub Events](#github)
- [Cron Events](#cron)
- [Generic Events](#generic)


<a name="common"/>
## Common Syntax

All triggers work by the same process: the patterns you specify as triggers 
are matched to external event data, and for each matched trigger, a new process 
is started.

Triggers are defined in the `triggers` section of a `concord.yml` file:

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

The above example makes use of the fact that events published by the external system to the the API end-point `/api/v1/events/`  are matched with trigger names. This allows you to publish events to `/api/v1/events/eventSource` for matching with triggers using the name `eventSource` as in the example. Further: 

- `parameter1` and `parameter2` are then are then matched with the external event's parameters.
- `entryPoint` is the name of the flow which will be started if there is a match.
- `arguments` is the list of additional parameters which are passed to the flow.

Parameters can contain YAML literals incuding:

- strings.
- numbers.
- boolean values.
- regular expressions.

The `triggers` section can contain multiple trigger definitions. Each matching
trigger is processed individually--each match can start a new process.

A trigger definition without match attributes is activated for any event
received from the specified source.

In addition to the `arguments` list, a started flow receives the `event`
parameter which contains attributes of the external event. Depending on the
source of the event, the exact structure of the `event` object may vary.

<a name="oneops"/>
## OneOps Events

The `oneops` event source allows Concord to receive events from OneOps. The
exact nature of those events depends on the configuration of the notification
sink in OneOps.

One of the possible event types is a deployment completion event:

```yaml
flows:
  onDeployment:
  - log: "OneOps has completed a deployment: ${event}"
  
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

The `event` object's, in addition to the trigger parameters, contains `payload`
attribute - the original event's data "as is". The following example uses the
IP address of the deployment component to build an ansible inventory for
exection of an [Ansible task](../plugins/ansible.html):


```yaml
flows:
  onDeployment:
  - task: ansible
    in:
      ...
      inventory:
        hosts:
          - "${event.payload.cis.public_ip}"
```

<a name="github"/>
## GitHub Events

The `github` event source allows Concord to receive push notifications from
GitHub:

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

The connection to the GitHub deployment needs to be 
[configured globally](./configuration.html#github).

<a namr="cron"/>
## Cron Events

You can schedule processes using cron events using:

- `fireat` for specific date and time date in ISO-8601 format.
- `spec` for time interval(s) in seconds.
- a combination of the above.

```yaml
triggers:
- cron:
    spec: 0,3,6,9
    entryPoint: onTrigger
    arguments:
      name: "Concord"
```

A single `concord.yml` file can contain multiple cron trigger definitions.

<a name="generic"/>
## Generic Events

The generic event end-point provides a simple way of integration with Concord for
3rd-party systems. Any event submitted to the events API using a specific
trigger name is routed to the identically named triggers in your Concord
project.

You can submit a JSON document to the API at `/api/v1/events/example` and start off
a flow with the trigger:

```
triggers:
- example:
    project: "myProject"
    repository: "myRepository"
    entryPoint: exampleFLow
```

Check out the
[full example]({{site.concord_source}}tree/master/examples/generic_triggers)
for more details.