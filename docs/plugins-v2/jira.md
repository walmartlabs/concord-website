---
layout: wmt/docs
title:  Jira Task
side-navigation: wmt/docs-navigation.html
description: Plugin for interacting with Atlassian's Jira API
---

# {{ page.title }}

The `jira` task supports operations on the popular issue tracking system
[Atlassian Jira](https://www.atlassian.com/software/jira).

- [Usage](#usage)
- [Overview](#overview)
- [Authentication](#authentication)

Possible operations are:

- [Create an Issue](#createIssue)
- [Create a Subtask](#createSubtask)
- [Update an Issue](#updateIssue)
- [Add a comment](#addComment)
- [Add an Attachment](#addAttachment)
- [Transition an Issue](#transitionIssue)
- [Delete an Issue](#deleteIssue)
- [Create a Component](#createComponent)
- [Delete a Component](#deleteComponent)
- [Get Current Status](#getStatus)
- [Get Issues](#getIssues)

<a name="usage"/>

## Usage

To be able to use the `jira` task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:jira-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the
[Jira task](#overview).

<a name="overview"/>

## Overview

The `jira` task allows users to trigger operations on a Jira server as a step of
a flow. It uses a number of required input parameters that are common for all
operations:

- `apiUrl` -  URL to the API endpoint of the Jira server, e.g `https://jira.example.com/rest/api/2/`
- `action` - determines the operation to be performed with the current invocation of the Jira task
- `userId` -  identifier of the user account to use for the interaction
- `password` -  password for the user account to use, typically this should be
provided via usage of the [Crypto task](./crypto.html)
- `auth` - authentication used for jira.
- `debug` - Optional, if true enables additional debug output. Default is set to `false`

The `apiUrl` configures the URL to the Jira REST API endpoint. It is best
configured globally by a
[default process configuration](../getting-started/policies.html#default-process-configuration-rule)
policy:

```json
{
  "defaultProcessCfg": {
    "defaultTaskVariables": {
      "jira": {
        "apiUrl": "https://jira.example.com/rest/api/2/"
      }
    }
  }
}
```

<a name="authentication"/>

## Authentication
A minimal configuration to get authenticated from a globally configured API URL
includes the `userId`, the `password`.

```yaml
flows:
  default:
  - task: jira
    in:
      action: createIssue
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      ...
```

`username` and `password` can also be provided as:

```yaml
- task: jira
  in:
    auth:
      basic:
        username: "..."
        password: "..."

```

`USERNAME_PASSWORD` type secrets can also be used to provide the credentials:

```yaml
- task: jira
  in:
    auth:
      secret:
        org: "..." # optional
        name: "..."
        password: "..." # optional
```

<a name="createIssue"/>

## Create an Issue

The JIRA task can be used to create a new issue with the `createIssue` action.

```yaml
flows:
  default:
  - task: jira
    in:
      action: createIssue
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      projectKey: MYPROJECT
      summary: mySummary
      description: myDescription
      requestorUid: "${initiator.username}"
      issueType: "Bug"
      priority: P4
      labels: ["myLabel1","myLabel2"]
      components: [{"name": "myComponent1"},{"name": "myComponent1"}]
      customFieldsTypeKv: {"customfield_10212": "mycustomfield_10212","customfield_10213": "mycustomfield_10213"}
      customFieldsTypeFieldAttr:
        customfield_10216:
                    value: "mycustomfield_10216"
        customfield_10212:
                    value: "mycustomfield_10212"
    out: result
  - if: ${result.ok}
    then:
      - log: "Created issue: ${result.issueId}"
    else:
      - log: "Error creating issue: ${result.error}"
```

Additional parameters to use are:

- `projectKey` - identifying key for the project
- `summary` - summary text
- `description` - description text
- `issueType` -  name of the issue type
- `components` - list of components to add
- `labels` - list of labels to add
- `requestorUid` - identifier of the user account to be used as the requestor
- `customFieldsTypeKv` - list of custom fields of type key->value
- `customFieldsTypeFieldAttr` - list of custom fields of type fieldAttribute

After the action runs, the identifier for the created issue is available in the
`issueId` variable.

> To see possible values for custom fields we recommend using the `issue` API endpoint
> on an existing ticket and inspect the return object e.g.
> https://jira.example.com/rest/api/2/issue/{issueId}

<a name="createSubtask"/>

## Create a Subtask

The JIRA task can be used to create a subtask for an existing issue with the
`createSubtask` action. It requires a `parentIssueKey` parameter and accepts the
same parameters as the [`createIssue`](#create-an-issue) action;

```yaml
flows:
  default:
  - task: jira
    in:
      action: createSubtask
      parentIssueKey: "MYISSUEKEY"
      # see parameters for createIssue
    out: result
  - if: ${result.ok}
    then:
      - log: "Created issue: ${result.issueId}"
    else:
      - log: "Error creating issue: ${result.error}"
```

<a name="updateIssue"/>

## Update an Issue

The JIRA task can be used to update an issue with the `updateIssue` action.

```yaml
flows:
  default:
  - task: jira
    in:
      action: updateIssue
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      issueKey: "MYISSUEKEY"
      fields:
        summary: "mySummary123"
        description: "myDescription123"
        assignee:
          name: "my-user"
```

Additional parameters to use are:

- `issueKey` - the identifier of the issue
- `summary` - summary text
- `description` - description text
- `assignee` -  name of the assignee of issue

<a name="addComment"/>

## Add a comment

The JIRA task can be used to add a comment to an existing issue with the
`addComment` action.

```yaml
flows:
  default:
  - task: jira
    in:
      action: addComment
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      issueKey: "MYISSUEKEY"
      comment: "This is my comment from concord"
```

Additional parameters to use are:

- `issueKey` - the identifier of the issue

<a name="addAttachment"/>

## Add an Attachment

The JIRA task can be used to add attachment to an existing issue with the
`addAttachment` action.

```yaml
flows:
  default:
  - task: jira
    in:
      action: addAttachment
      ...
      issueKey: "MYISSUEKEY"
      filePath: "path/to/file"
```

The `filePath` must be relative to the process' `workDir`.

<a name="transitionIssue"/>

## Transition an Issue

The JIRA task can be used to transition an existing issue with the `transition`
action. It moves the project from one status to another e.g. from backlog to
work in progress, from ready for review to done and others.

```yaml
flows:
  default:
  - task: jira
    in:
      action: transition
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      issueKey: "MYISSUEKEY"
      transitionId: 561
      transitionComment: "Marking as Done"
```

Additional parameters to use are:

- `issueKey` - the identifier of the issue
- `transitionId` - identifier to use for the transition
- `transitionComment` - comment to add to the transition

Custom fields can be specified like in [issue creation](#createIssue).

<a name="deleteIssue"/>

## Delete an Issue

The JIRA task can be used to delete an existing issue with the `deleteIssue`
action and the identifier for the issue in `issueKey`.

```yaml
flows:
  default:
  - task: jira
     in:
      action: deleteIssue
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      issueKey: "MYISSUEKEY-123"
```

<a name="createComponent"/>

## Create a new Component

The JIRA task can be used to create a new component for a given JIRA project
with the `createComponent` action.

```yaml
flows:
  default:
  - task: jira
    in:
      action: createComponent
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      projectKey: "MYPROJECTKEY"
      componentName: "MYCOMPONENT"
```

Additional parameters to use are:

- `projectKey` - identifying key for the project
- `componentName` - name for the new component

<a name="deleteComponent"/>

## Delete a Component

The JIRA task can be used to delete a component with the `deleteComponent` action
the identifier of the component in `componentId`.

```yaml
flows:
  default:
  - task: jira
    in:
      action: deleteComponent
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      componentId: 33818
```

<a name="getStatus"/>

## Get Current Status

The JIRA task can be used to get the current status of an existing issue with the
`currentStatus` action.

```yaml
flows:
  default:
  - task: jira
    in:
      action: currentStatus
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      issueKey: "MYISSUEKEY"
  - if: ${result.ok}
    then:
      - log: "Issue status: ${result.issueStatus}"
    else:
      - log: "Error getting issue status: ${result.error}"
```

<a name="getIssues"/>

## Get Issues

The JIRA task can be used to get the count and list of all issue ids for given
JIRA project based on a given issue type and its status with the `getIssues`
action. Below example fetches list of all issue ids that matches
`project = MYPROJECTKEY AND issueType = Bug AND issueStatus != Done`

```yaml
flows:
  default:
  - task: jira
    in:
      action: getIssues
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      projectKey: "MYPROJECTKEY"
      issueType: Bug
      issueStatus: Done
      statusOperator: "!="
  - if: ${result.ok}
    then:
      - log: "Found ${result.issueCount} issue(s)"
      - log: "Issue IDs: ${result.issueList}"
    else:
      - log: "Error getting issue status: ${result.error}"
```

**Note:** The provided filter values are inserted into a
[JQL query](https://confluence.atlassian.com/jiracoreserver0813/advanced-searching-1027139119.html)
and may require escaping or extra quoting. The below example results in the
corresponding JQL query: `project = MYPROJECTKEY AND issueType = Support\ Ticket AND issueStatus != 'Work in Progress'`

```yaml
flows:
  default:
  - task: jira
    in:
      action: getIssues
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      projectKey: "MYPROJECTKEY"
      issueType: "Support\\ Ticket"      # escape spaces
      issueStatus: "'Work in Progress'"  # or use extra quotes
      statusOperator: "!="
```

Additional parameters to use are:

- `projectKey` - string, Required - identifying key for the project.
- `issueType` -  string, Required - name of the issue type that you want to query against.
- `statusOperator` - string, Optional - operator used to compare againt `issueStatus`. Accepted values are `=` and `!=`. Default is set to `=`.
- `issueStatus` - string, Optional - status of the issue that you want to query against. If not set, fetches all issue ids for a given `projectKey` and `issueType`
