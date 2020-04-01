---
layout: wmt/docs
title:  Zoom Tasks
side-navigation: wmt/docs-navigation.html
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
[dependency](../processes-v1/configuration.html#dependencies):

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

    - if: "${!result.ok}"
    then:
    - throw: "Error while sending a message: ${result.error}"
    else:
    - log: "Data: ${result.data}"
```
Walmart users can get the `channelId` by one of the following approaches:
Go to a Zoom chat channel and type,

`/getchanneldetails list`

This will display a list of channels the user `(who typed the slash command)` 
has access to. Click on a channel in the list to see the JID of that channel.

`/getchanneldetails details`

This will display the channel JID and channel name of the channel the command was typed 
in, as well as the Account ID.

In general Users can get the `channelId` from the Chatbot request sent to the server. 
Refer to the example [here](https://marketplace.zoom.us/docs/guides/chatbots/sending-messages#receive).

The task returns a `result` object with three fields:

- `ok` - `true` if the operation is succeeded.
- `data` - string - response body, if the operation is succeeded.
- `error` - error message if the operation failed.  
