---
layout: wmt/docs
title:  Slack Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `slack` task supports posting messages on a channel of the
[Slack](https://slack.com/) messaging platform.

## Configuration

This task is provided automatically by Concord and the target Slack server
instance has to be
[configured as part of the server installation](../getting-started/configuration.html#slack).

The bot user created for the API token configuration e.g. `concord` has to be a
member of the channel receiving the messages.

## Usage

A message `text` can be sent to a specific channel identified by a `channelId`
with the long syntax or you can use the `call` method.

```yaml
flows:
  default:
    - task: slack
      in:
        channelId: "exampleId"
        username: "anyCustomString"
        iconEmoji: ":information_desk_person:"
        text: "Starting execution on Concord"
    - log: "Default flow running"
    - ${slack.call("exampleId", "Another message")}
```

The `channelId` can be seen in the URL of the channel or alternatively the name
of the channel can be used e.g. `C7HNUMYQ1` and `my-project-channel`.

Optionally, the message sender name appearing as the user submitting the post,
can be changed with `username`.  In addition, the optional `iconEmoji` can
configure the icon to use for the post.

# Slack Channel Task

The `slackChannel` task supports creating and archiving channels and groups of the
[Slack](https://slack.com/) messaging platform.

## Configuration

This task is provided automatically by Concord and the target Slack server
instance has to be
[configured as part of the server installation](../getting-started/configuration.html#slack).


Possible operations are: 

- [Create a channel](#create)
- [Archive a channel](#archive)
- [Create a group](#createGroup)
- [Archive a group](#archiveGroup)

The `slackChannel` task uses following input parameters

- `action`: Required - the name of the operation to perform.
- `channelName`: Required - the name of the slack channel that you want to create
- `channelId`: Required - the id of the slack channel that you want to archive
- `apiToken` Required - the [slack API token](https://api.slack.com/custom-integrations/legacy-tokens) for authentication and       authorization,typically this should be provided via usage of the [Crypto task](./crypto.html).

<a name="create"/>
## Create a channel

The `slackChannel` task can be used to create a new channel with the `create` action.

```yaml
flows:
  default:
  - task: slackChannel
    in:
      action: create
      channelName: myChannelName
      apiToken: mySlackApiToken
```

<a name="archive"/>
## Archive a channel

The `slackChannel` task can be used to archive an existing channel with the `archive` action.

```yaml
flows:
  default:
  - task: slackChannel
    in:
      action: archive
      channelId: C7HNUMYQ1
      apiToken: mySlackApiToken
```

The `channelId` can be seen in the URL of the channel  e.g. `C7HNUMYQ1`

<a name="createPriv"/>
## Create a group

The `slackChannel` task can be used to create a group with the `createGroup` action.

```yaml
flows:
  default:
  - task: slackChannel
    in:
      action: createGroup
      channelName: myChannelName
      apiToken: mySlackApiToken
```

<a name="archivePriv"/>
## Archive a group

The `slackChannel` task can be used to archive a group with the `archiveGroup` action.

```yaml
flows:
  default:
  - task: slackChannel
    in:
      action: archiveGroup
      channelId: C7HNUMYQ1
      apiToken: mySlackApiToken
```
