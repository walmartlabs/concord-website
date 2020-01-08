---
layout: wmt/docs
title:  Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Triggers provide a way to automatically start specific Concord flows as a
response to specific events.

- [Common Syntax](#common)
- [Supported Triggers](#supported-triggers)
  - [OneOps Triggers](#oneops)
  - [GitHub Triggers](#github)
    - [Version 2](#github-v2)
    - [Version 1](#github-v1)
    - [Migration](#github-migration)
  - [Scheduled Triggers](#scheduled)
  - [Generic Triggers](#generic)
  - [Manual Triggers](#manual)
- [Exclusive Triggers](#exclusive-triggers)

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

- Concord detects any matches of `parameter1` and `parameter2` with the external
  event's parameters.
- `entryPoint` is the name of the flow that Concord starts when there is a match.
- `arguments` is the list of additional parameters that are passed to the flow;
- `exclusive` is the name of the [exclusive group](#exclusive-triggers).

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

## Supported Triggers

<a name="oneops"/>

### OneOps Triggers

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
attribute--the original event's data "as is". You can set `useInitiator` to
`true` in order to make sure that process is initiated using `createdBy`
attribute of the event.

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

### GitHub Triggers

Currently Concord supports two different implementations of `github` triggers:
`version: 1` and `version: 2`. The latter has cleaner syntax and is more
straightforward to use in complex use cases like listening for multiple
repositories.

The default version is configured in [the server configuration file](./configuration.html#server-cfg-file).
Ask your Concord instance's administrator which version is the default version
for your environment.

<a name="github-v2"/>

### Version 2

The `github` event source allows Concord to receive `push` and `pull_request`
notifications from GitHub. Here's an example:

```yaml
flows:
  onPush:
  - log: "${event.sender} pushed ${event.commitId} to ${event.payload.repository.full_name}"
  
triggers:
- github:
    version: 2
    useInitiator: true
    entryPoint: onPush
    conditions:
      type: push
```

Github trigger supports the following attributes

- `entryPoint` string, mandatory, the name of the flow that Concord starts when
GitHub event matches trigger conditions;
- `activeProfiles` array of string, optional, list of profiles that Concord
applies for process;
- `useInitiator` boolean, optional, process initiator is set to `sender` when
this attribute is marked as `true`;
- `useEventCommitId` boolean, optional, Concord will use commit id from event
for process;
- `exclusive` string, optional, exclusive group for process;
- `arguments` key-value, optional, additional parameters that are passed to the
flow;
- `conditions` key-value, mandatory, conditions for GutHub event matching;
- `version` - number, optional if matches the default version of the current
Concord instance. Trigger implementation's version.

Possible GitHub trigger `conditions`:

- `type` - string, mandatory, GitHub event name;
- `githubOrg` - string or regex, optional, GitHub organization name. Default is
the current repository's GitHub organization name;
- `githubRepo` - string or regex, optional, GitHub repository name. Default is
the current repository's name;
- `githubHost` - string or regex, optional, GitHub host;
- `branch` - string or regex, optional, even branch name;
- `sender` - string or regex, optional, event sender;
- `status` - string or regex, optional, event action;
- `repositoryInfo` - a list of objects, information about the matching Concord
repositories (see below);
- `payload` - key-value, optional, github event payload.

The `repositoryInfo` condition allows triggering on GitHub repository events
that have matching Concord repositories. See below for examples.

The `repositoryInfo` entries have the following structure:
- `projectId` - UUID, ID of a Concord project with the registered repository;
- `repositoryId` - UUID, ID of the registered repository;
- `repository` - string, name of the registered repository;
- `branch` - string, the configured branch in the registered repository.

The `event` object provides all attributes from trigger conditions filled with
GitHub event.

#### Examples

A minimal `github` trigger definition that triggers the `onPush` flow whenever
there's a `push` event in the same branch as configured in Concord:

```yaml
- github:
    version: 2
    entryPoint: "onPush"
    conditions:
      type: "push"
```

The following example trigger fires when someone pushes to a development branch
with a name starting with `dev-`, e.g. `dev-my-feature`, `dev-bugfix`, and
ignores pushes on branch deletes:

```yaml
- github:
    version: 2
    useInitiator: true
    entryPoint: devPushFlow
    conditions:
      branch: '^dev-.*$'
      type: push
      payload:
        deleted: false
```

The next example trigger only fires on pull requests that have the label `bug`:

```yaml
- github:
    version: 2
    useInitiator: true
    entryPoint: pullRequestFlow
    conditions:
      type: pull_request
      payload:
        pull_request:
          labels:
          - { name: "bug" }
```

The following example trigger fires when someone pushes/merges into master, but
ignores pushes by `jenkinspan` and `anothersvc`:

```yaml
- github:
    version: 2
    useInitiator: true
    entryPoint: mainPushFlow
    conditions:
      type: push
      branch: 'master'
      author: '^(?!.*(jenkinspan|anothersvc)).*$'
```

If `https://github.com/myorg/producer-repo` is registered in Concord as
`producerRepo` then the following trigger will receive all matching events for
the registered repository:

```yaml
- github:
      version: 2
      entryPoint: onPush
      conditions:
        repositoryInfo:
          - repository: producerRepo
```

Regular expressions can be used to subscribe to *all* GitHub repositories
handled by the registered webhooks:

```yaml
- github:
    version: 2
    entryPoint: onPush
    conditions:
      githubOrg: ".*"
      githubRepo: ".*"
```

**Note:** subscribing to all GitHub events can be restricted on the system
policy level. Ask your Concord instance administrator if it is allowed in your
environment. 

<a name="github-v1"/>

## Version 1

**Note:** the version 1 of `github` trigger implementation is deprecated and
replaced with [version 2](#version-2). Check [the migration guide](#github-migration)
on how to update your flows to be compatible with the version 2. 

The `github` event source allows Concord to receive `push` and `pull_request`
notifications from GitHub. Here's an example:

```yaml
flows:
  onPush:
  - log: "${event.author} pushed ${event.commitId} to ${event.project}/${event.repository}"

triggers:
- github:
    version: 1
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
  which were updated in GitHub. By default the current project/repository is
  triggered;
- `author` - GitHub user, the author of the commit;
- `branch` - the GIT repository's branch;
- `commitId` - ID of the commit which triggered the notification;
- `useInitiator` - process initiator is set to `author` when this attribute is
  marked as `true`;
- `version` - number, optional if matches the default version of the current
  Concord instance. Trigger implementation's version.

<a name="github-migration"/>

### Migration

Notable differences in `github` triggers between [version 1](#github-v1) and
[version 2](#github-v2):
- trigger conditions are moved into a `conditions` field:

  ```yaml
  # v1
  - github:
      version: 1
      type: "push"
      entryPoint: "onPush"
  
  # v2
  - github:
      version: 2
      conditions:
        type: "push"
      entryPoint: "onPush"
  ```
- the `event` variable structure is different:
    - `${event.author}` is replaced with `${event.sender}` to closely match the
    original data received from GitHub;
    - `${event.org}` and `${event.project}` are gone. It's not possible to
    provide this data while simultaneously support triggers for repositories
    that are not registered in Concord (i.e. in typical GitOps use cases).

<a name="scheduled"/>

### Scheduled Triggers

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

### Generic Triggers

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

<a name="manual"/>

### Manual Triggers

Manual triggers can be used to add items to the repository action drop down
in the Concord Console, similar to the default added _Run_ action.

Each `manual` trigger must specify the flow to execute using the `entryPoint`
parameter. The `name` parameter is the displayed name of the shortcut.

After repository triggers are refreshed, the defined `manual` triggers appear
as dropdown menu items in the repository actions menu.

```yaml
triggers:
  - manual:
      name: Build
      entryPoint: main
  - manual:
      name: Deploy Prod
      entryPoint: deployProd
```

## Exclusive Triggers

There is an option to make a triggered processes "exclusive". This prevents
the process from running, if there are any other processes in the same project
with the same "exclusive group":

```yaml
flows:
  cronEvent:
    - log: "Hello!"
    - ${sleep.ms(65000)} # wait for 1m 5s

triggers:
  - cron:
      spec: "* * * * *" # run every minute
      timezone: "America/Toronto"
      entryPoint: cronEvent
```

In this example, if the triggered process runs longer than the trigger's period,
then it is possible that multiple `cronEvent` processes can run at the same
time. In some cases, it is necessary to enforce that only one trigger process
runs at a time, due to limitation in target systems being accessed or similar
reasons.
  
```yaml
triggers:
  - cron:
      spec: "* * * * *"
      timezone: "America/Toronto"
      entryPoint: cronEvent
      exclusive:
        group: "myGroup"
        mode: "cancel" # or "wait"
```

Any processes with the same `exclusive` value are automatically prevented from
starting, if a running process in the same group exists. If you wish to enqueue
the processes instead use `mode: "wait"`.

See also [Exclusive Execution](./concord-dsl.html#exclusive-execution) section
in the Concord DSL documentation.
