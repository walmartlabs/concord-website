---
layout: wmt/docs
title:  Jira Task
side-navigation: wmt/docs-navigation.html
deprecated: true
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
[dependency](../processes-v1/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:jira-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the
[Jira task](#overview).

> Versions 0.49.1 and older of the JIRA task used a different, incompatible
> implementation of the task. Please migrate to the new actions documented here
> when upgrading from these versions.

<a name="overview"/>

## Overview

The `jira` task allows users to trigger operations on a Jira server as a step of
a flow. It uses a number of required input parameters that are common for all
operations:

- `apiUrl` -  URL to the API endpoint of the Jira server, e.g `https://jira.example.com/rest/api/2/`
- `action` - determines the operation to be performed with the current invocation of the Jira task
- `auth` - one of the following authentication types:
  - `accessToken`: string, access token to be used for authentication.
  - `basic`:
    - `username`: string value, identifier of the Confluence user account to use for the
      interaction
    - `password`: string value, password for the user account to use, typically
      this should be provided via usage of the [Crypto task](./crypto.html) to
      access a password stored in Concord or decrypt an encrypted password string.
  - `secret`:
    - `org`: string, optional, name of the organization where the secret is
      stored. If not provided, the current organization is used.
    - `name`: string, name of the secret where the credentials are stored.
    - `password`: string, optional, decryption password for the secret
- `debug` - Optional, if true enables additional debug output. Default is set to `false`

The `apiUrl` configures the URL to the Jira REST API endpoint. It is best
configured globally as
[default process configuration](../getting-started/configuration.html#default-process-variables):
with a `jiraParams` argument:

```yaml
configuration:
  arguments:
    jiraParams:
      apiUrl: "https://jira.example.com/rest/api/2/"
```

<a name="authentication"/>

## Authentication

A minimal configuration to get authenticated from a globally configured API URL
includes the `username`, the `password`.

```yaml
- task: jira
  in:
    auth:
      basic: "${crypto.exportCredentials('my-org', 'my-creds', null)}"
```

Personal Access Tokens can be used with the `accessToken` authentication type:

```yaml
- task: jira
  in:
    auth:
      accessToken: "${crypto.exportAsString('my-org', 'my-token', null)}"
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
      auth:
        accessToken: "..."
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
      auth:
        accessToken: "..."
      issueKey: "MYISSUEKEY"
      fields:
        summary: "mySummary123"
        description: "myDescription123"
        assignee:
          name: "myuser"
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
      auth:
        accessToken: "..."
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
      auth:
        accessToken: "..."
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
      auth:
        accessToken: "..."
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
      auth:
        accessToken: "..."
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
      auth:
        accessToken: "..."
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
      auth:
        accessToken: "..."
      issueKey: "MYISSUEKEY"
```

After the action runs, the current status of an issue is available in the
`issueStatus` variable.

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
      auth:
        accessToken: "..."
      projectKey: "MYPROJECTKEY"
      issueType: Bug
      issueStatus: Done
      statusOperator: "!="
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
      auth:
        accessToken: "..."
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

After the action runs, the identifier for the fetched issue id list is available
in the `issueList` variable and total count of issues fetched is available in
`issueCount`variable that can used at later point in the flow.