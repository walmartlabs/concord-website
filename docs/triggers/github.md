---
layout: wmt/docs
title:  GitHub Triggers
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Currently Concord supports two different implementations of `github` triggers:
`version: 1` and `version: 2`. The latter has cleaner syntax and is more
straightforward to use in complex use cases like listening for multiple
repositories.

- [Version 1](#github-v1)
- [Version 2](#github-v2)
- [Migration](#github-migration)
- [Examples](#examples)
  - [Push Notifications](#push-notifications)
  - [Pull Requests](#pull-requests)
  - [Organization Events](#organization-events)
  - [Common Events](#common-events)

The default version is configured in [the server configuration file](../getting-started/configuration.html#server-cfg-file).
Ask your Concord instance's administrator which version is the default version
for your environment.

<a name="github-v2"/>

## Version 2

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
- `conditions` key-value, mandatory, conditions for GitHub event matching;
- `version` - number, optional if matches the default version of the current
Concord instance. Trigger implementation's version.

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

The `event` object provides all attributes from trigger conditions filled with
GitHub event.

Refer to the GitHub's [Webhook](https://developer.github.com/webhooks/)
documentation for the complete list of event types and `payload` structure.

**Note:** Normally, Concord automatically reload trigger definitions for all
registered repositories. However, in some cases, such as using personal
repositories or using a Concord environment without GitHub webhooks installed,
you need to manually refresh the repository by clicking on the `Refresh` button
on the `Repository` page of Concord UI or
[using the API](../api/repository.html#refresh-repository).

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
  `opened` or `closed`. A complete list of values can be found
  [here](https://developer.github.com/v3/activity/events/types/#pullrequestevent);
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

## Migration

Notable differences in `github` triggers between [version 1](#github-v1) and
[version 2](#github-v2):

Trigger conditions are moved into a `conditions` field:

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

The `event` variable structure is different:

- `${event.author}` is replaced with `${event.sender}` to closely match the
original data received from GitHub;
- `${event.org}` and `${event.project}` are gone. It's not possible to
provide this data while simultaneously support triggers for repositories
that are not registered in Concord (i.e. in typical GitOps use cases).

## Examples

### Push Notifications

To listen for all commits into the branch configured in the project's
repository:

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
    version: 2
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
    version: 2
    entryPoint: "onPr"
    conditions:
      type: "pull_request"
      status: "opened"
      branch: ".*"
```

To trigger a process when a new PR is opened or commits are added to the existing PR:

```yaml
- github:
    version: 2
    entryPoint: "onPr"
    conditions:
      type: "pull_request"
      status: "(opened|synchronize)"
      branch: ".*"
```

To trigger a process when a PR is merged:

```yaml
- github:
    version: 2
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
    version: 2
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
    version: 2
    entryPoint: "onTeamChange"
    conditions:
      type: "membership"
      githubRepo: ".*"
```

To trigger a process when a team is added to the current repository:

```yaml
- github:
    version: 2
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
    entryPoint: onEvent
    conditions:
      githubOrg: ".*"
      githubRepo: ".*"
      branch: ".*"
```

**Note:** subscribing to all GitHub events can be restricted on the system
policy level. Ask your Concord instance administrator if it is allowed in your
environment.
