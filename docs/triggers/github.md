---
layout: wmt/docs
title:  GitHub Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

- [Usage](#usage)
- [Examples](#examples)
  - [Push Notifications](#push-notifications)
  - [Pull Requests](#pull-requests)
  - [Organization Events](#organization-events)
  - [Common Events](#common-events)

## Usage

The `github` event source allows Concord to receive `push` and `pull_request`
notifications from GitHub. Here's an example:

```yaml
flows:
  onPush:
  - log: "${event.sender} pushed ${event.commitId} to ${event.payload.repository.full_name}"
  
triggers:
- github:
    useInitiator: true
    entryPoint: onPush
    conditions:
      type: push
```

Github trigger supports the following attributes

- `entryPoint` - string, mandatory, the name of the flow that Concord starts
when GitHub event matches trigger conditions;
- `activeProfiles` - list of strings, optional, list of profiles that Concord
applies for process;
- `useInitiator` - boolean, optional, process initiator is set to `sender` when
this attribute is marked as `true`;
- `useEventCommitId` - boolean, optional, Concord will use the event's commit
ID to start the process;
- `ignoreEmptyPush` - boolean, optional, if `true` Concord skips empty `push`
notifications, i.e. pushes with the same `after` and `before` commit IDs.
Default value is `true`;
- `exclusive` - key-value, optional, exclusive execution configuration for process;
- `arguments` - key-value, optional, additional parameters that are passed to
the flow;
- `conditions` - key-value, mandatory, conditions for GitHub event matching.

Possible GitHub trigger `conditions`:

- `type` - string, mandatory, GitHub event name;
- `githubOrg` - string or regex, optional, GitHub organization name. Default is
the current repository's GitHub organization name;
- `githubRepo` - string or regex, optional, GitHub repository name. Default is
the current repository's name;
- `githubHost` - string or regex, optional, GitHub host;
- `branch` - string or regex, optional, event branch name;
- `sender` - string or regex, optional, event sender;
- `status` - string or regex, optional. For `pull_request` notifications
possible values are `opened` or `closed`. A complete list of values can be
found [here](https://developer.github.com/v3/activity/events/types/#pullrequestevent);
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

The `exclusive` section in the trigger definition can be used to configure
exclusive execution of the process:

```yaml
triggers:
  - github:
      useInitiator: true
      entryPoint: onPush
      exclusive:
        groupBy: "branch"
        mode: "cancelOld"
      conditions:
        type: push
```

In the example above, if another process in the same project with the same github branch 
is running, it will be immediately cancelled.

The `exclusive` entry have the following structure:
- `group` - string, optional;
- `groupBy` - string, optional, allowed values: 
  - `branch` - processes grouped by branch name;
- `mode` - string, mandatory, allowed values: 
  - `cancel` - new process in the same `group` will be cancelled;
  - `cancelOld` - all running processes in the same `group` that starts before current will be cancelled;
  - `wait` - only one process in the same `group` is allowed to run.

**Note:** this feature available only for project processes.

The `event` object provides all attributes from trigger conditions filled with
GitHub event.

Refer to the GitHub's [Webhook](https://developer.github.com/webhooks/)
documentation for the complete list of event types and `payload` structure.

**Note:** standard [limitations](./index.html#limitations) apply.

## Examples

### Push Notifications

To listen for all commits into the branch configured in the project's
repository:

```yaml
- github:
    entryPoint: "onPush"
    conditions:
      type: "push"
```

The following example trigger fires when someone pushes to a development branch
with a name starting with `dev-`, e.g. `dev-my-feature`, `dev-bugfix`, and
ignores pushes on branch deletes:

```yaml
- github:
    entryPoint: "onPush"
    conditions:
      branch: "^dev-.*$"
      type: "push"
      payload:
        deleted: false
```

The following example trigger fires when someone pushes/merges into master, but
ignores pushes by `jenkinspan` and `anothersvc`:

```yaml
- github:
    entryPoint: "onPush"
    conditions:
      type: "push"
      branch: "master"
      sender: "^(?!.*(jenkinspan|anothersvc)).*$"
```

### Pull Requests

To receive a notification when a PR is opened: 

```yaml
- github:
    entryPoint: "onPr"
    conditions:
      type: "pull_request"
      status: "opened"
      branch: ".*"
```

To trigger a process when a new PR is opened or commits are added to the existing PR:

```yaml
- github:
    entryPoint: "onPr"
    conditions:
      type: "pull_request"
      status: "(opened|synchronize)"
      branch: ".*"
```

To trigger a process when a PR is merged:

```yaml
- github:
    entryPoint: "onPr"
    conditions:
      type: "pull_request"
      status: "closed"
      branch: ".*"
      payload:
        pull_request:
          merged: true
```

The next example trigger only fires on pull requests that have the label `bug`:

```yaml
- github:
    entryPoint: "onBug"
    conditions:
      type: "pull_request"
      payload:
        pull_request:
          labels:
          - { name: "bug" }
```

### Organization Events

To receive notifications about team membership changes in the current project's
organization:

```yaml
- github:
    entryPoint: "onTeamChange"
    conditions:
      type: "membership"
      githubRepo: ".*"
```

To trigger a process when a team is added to the current repository:

```yaml
- github:
    entryPoint: "onTeamAdd"
    conditions:
      type: "team_add"
```



### Common Events

If `https://github.com/myorg/producer-repo` is registered in Concord as
`producerRepo`, put `producerRepo` in `repository` field under `repositoryInfo`
as shown below. The following trigger will receive all matching events for the
registered repository:

```yaml
- github:
    entryPoint: onPush
    conditions:
      repositoryInfo:
        - repository: producerRepo
```

Regular expressions can be used to subscribe to *all* GitHub repositories
handled by the registered webhooks:

```yaml
- github:
    entryPoint: onEvent
    conditions:
      githubOrg: ".*"
      githubRepo: ".*"
      branch: ".*"
```

**Note:** subscribing to all GitHub events can be restricted on the system
policy level. Ask your Concord instance administrator if it is allowed in your
environment.
