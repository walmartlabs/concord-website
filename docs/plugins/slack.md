---
layout: wmt/docs
title:  Slack Tasks
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `slack` plugin supports interaction with the [Slack](https://slack.com/)
messaging platform.

- posting messages to a channel with the [slack task](#slack)
- working with channels and groups with the [slackChannel task](#slack-channel)

## Configuration

This slack plugin is provided automatically by Concord and the target Slack server
instance has to be
[configured as part of the server installation](../getting-started/configuration.html#slack).

The bot user created for the API token configuration e.g. `concord` has to be a
member of the channel receiving the messages.

<a name="slack"/>

## Slack Task

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
        text: "Starting execution on Concord, process ID ${txId}"

    - if: "${!result.ok}"
      then:
        - log: "Error while sending a message: ${result.error}"

    ...

    - task: slack
      in:
        channelId: "exampleId"
        ts: ${result.ts}
        username: "anyCustomString"
        iconEmoji: ":information_desk_person:"
        text: "Execution on Concord for process ID ${txId} completed."
```

The `channelId` can be seen in the URL of the channel or alternatively the name
of the channel can be used e.g. `C7HNUMYQ1` and `my-project-channel`. To send a
message to a specific user use `@handle` syntax:

```yaml
- task: slack
  in:
    channelId: "@someone"
    text: "Hi there!"
```

Not that `@handle` works only for users that did not change their _Display Name_
in their Slack profiles.

Optionally, the message sender name appearing as the user submitting the post,
can be changed with `username`.  In addition, the optional `iconEmoji` can
configure the icon to use for the post.

The task returns a `result` object with three fields:

- `ok` - `true` if the operation succeeded;
- `error` - error message if the operation failed.
- `ts` -  Timestamp ID of the message that was posted, can be used, in the
  following slack task of posting message, to make the message a reply.

The optional field from the result object `ts` can be used to create
a thread and reply. Avoid using a reply's `ts` value; use it's parent instead.

## Slack Channel Task

The `slackChannel` task supports creating and archiving channels and groups of the
[Slack](https://slack.com/) messaging platform.

Possible operations are:

- [Create a channel](#create)
- [Archive a channel](#archive)
- [Create a group](#create-group)
- [Archive a group](#archive-group)

The `slackChannel` task uses following input parameters

- `action`: required, the name of the operation to perform `create`, `archive`,
  `createGroup` or `archiveGroup`
- `channelName` the name of the slack channel or group you want to create,
  required for `create` and `createGroup` that you want to create or
- `channelId`: the id of the slack channel that you want to archive, required
  for `archive` and `archiveGroup`
- `apiToken`: required, the
  [slack API token](https://api.slack.com/custom-integrations/legacy-tokens) for
  authentication and authorization. The owner of the token as has to have
  sufficient access rights to create or archive channels and groups. Typically
  this should be provided via usage of the [Crypto task](./crypto.html).


<a name="create"/>
### Create a Channel

This `slackChannel` task can be used to create a new channel with the `create` action.

```yaml
flows:
  default:
  - task: slackChannel
    in:
      action: create
      channelName: myChannelName
      apiToken: mySlackApiToken
  - log: "Channel ID: ${slackChannelId}"
```

The identifier of the created channel is available in the context after the
successful task execution output variable as `slackChannelId`.

<a name="archive"/>
### Archive a Channel

This `slackChannel` task can be used to archive an existing channel with the
`archive` action.

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

<a name="create-group"/>
### Create a Group

This `slackChannel` task can be used to create a group with the `createGroup`
action.

```yaml
flows:
  default:
  - task: slackChannel
    in:
      action: createGroup
      channelName: myChannelName
      apiToken: mySlackApiToken
  - log: "Group ID: ${slackChannelId}"
```

The identifier of the created group is available in the context after the
successful task execution output variable as `slackChannelId`.

<a name="archive-group"/>
### Archive a Group

This `slackChannel` task can be used to archive an existing group with the
`archiveGroup` action.

```yaml
flows:
  default:
  - task: slackChannel
    in:
      action: archiveGroup
      channelId: C7HNUMYQ1
      apiToken: mySlackApiToken
```
