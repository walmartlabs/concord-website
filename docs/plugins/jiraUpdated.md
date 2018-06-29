---
layout: wmt/docs
title:  JIRA Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `jira` task supports creating and updating issues in
[Atlassian JIRA](https://www.atlassian.com/software/jira).

- [Usage](#usage)
- [Jira Task](#jira-task)
  - [Create an Issue](#createIssue)
  - [Add a comment](#addComment)
  - [Transition an Issue](#transition)
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
[Jira Task](#git-task)

## Jira Task
The jira task allows users to trigger jira operations as a step of a flow. 

The `jira` task uses a number of input parameters that are common for all operations:

Following is a complete list of available attributes:

- `apiUrl` -  apiUrl of the JIRA server
- `userId` -  identifier of the user account to use for the interaction
- `password` -  password for the user account to use, typically this should be
provided via usage of the [Crypto task](./crypto.html)
- `projectKey` - identifying key for the project
- `summary` - summary text
- `description` - description text
- `issueType` -  name the issue type
- `components` - list of components 
- `labels` - list of labels
- `requestorUid` - identifier of the user account to be used as the requestor
- `customFieldsTypeKv` - list of custom fields of type key->value (e.g "customfield_40000": "this is a text field")
- `customFieldsTypeFieldAttr` - list of custom fields of type fieldAttribute 
          (e.g customfield_10216:
                    value: "4 - Cosmetic")
- `issueKey` - the identifier of the ticket e.g. used for
[adding a comment](#add-comment) or [transitioning](#transition) an issue.
- `transitionId` - identifier to use for the transition
- `transitionComment` - comment to add to the transition
- `componentId` - identifier to use for the deletion of component

The `apiUrl` configures the jira API endpoint. It is best configured globally
as 
[default process configuration](../getting-started/configuration.html#default-process-variable):
with a `jiraParams` argument:

```yaml
configuration:
  arguments:
    jiraParams:
      apiUrl: "https://jira.example.com/rest/api/2/"
```

Following is an example showing the common parameters.
<a name="createIssue"/>
### Create an Issue

The JIRA task can be used to create a new issue:

```yaml
flows:
  default:
  - task: jira
    in:
      action: createIssue
      apiUrl: "https://jira.example.com/rest/api/2/"
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
<a name="addComment"/>
### Add a comment

The JIRA task can be used to add a comment to an existing issue:

```yaml
flows:
  default:
  - task: jira
    in:
      action: addComment
       apiUrl: "https://jira.example.com/rest/api/2/"
       userId: myUserId
       password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
       issueKey: "MYISSUEKEY"
       comment: "This is my comment from concord"
```

<a name="transition"/>
## Transition an Issue

The JIRA task can be used to transition an existing issue to another status such
as work in progress, ready for review or done:

```yaml
flows:
  default:
  - task: jira
    in:
      action: transition
      apiUrl: "https://jira.example.com/rest/api/2/"
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      issueKey: "MYISSUEKEY"
      transitionId: 561
      transitionComment: "marking as Done"
      customFieldsTypeKv: {"customfield_10212": "Development","customfield_10213": "PROD"}
      customFieldsTypeFieldAttr:
         customfield_10229:
                   value: "Task Completed"
         customfield_20106: 
                  value: "This is not going into production (ever)"
      
```

<a name="deleteIssue"/>
## Delete an Issue

The JIRA task can be used to delete an existing issue.

```yaml
flows:
  default:
  - task: jira
     in:
      action: deleteIssue
      apiUrl: "https://jira.example.com/rest/api/2/"
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      issueKey: "MYISSUEKEY"
```

<a name="createComponent"/>
## Create a new Component

The JIRA task can be used to create a new Component for a given JIRA project.

```yaml
flows:
  default:
  - task: jira
    in:
      action: createComponent
      apiUrl: "https://jira.example.com/rest/api/2/"
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      projectKey: "MYPROJECTKEY"
      componentName: "MYCOMPONENT"
      
```


<a name="deleteComponent"/>
## Delete a Component

The JIRA task can be used to delete a Component using componentId

```yaml
flows:
  default:
  - task: jira
    in:
      action: deleteComponent
      apiUrl: "https://jira.example.com/rest/api/2/"
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      componentId: 33818
      
```
