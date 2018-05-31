---
layout: wmt/docs
title:  JIRA Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `jira` task supports creating and updating issues in
[Atlassian JIRA](https://www.atlassian.com/software/jira).

## Usage

To be able to use the `jira` task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:jira-task:0.43.0
```

This adds the task to the classpath and allows you to configure the main
parameters in a separate collection e.g. named `jiraConfig`:

```yaml
configuration:
  arguments:
    jiraConfig:
      jiraUrl: "https://jira.example.com"
      jiraUid: "myJiraUser"
      jiraPwd: "${crypto.decryptString('encryptedPassword')}"
      jiraProjectKey: MYPROJECT 
      jiraSummary: "My Summary"
      jiraDescription: "We should really fix this"
      jiraIssueTypeId: 10
      jiraRequestorUid: "${initiator.username}"
```

Following is a complete list of available configuration attributes:

- `jiraUrl` -  URL of the JIRA server
- `jiraUid` -  identifier of the user account to use for the interaction
- `jiraPwd` -  password for the user account to use, typically this should be
provided via usage of the [Crypto task](./crypto.html)
- `jiraProjectKey` - identifying key for the project
- `jiraSummary` - summary text
- `jiraDescription` - description text
- `jiraIssueTypeId` -  numerical identifier for the issue type
- `jiraComponents` - list of components 
- `jiraLabels` - list of labels
- `jiraRequestorUid` - identifier of the user account to be used as the requestor
- `jiraCustomFields` - list of custom fields
- `jiraIssueKey` - the identifier of the ticket e.g. used for
[adding a comment](#add-comment) or [transitioning](#transition) an issue.
- `jiraTransitionFields` - list of fields to add
- `jiraTransitionId` - identifier to use for the transition
- `jiraTransitionComment` - comment to add to the transition


With the configuration in place, you can call the various functions of the
JIRA tasks using the
[execution context](../getting-started/processes.html#provided-variables), 
and the configuration object e.g. `jiraConfig` with the potential addition of any
further required parameters.

```yaml
flows:
  default:
  - ${jira.addComment(context, jiraConfig, "my new comment"")}
```

The following sections describe the available functions in more detail:

- [Create an Issue](#create)
- [Add a comment](#add-comment)
- [Transition an Issue](#transition)
- [Delete an Issue](#delete)
- [Create a Component](#create-component)
- [Source Reference](#source)


<a name="create"/>

## Create an Issue

The JIRA task can be used to create a new issue: 

```yaml
- ${jira.create(context, jiraConfig)}
```

<a name="add-comment"/>

## Add a Comment

The JIRA task can be used to add a comment to an existing issue:

```yaml
- ${jira.addComment(context, jiraConfig), comment}
```

<a name="transition"/>

## Transition an Issue

The JIRA task can be used to transition an existing issue to another status such
as work in progress, ready for review or done:

```yaml
- ${jira.transition(context, jiraConfig)}
```


<a name="delete"/>

## Delete an Issue

The JIRA task can be used to delete an existing issue.

```yaml
- ${jira.delete(context, jiraConfig)}
```

<a name="create-component"/>

## Create a new Component

The JIRA task can be used to create a new Component for a given JIRA project.

```yaml
- ${jira.createComponent(context, jiraConfig, componentName)}
```

<a name="source"/>

## Source Reference

The
[source code of the task implementation]({{site.concord_plugins_source}}tree/master/tasks/jira)
can be used as the reference for the available functionality.
