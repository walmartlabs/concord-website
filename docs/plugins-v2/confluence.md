---
layout: wmt/docs
title:  Confluence Task
side-navigation: wmt/docs-navigation.html
description: Plugin for interacting with Atlassian's Confluence API
---

# {{ page.title }}

The `confluence` task supports operations on the popular content collaboration
tool [Atlassian Confluence](https://www.atlassian.com/software/confluence).

- [Usage](#usage)
- [Overview](#overview)

Possible operations are:

- [Create a Page](#createPage)
- [Update a Page](#updatePage)
- [Add a comment](#addCommentsToPage)
- [Upload an Attachment](#uploadAttachment)
- [Create a Child Page](#createChildPage)
- [Delete a Page](#deletePage)
- [Get page content](#getPageContent)

<a name="usage"/>

## Usage

To be able to use the `confluence` task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:confluence-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the
[Confluence task](#overview).

<a name="overview"/>

## Overview

The `confluence` task allows users to trigger operations on a Confluence server
as a step of a flow. It uses a number of required input parameters that are
common for all operations:

- `apiUrl` - URL to the API endpoint of the Confluence server, e.g
  `https://confluence.example.com/rest/api/`
- `action` - determines the operation to be performed with the current
  invocation of the `confluence` task
- `userId` - identifier of the Confluence user account to use for the
  interaction
- `password` - password for the user account to use, typically this should be
  provided via usage of the [Crypto task](./crypto.html) to access a password
  stored in Concord or decrypt an encrypted password string.
- `ignoreErrors` - boolean value, if `true` any errors that occur during the
  execution are ignored and stored in the `result` variable. Defaults to
  `false`.

The `apiUrl` configures the URL to the Confluence REST API endpoint. It is best
configured globally by a
[default process configuration](../getting-started/policies.html#default-process-configuration-rule)
policy:

```json
{
  "defaultProcessCfg": {
    "defaultTaskVariables": {
      "confluence": {
        "apiUrl": "https://confluence.example.com/rest/api/"
      }
    }
  }
}
```

A minimal configuration taking advantage of a globally configured API URL
includes the `userId`, the `password`, the desired `action` to perform and any
additional parameters need for the action:

```yaml
flows:
  default:
  - task: confluence
    in:
      action: createPage
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    out: result
```

All operations are subject to the security configuration of your Confluence and
the userId performing the actions. For example, if you attempt to delete a page
without the correct rights to delete pages, the action of the task fails.

<a name="createPage"/>

## Create a Page

The `createPage` action can be used to create a new page with content in a
specific `space`.

```yaml
- task: confluence
  in:
    action: createPage
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    spaceKey: "MYSPACEKEY"
    pageTitle: "My Page Title"
    pageContent: "<p>This is <br/> my page content</p>"
  out: result
- log: "Page Id is ${result.pageId}"
- if: ${!result.ok}
  then:
  - throw: "Something went wrong: ${result.error}"
  else:
  - log: "Here is Page view info URL: ${result.data}"
```

Additional parameters to use are:

- `spaceKey` - string, Required - identifying key for a Confluence space.
- `pageTitle` - string, Required - title of a page.
- `pageContent` - string, optional - content to be added to a page.
- `template` - string, optional - the task supports the use of a separate file
  for longer content.

As an alternative to `pageContent`, specify template and point to a file in your
project that contains the content text.

```yaml
template: page.mustache
```

The template engine [Mustache](https://mustache.github.io/) is used to process
content template files, so you can use any variables from the Concord process
context in the message.

When creating content in a template file, you can reference any variable that is
defined in the flow using double open { and closing curly braces } in the
template file. You can also pass additional variables as a part of
`templateParams` parameter as shown below

```yaml
- task: confluence
  in:
    action: createPage
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    spaceKey: "MYSPACEKEY"
    pageTitle: "My Page Title"
    template: content.mustache
    templateParams:
      myVariable1: "content variable 1"
      myVariable2: "content variable 2"
      myVariable3: "content variable 3"
  out: result
```

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the following attributes are returned:

- `data` - string value, contains the page view info URL.
- `pageId` - integer value, contains the `id` of confluence page created.
 
<a name="updatePage"/>

## Update a Page

The `updatePage` action can be used to update (`append/overWrite`) the content
of an existing page. By default this action appends text to existing content.

```yaml
- task: confluence
  in:
    action: updatePage
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    spaceKey: "MYSPACEKEY"
    pageTitle: "My Page Title"
    pageUpdate: "This is an update to an existing content"
  out: result
```

Additional parameters to use are:

- `spaceKey` - string, Required - identifying key for a `Confluence` space.
- `pageTitle` - string, Required - title of a page that you intend to update.
- `pageUpdate` - string, Required - content used to update an existing page.
- `overWrite`: boolean, if set to `true` overwrites the existing content.
  Defaults to `false`.

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the following attributes are returned:

- `data` - string value, contains the page view info URL.

<a name="addCommentsToPage"/>

## Add a comment

The `addCommentsToPage` action can be used to add a comment to an existing page.

```yaml
- task: confluence
  in:
    action: addCommentsToPage
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    pageId: 32432235
    pageComment: "<p>This is a comment to an existing page</p>"
  out: result
```

Additional parameters to use are:

- `pageId` - integer, Required - Id of a confluence page to which comments are
  added.
- `pageComment` - string, Required - comments added to an existing page.

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the following attributes are returned:

- `data` - string value, contains the page view info URL.

<a name="uploadAttachment"/>

## Upload an Attachment

The `uploadAttachment` action can be used to upload an attachment to a specific
page.

```yaml
- task: confluence
  in:
    action: uploadAttachment
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    pageId: 32432235
    attachmentComment: "My attachment comments"
    attachmentPath: path/to/the/attachment.txt
  out: result
```

Additional parameters to use are:

- `pageId` - integer, Required - Id of a confluence page to which file is
  attached.
- `attachmentComment` - Required - string, comments added to an attachment.
- `attachmentPath` - Required - string, path to an attachment file.

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the following attributes are returned:

- `data` - string value, contains the page view info URL.


<a name="getPageContent"/>

## Get Page Content

The `getPageContent` action can be used to get the content of a
page.

```yaml
- task: confluence
  in:
    action: getPageContent
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    pageId: 32432235
  out: result
```

Additional parameters to use are:

- `pageId` - interger, Required - Id of a confluence page

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the following attributes are returned:

- `data` - string value, contains the page content

<a name="createChildPage"/>

## Create a Child Page

The `createChildPage` action can be used to create a new page, with content, as
a child of another page.

```yaml
- task: confluence
  in:
    action: createChildPage
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    spaceKey: "MYSPACEKEY"
    parentPageId: 32432235
    childPageTitle: "My Child Page Title"
    childPageContent: "<p>This is <br/> child page content</p>"
  out: result
- log: "Child Page Id is ${result.childId}"
```

Additional parameters to use are:

- `parentPageId` - integer, Required - id of parent page.
- `childPageTitle` - string, Required - title of child page.
- `childPageContent` - string, optional - content added to child page.
- `template` - string, optional - task supports the use of a separate file for longer content. As an alternative to `childPageContent`, specify template and point to a file in your project that contains the content text.
- `templateParams` - map, optional - parameter used to define  additional variables that can be used when creating content in a `template` file

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the following attributes are returned:

- `data` - string value, contains the page view info URL.
- `childId` - integer value, contains the `id` of child page.

<a name="deletePage"/>

## Delete a Page

The `deletePage` action can be used to delete an existing page.

```yaml
- task: confluence
  in:
    action: deletePage
    userId: myUserId
    password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
    pageId: 32432235
  out: result
```

Additional parameters to use are:

- `pageId` - integer, Required - id of page that you intend to delete.

The `deletePage` action only returns the
[common task result fields](../processes-v2/flows.html#task-result-data-structure).
