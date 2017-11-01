---
layout: wmt/docs
title:  Slack Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `slack` task supports posting messages on a channel of the
[Slack](https://slack.com/) messaging platform.

## Configuration

This task is provided automatically by the Concord and the target Slack server
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
        text: "Starting execution on Concord"
    - log: "Default flow running"
    - ${slack.call("exampleId", "Another message")}
```

The `channelId` can be seen in the URL of the channel or alternatively the name
of the channel can be used e.g. `C7HNUMYQ1` and `my-project-channel`.