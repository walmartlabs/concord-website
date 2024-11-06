---
layout: wmt/docs
title:  MS Teams Task
side-navigation: wmt/docs-navigation.html
deprecated: true
description: Plugin for sending MS Teams messages
---

# {{ page.title }}

The `msteams` plugin supports interaction with the [Microsoft Teams](https://teams.microsoft.com/)
messaging platform.

- [Usage](#usage)
- [Version 2](#msteams-v2) (Recommended)
- [Version 1](#msteams-v1)

# Usage

To be able to use the `MSTeams` task in a Concord flow, it must be added as a
[dependency](../processes-v1/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:msteams-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the `MSTeams` task.


<a name="msteams-v2"/>

# Version 2

- [Why V2](#why-v2)
- [Prerequisite](#prerequisite-v2)
- [Common Parameters](#commonParameters)

Possible operations are:

- [Create Conversation](#create-conversation)
- [Reply To Conversation](#reply-to-conversation)


<a name="Why-v2"/>

## Why V2

We recommend users to use or move to `msteamsV2` for following reasons:

1. Unlike `V1`, adding `concord-bot` to a team, makes it available
for all public channels in a team.
2. Supports `replyToConversation` action.
3. Future enhancements (if any), will be made on `V2`.

<a name="prerequisite-v2"/>

## Prerequisite

Add `concord-bot` to your MS Team/channel. Follow below steps
to add it from MS Teams UI.

1. Click on ellipsis (3 dots) next to the Team you want to add the Bot to,
then click on Manage Team.
2. Click on `Apps` tab and then click on `More Apps` button.
3. In the new window opened, search for `concord-bot`.
4. Click on `open` dropdown and select `Add to a team`.
5. Type the team or channel name and click `Set up a bot`.

> Private channels do not support bots. Make sure your channel is not marked as `private`.
For more details check [here](https://docs.microsoft.com/en-us/microsoftteams/private-channels#what-you-need-to-know-about-private-channels).

<a name="commonParameters"/>

## Common Parameters

The `MSTeams` task uses a number of input parameters that are common for all
operations:

- `task` - determines name of task. Should be `msteamsV2` if you are using
version 2;
- `action` - determines the operation to be performed with the current
invocation of the `MSTeams` task.
- `ignoreErrors` - boolean value, if `true` any errors that occur during
the execution are ignored and stored in the `result` variable. Defaults to
`false`.

The `tenantId`, `useProxy`, `proxyAddress`, `proxyPort`,`clientId`,
`clientSecret`, `rootApi`, and `accessTokenApi` variables
configure the connection to the MS Teams server. They are
best configured globally as [default process configuration]
(../getting-started/configuration.html#default-process-variable)
with an `msteamsParams` argument.

```yaml
configuration:
  arguments:
    msteamsParams:
      tenantId: "myTenantID"
      useProxy: true
      proxyAddress: "proxy.example.com"
      proxyPort: 8080
      clientId: "botId"
      clientSecret: "botSecret"
      rootApi: "https://smba.trafficmanager.net/amer/v3/conversations"
      accessTokenApi: "https://login.microsoftonline.com/botframework.com/oauth2/v2.0/token"
```

- `useProxy` - boolean value, if `true` uses the `proxyAddress` and `proxyPort`
set in default vars. Defaults to `false`.
- `clientId` - determines the id associated with bot.
- `clientSecret` - determines the secret associated with bot.

**Note:** your Concord environment may provide other defaults using
the [default variables](../getting-started/configuration.html#default-process-variables).

### Create Conversation

The `createConversation` action allows users to create a new conversation in a specific MSTeams
channel. It uses input parameters listed below for the operation.

- `channelId`: string, required - the Id of the MS teams channel. It can be seen
in the URL opened by clicking  `3 dots -> Get link to channel` link next to your channel.
- `activity`: map, required - initial message to send to the conversation when it is created.
More details about `activity` object can be found [here](https://docs.microsoft.com/en-us/azure/bot-service/rest-api/bot-framework-rest-connector-api-reference?view=azure-bot-service-4.0#activity-object),
but a simple example can look like as shown below.

```yaml
flows:
  default:
  - task: msteamsV2
    in:
      action: createConversation
      activity:
        type: message
        text: "My First Message"
      channelId: "myChannelId"
      ignoreErrors: true

  - log: "Result status: ${result.ok}"
  - if: "${!result.ok}"
    then:
    - throw: "Error occurred while sending a message: ${result.error}"

  ...
```

The task returns a `result` object with following fields:

- `ok` - `true` if the operation is succeeded.
- `data` - string - response body, if the operation is succeeded.
- `error` - error message if the operation failed.
- `coversationId` - ID of the conversation that was posted, can be used,
in the following msteams task to reply to a conversation.
- `activityId` - ID of the activity, if sent.

### Reply To Conversation

The `replyToConversation` action allows users to reply to an existing
conversation in a specific MSTeams channel. It uses input parameters
listed below for the operation.

- `coversationId`: string, required - the Id of the conversation that was previously posted.
- `activity`: map, required - message used to reply to a conversation.

```yaml
- task: msteamsV2
    in:
      action: replyToConversation
      conversationId: ${result.conversationId}
      activity:
        type: message
        text: "This replies to a previously posted conversation"
```

<a name="msteams-v1"/>

# Version 1

- [Prerequisite](#prerequisite-v1)
- [Overview](#overview-v1)

Possible operations:

- [Send Message](#send-message)
   - [Using WebhookURL](#using-webhookurl)
   - [Using IDs (teamId/webhookId)](#using-ids)

<a name="prerequisite-v1"/>

## Prerequisite

Configure an `Incoming Webhook` on your Teams channel. Follow below steps to
configure it from MS Teams UI.

1. Navigate to the channel where you want to add the webhook and select
(•••) More Options from the top navigation bar
2. Choose Connectors from the drop-down menu and search for Incoming Webhook.
3. Select the Configure button, provide a name, and, optionally, upload an
image avatar for your webhook.
4. The dialog window presents a unique URL that maps to the channel. Copy and
save the URL—to use in a Concord flow. Sample webhook URL for reference
`https://outlook.office.com/webhook/{teamID}@{tenantID}/IncomingWebhook/{webhookID}/{webhookTypeID}`
5. Select the Done button. The webhook will now be available in the team channel.

<a name="overview-v1"/>

## Overview

The `MSTeams` task allows users to trigger operations on a Microsoft Teams server
as a step in a Concord flow. It uses a number of required input parameters that are
common for all operations:

- `action` - determines the operation to be performed with the current invocation
of the `MSTeams` task.
- `ignoreErrors` - boolean value, if `true` any errors that occur during the
execution are ignored and stored in the `result` variable. Defaults to `false`.

The `webhookTypeId`, `tenantId`, `rootWebhookUrl`, `proxyAddress`, and
`proxyPort` variables configure the connection to the MS Teams server. They are
best configured globally as
[default process configuration](../getting-started/configuration.html#default-process-variables)
with an `msteamsParams` argument.

- `webhookTypeId`: unique GUID of webhook type `Incoming Webhook`
- `tenantId`:  unique GUID representing the Azure ActiveDirectory Tenant
- `rootWebhookUrl`: root URL of webhook
- `proxyAddress`: proxy server to use
- `proxyPort`: proxy server port to use

Extract `webhookTypeId` and `tenantId` from webhook URL from step 4 of [Prerequisite](#prerequisite)

```yaml
configuration:
  arguments:
    msteamsParams:
      webhookTypeId: "myWebhookTypeID"
      tenantId: "myTenantID"
      rootWebhookUrl: "https://outlook.office.com/webhook/"
      proxyAddress: "proxy.example.com"
      proxyPort: 8080
```

## Send Message

The `sendMessage` action allows users to send messages to a specific MSTeams
channel. It uses input parameters listed below for the operation.

- `webhookUrl`: URL, required - webhook URL from step 4 of [Prerequisite](#prerequisite).
- `title`: string, optional - title of the message.
- `text`: string, required - body of the message.
- `themeColor`: string, optional - theme color of the message. Defaults to
`11B00A`. More theme colors can be found [here](https://htmlcolorcodes.com/)
to pick from.
- `sections`: array, optional - a collection of sections to include in a message.
See [sections](https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#section-fields)
for more details.
- `potentialAction`: array, optional - a collection of actions that can be
invoked on a message. See [potentialAction](https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#actions)
for more details.

### Using WebhookURL

Initiate `sendMessage` action using `webhookUrl`

```yaml
flows:
  default:
    - task: msteams
      in:
        action: sendMessage
        webhookUrl: https://outlook.office.com/webhook/{teamID}@{tenantID}/IncomingWebhook/{webhookID}/{webhookTypeID}
        title: "My message title"
        text: "My message text"
        ignoreErrors: true

    - if: "${!result.ok}"
      then:
        - throw: "Error while sending a message: ${result.error}"
      else:
        - log: "Data: ${result.data}"
```

### Using IDs

Initiate `sendMessage` action using `teamId` and `webhookId` extracted from
webhook URL from step 4 of [Prerequisite](#prerequisite)

- `teamId`: string, required - team ID
- `webhookId`: string, required - webhook ID

```yaml
flows:
  default:
    - task: msteams
      in:
        action: sendMessage
        teamId: "myTeamID"
        webhookId: "myWebhookID"
        title: "My message title"
        text: "My message text"
        ignoreErrors: true

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
