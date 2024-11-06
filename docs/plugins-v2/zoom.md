---
layout: wmt/docs
title:  Zoom Tasks
side-navigation: wmt/docs-navigation.html
description: Plugin for sending Zoom messages
---

# {{ page.title }}

The `zoom` plugin supports interaction with the [Zoom](https://zoom.us/)
messaging platform.

- [Usage](#usage)
- [Overview](#overview)

Possible operations are:

- [Send Message](#send-message)

<a name="usage"/>

## Usage

To be able to use the `Zoom` task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:zoom-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the `Zoom` task.

<a name="overview"/>

## Overview

The `Zoom` task allows users to trigger operations on a Zoom server
as a step in a flow. It uses a number of required input parameters that are
common for all operations:

- `action` - determines the operation to be performed with the current
  invocation of the `Zoom` task
- `ignoreErrors` - boolean value, if `true` any errors that occur during the
  execution are ignored and stored in the `result` variable. Defaults to
  `false`.

The `clientId`, `clientSecret`, `robotJid`, `accountId`, `rootApi` and
`accessTokenApi` variables configure the connection to the MS Teams server. It
is best configured globally by a
[default process configuration](../getting-started/policies.html#default-process-configuration-rule)
policy:

```json
{
  "defaultProcessCfg": {
    "defaultTaskVariables": {
      "zoom": {
        "clientId": "botId",
        "clientSecret": "botSecret",
        "robotJid": "botJid",
        "accountId": "zoomAccountId",
        "rootApi": "zoomRootApi",
        "accessTokenApi": "zoomAccessTokenApi"
      }
    }
  }
}
```

For more details about each parameter refer to the [api docs](https://marketplace.zoom.us/docs/guides/chatbots/send-edit-and-delete-messages#send-messages).

<a name="send-message"/>

## Send Message

The `sendMessage` action allows users to send messages to a specific Zoom channel
identified by a `channelId`. It uses input parameters listed below for the operation:

- `channelId` - string, Required - The JID of the Channel you want to send message to.
- `headText` - string, Required - text that goes into message head.
- `bodyText` - string, optional - text that goes into the message body.

```yaml
flows:
  default:
  - task: zoom
    in:
      action: sendMessage
      channelId: "myZoomChannelId"
      headText: "Hello to concord world"
      bodyText: "Hello everyone"
      ignoreErrors: true
    out: result

  - if: "${!result.ok}"
    then:
      - throw: "Error while sending a message: ${result.error}"
    else:
      - log: "Data: ${result.data}"
```

The task returns a `result` object with three fields:

- `ok` - `true` if the operation is succeeded.
- `data` - string - response body, if the operation is succeeded.
- `error` - error message if the operation failed.
