---
layout: wmt/docs
title:  Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Triggers provide a way to automatically start specific Concord flows as a
response to specific events.

- [Common Syntax](#common)
- [OneOps Triggers](#oneops)
- [GitHub Triggers](#github)
- [Scheduled Triggers](#scheduled)
- [Generic Triggers](#generic)

> Trigger configuration is typically loaded automatically, but can be disabled
> globally or for specific types of repositories. For example, personal git
> repositories can be treated differently from organizational repositories in
> GitHub. You can force a new parsing and configuration by reloading a
> repository content with the reload button beside the repository in the Concord
> Console.
  



<a name="common"/>
## Common Syntax

All triggers work by the same process: 

- Concord matches the patterns you specify as triggers to event data.
- Event data is typically external, but can be internally produced in the case
of the [scheduled triggers](#scheduled).
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

This allows you to publish events to `/api/v1/events/eventSource` for matching
with triggers (where `eventSource` is any string).

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
## OneOps Triggers

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
    useInitiator: true
    entryPoint: onDeployment
```

The `event` object, in addition to its trigger parameters, contains a `payload`
attribute--the original event's data "as is". You can set `useInitiator` to `true` in order to make
sure that process is initiated using `createdBy` attribute of the event.

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
## GitHub Triggers

The `github` event source allows Concord to receive `push` and `pull_request` notifications from
GitHub. Here's an example:

```yaml
flows:
  onPush:
  - log: "${event.author} pushed ${event.commitId} to ${event.project}/${event.repository}"
  
triggers:
- github:
    type: push
    useInitiator: true
    entryPoint: onPush
```

The `event` object provides the following attributes

- `type` - Notifications type to bind with respective event notification.
Possible values can be `push` and `pull_request`. If not specified, the `type`
is set to `push` by default;
- `status` - for `pull_request` notifications only, with possible values of
`opened` or `closed`
- `project` and `repository` - the name of the Concord project and repository
which were updated in GitHub. By default the current project/repository is triggered;
- `author` - GitHub user, the author of the commit;
- `branch` - the GIT repository's branch;
- `commitId` - ID of the commit which triggered the notification;
- `useInitiator` - process initiator is set to `author` when this attribute is marked as `true`

The following example trigger fires when someone pushes to a development branch
with a name starting with `dev-`, e.g. `dev-my-feature`, `dev-bugfix`, and
ignores pushes on branch deletes:

```yaml
- github:
    type: push
    useInitiator: true
    entryPoint: devPushFlow
    branch: '^dev-.*$'
    payload:
      deleted: false
```

The next example trigger only fires on pull requests that have the label `bug`:

```yaml
- github:
    type: pull_request
    useInitiator: true
    entryPoint: pullRequestFlow
    payload:
      pull_request:
        labels:
        - { name: "bug" }
```

The following example trigger fires when someone pushes/merges into master, but
ignores pushes by `jenkinspan` and `anothersvc`:

```yaml
- github: 
    type: push
    useInitiator: true
    entryPoint: mainPushFlow
    branch: 'master'
    author: '^(?!.*(jenkinspan|anothersvc)).*$'
```

The connection to the GitHub deployment needs to be
[configured globally](./configuration.html#github).

<a name="scheduled"/>
## Scheduled Triggers

You can schedule execution of flows by defining one or multiple `cron` triggers.

Each `cron` trigger is required to specify the flow to execute with the
`entryPoint` parameter. Optionally, key/value pairs can be supplied as
`arguments`.

The `spec` parameter is used to supply a regular schedule to execute the
flow by using a [CRON syntax](https://en.wikipedia.org/wiki/Cron).

The following example trigger kicks off a process to run the `hourlyCleanUp`
flow whenever the minute value is 30, and hence once an hour every hour.

```yaml
flows:
  hourlyCleanUp:
  - log: "Sweep and wash."
triggers:
- cron:
    spec: "30 * * * *"
    entryPoint: hourlyCleanUp
```

Multiple values can be used to achieve shorter intervals, e.g. every 15 minutes
with `spec: 0,15,30,45 * * * *`. A daily execution at 9 can be specified with
`spec: 0 9 * * *`. The later fields can be used for hour, day and other
values and advanced [CRON](https://en.wikipedia.org/wiki/Cron) features such as
regular expression usage are supported as well.

Cron triggers that include a specific hour of day, can also specify a timezone 
value for stricter control. Otherwise the Concord instance specific timezone is used.

```yaml
flows:
  cronEvent:
  - log: "On cron event."
triggers:
- cron:
    spec: "0 12 * * *"
    timezone: "Europe/Moscow"
    entryPoint: cronEvent
```

Values for the timezone are derived from the
[tzdata](https://en.wikipedia.org/wiki/Tz_database)
database as used in the
[Java TimeZone class](https://docs.oracle.com/javase/8/docs/api/java/util/TimeZone.html).
You can use any of the TZ values from the
[full list of zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

Each trigger execution receives an `event` object with the properties `event.fireAt`
and `event.spec` as well as any additional arguments supplied in the
configuration (e.g. `arguments` or `activeProfiles`): 

```yaml
flows:
  eventOutput:
  - log: "${name} - event run at ${event.fireAt} due to spec ${event.spec} started."
triggers:
- cron:
    spec: "* 12 * * *"
    entryPoint: eventOutput
    activeProfiles:
    - myProfile
    arguments:
      name: "Concord"
```

Scheduled events are a useful feature to enable tasks such as regular cleanup
operations,  batch reporting or processing and other repeating task that are
automated via a Concord flow.

<a name="generic"/>

## Generic Triggers

You can configure generic triggers to respond to events that are configured to
submit data to the Concord REST API.

For example, if you submit a JSON document to the API at `/api/v1/events/example`,
an `example` event is triggered. You can capture this event and trigger a flow by
creating a trigger configuration using the same `example` name:

```yaml
triggers:
- example:
    project: "myProject"
    repository: "myRepository"
    entryPoint: exampleFLow
```

Every incoming `example` event kicks of a process of the `exampleFlow` from
`myRepository` in `myProject`.

The generic event end-point provides a simple way of integrating third-party 
systems with Concord. Simply modify or extend the external system to send
events to the Concord API and define the flow in Concord to proceed with the
next steps.

Check out the
[full example](
{{site.concord_source}}tree/master/examples/generic_triggers)
for more details.
