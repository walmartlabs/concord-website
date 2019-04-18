---
layout: wmt/docs
title:  Jira Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `jira` task supports operations on the popluar issue tracking system
[Atlassian Jira](https://www.atlassian.com/software/jira).

- [Usage](#usage)
- [Overview](#overview)

Possible operations are: 

- [Create an Issue](#createIssue)
- [Update an Issue](#updateIssue)
- [Add a comment](#addComment)
- [Transition an Issue](#transitionIssue)
- [Delete an Issue](#deleteIssue)
- [Create a Component](#createComponent)
- [Delete a Component](#deleteComponent)

<a name="usage"/>
## Usage

To be able to use the `jira` task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

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
- `action` - determines the operation to be performed with the currennt invocation of the Jira task
- `userId` -  identifier of the user account to use for the interaction
- `password` -  password for the user account to use, typically this should be
provided via usage of the [Crypto task](./crypto.html)

The `apiUrl` configures the URL to the Jira REST API endpoint. It is best
configured globally as 
[default process configuration](../getting-started/configuration.html#default-process-variable):
with a `jiraParams` argument:

```yaml
configuration:
  arguments:
    jiraParams:
      apiUrl: "https://jira.example.com/rest/api/2/"
```

A minimal configuration taking advantage of a globally configured API URL
includes the `userId`, the `password`, the desired `action` to perform and any
additional parameters need for the action:

```yaml
flows:
  default:
  - task: jira
    in:
      action: createIssue
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      ....
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
```

Additional parameters to use are:

- `projectKey` - identifying key for the project
- `summary` - summary text
- `description` - description text
- `issueType` -  name the issue type
- `components` - list of components to add 
- `labels` - list of labels to add
- `requestorUid` - identifier of the user account to be used as the requestor
- `customFieldsTypeKv` - list of custom fields of type key->value
- `customFieldsTypeFieldAttr` - list of custom fields of type fieldAttribute

> To see possible values for custom fields we recommend to use the `issue` endpoint
> of the API and inspect the return object of an existing ticket e.g.
> https:https://jira.example.com/rest/api/2/issue/issueId


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
          name: "vn0tj0b"
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

<a name="transition"/>
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
