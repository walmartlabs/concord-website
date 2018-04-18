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
- [Generic Event](#generic)
- [Integration Using Event](#integration)


<a name="common"/>
## Common Syntax

All triggers work by the same process: 

- Concord matches the patterns you specify as triggers to external event data.
- For each matched trigger, it starts a new process.

You define triggers in the `triggers` section of a `concord.yml` file, as in 
this example:

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

When the API end-point `/api/v1/events/` receives an event, Concord detects any
existing matches with trigger names. 

This allows you to publish events to `/api/v1/events/eventSource` for matching with triggers (where `eventSource` is any string). 

Further: 

- Concord detects any matches of `parameter1` and `parameter2` with the external event's parameters.
- `entryPoint` is the name of the flow that Concord starts when there is a match.
- `arguments` is the list of additional parameters that are passed to the flow.

Parameters can contain YAML literals as follows:

- strings
- numbers
- boolean values
- regular expressions

The `triggers` section can contain multiple trigger definitions. Each matching
trigger is processed individually--each match can start a new process.

A trigger definition without match attributes is activated for any event
received from the specified source.

In addition to the `arguments` list, a started flow receives the `event`
parameter which contains attributes of the external event. Depending on the
source of the event, the exact structure of the `event` object may vary.

<a name="oneops"/>
## OneOps Events

Using `oneops` as an event source allows Concord to receive events from OneOps. 
You can configure event properties in the OneOps notification sink, specifically
for use in Concord triggers.

Deployment completion events can be especially useful:

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

The `event` object, in addition to its trigger parameters, contains a `payload`
attribute--the original event's data "as is". 

The following example uses the IP address of the deployment component to build 
an Ansible inventory for execution of an [Ansible task](../plugins/ansible.html):

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
GitHub. Here's an example:

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

The `event` object provides the following attributes

- `project` and `repository` - the name of the Concord project and
repository which were updated in GitHub
- `author` - GitHub user, the author of the commit
- `branch` - the GIT repository's branch
- `commitId` - ID of the commit which triggered the notification

The connection to the GitHub deployment needs to be 
[configured globally](./configuration.html#github).

<a namr="cron"/>
## Cron Events

You can schedule processes with cron events using one or both of the parameters
available.

- `fireat` for specifying a future date and time in ISO-8601 format
- `spec` for time interval(s) in seconds

```yaml
flows:
  default:
  - log: "hello"
 
  onTrigger:
  - log: "Triggered by ${event}. Hello from ${name}"
  triggers:
  - cron:
    spec: 0,3,6,9
    entryPoint: onTrigger
    arguments:
      name: "Concord"
```

A single `concord.yml` file can contain multiple cron trigger definitions.

<a name="generic"/>
## Generic Event

You can create generic events for may uses. 

For example, submit a JSON document to the API at `/api/v1/events/example`, and start off a flow with an `example` trigger:

```
triggers:
- example:
    project: "myProject"
    repository: "myRepository"
    entryPoint: exampleFLow
```

<a name="integration">
## Integration Using Events

The generic event end-point provides a simple way of integrating third-party 
systems with Concord. 
 
Simply name an event and a trigger with identical names. Concord routes any 
events incoming to the API that have names that match any triggers, to the identically named triggers.

Check out the
[full example](
{{site.concord_source}}tree/master/examples/generic_triggers)
for more details.
