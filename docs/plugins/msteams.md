---
layout: wmt/docs
title:  MSTeams Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `msteams` plugin supports interaction with the [Microsoft Teams](https://teams.microsoft.com/)
messaging platform.

- [Prerequisite](#prerequisite)
- [Usage](#usage)
- [Overview](#overview)
    
Possible operations are:

- [Send Message](#send-message)
   - [Using WebhookUrl](#using-webhookUrl)
   - [Using IDs (teamId/webhookId)](#using-ids)

# Prerequisite

Configure an `incoming webhook` on your Teams channel. Follow below steps to
configure it from MS Teams UI.

1. Navigate to the channel where you want to add the webhook and select
(•••) More Options from the top navigation bar
2. Choose Connectors from the drop-down menu and search for Incoming Webhook.
3. Select the Configure button, provide a name, and, optionally, upload an
image avatar for your webhook.
4. The dialog window presents a unique URL that maps to the channel. Copy and
save the URL—to use in a Concord flow. Sample `webhookUrl` for reference
`https://outlook.office.com/webhook/{teamID}@{tenantID}/IncomingWebhook/{webhookID}/{webhookTypeID}`
5. Select the Done button. The webhook will now be available in the team channel.

# Usage

To be able to use the `MSTeams` task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:msteams-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the `MSTeams` task.

# Overview

The `MSTeams` task allows users to trigger operations on a Microsoft Teams server
as a step in a Concord flow. It uses a number of required input parameters that are
common for all operations:

- `action` - determines the operation to be performed with the current
  invocation of the `MSTeams` task
- `ignoreErrors` - boolean value, if `true` any errors that occur during the
  execution are ignored and stored in the `result` variable. Defaults to
  `false`.

<a name="send-message"/>

## Send Message

The `sendMessage` action allows users to send messages to a specific MSTeams
channel. It uses input parameters listed below for the operation. 

- `webhookUrl`: URL, required - webhookUrl got from step 4 of [Prerequisite](#prerequisite).
- `title`: string, optional - title of the message.
- `text`: string, required - body of the message.
- `themeColor`: string, optional - theme color of the message. Defaults to
`11B00A`. More theme colors can be found [here](https://htmlcolorcodes.com/)
to pick from.
- `sections`: array, optional - a collection of sections to include in
a message. See [sections](https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#section-fields)
for more details.
- `potentialAction`: array, optional - a collection of actions that can be
invoked on a message. See [potentialAction](https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference#actions)
for more details.

<a name="using-webhookUrl"/>

### Using WebhookUrl

Initiating `sendMessage` action using `webhookUrl`

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

<a name="using-ids"/>

### Using IDs

Initiating `sendMessage` action using `teamId` and `webhookId` got from `webhookUrl`

- `teamId`: string, required - team ID
- `webhookId`: string, required - webhook ID

```yaml
flows:
  default:
    - task: msteams
      in:
        action: sendMessage
        teamId: "6d97d054-8882-59f8-be19-052934402f09"
        webhookId: "ec83079e7d2b5680886b1138966c46d9c"
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
