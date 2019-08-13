---
layout: wmt/docs
title:  Confluence Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `Confluence` task supports operations on the popluar content collaboration
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

<a name="usage"/>

## Usage

To be able to use the `confluence` task in a Concord flow, it must be added as a
[dependency](../getting-started/concord-dsl.html#dependencies):

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

- `apiUrl` -  URL to the API endpoint of the Confluence server, e.g
  `https://confluence.example.com/rest/api/`
- `action` - determines the operation to be performed with the current
  invocation of the `confluence` task
- `userId` -  identifier of the Confluence user account to use for the
  interaction
- `password` -  password for the user account to use, typically this should be
  provided via usage of the [Crypto task](./crypto.html) to access a password
  stored in Concord or decrypt an encrypted password string.

The `apiUrl` configures the URL to the Confluence REST API endpoint. It is best
configured globally as [default process
configuration](../getting-started/configuration.html#default-process-variable)
with a `confluenceParams` argument:

```yaml
configuration:
  arguments:
    confluenceParams:
      apiUrl: "https://confluence.example.com/rest/api/"
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
```

All operations are subject to the security configuration of your Confluence and
the userId performing the actions. For example, if you attempt to delete a page
without the correct rights to delete pages, the action of the task fails.

<a name="createPage"/>

## Create a Page

The `createPage` action can be used to create a new page with content in a
specific `space`. The output of the action is stored in a variable `pageId`. It
can used at later point in the flow.

```yaml
flows:
  default:
  - task: confluence
    in:
      action: createPage
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      spaceKey: "MYSPACEKEY"
      pageTitle: "My Page Title"
      pageContent: "<p>This is <br/> my page content</p>"
  - log: "Page Id is ${pageId}"
```

Additional parameters to use are:

- `spaceKey` - string, Required - identifying key for a `Confluence` space.
- `pageTitle` - string, Required - title of a page.
- `pageContent` - string, Required - content to be added to a page.

<a name="getPageContent/>

## Get Page Content

TBD
 
<a name="updatePage"/>

## Update a Page

The `updatePage` action can be used to update the content of an existing page.

```yaml
flows:
  default:
  - task: confluence
    in:
      action: updatePage
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      spaceKey: "MYSPACEKEY"
      pageTitle: "My Page Title"
      pageUpdate: "This is an update to an existing content"
      version: 2
```

Additional parameters to use are:

- `spaceKey` - string, Required - identifying key for a `Confluence` space.
- `pageTitle` - string, Required - title of a page that you intend to update.
- `pageUpdate` - string, Required - content used to update an existing page.
- `version` - Integer, Required - next version of a page. If `current version`
  of a page is `2` and you want to update its content using `updatePage` action,
  `version` is `3`.

<a name="addCommentsToPage"/>

## Add a comment

The `addCommentsToPage` action can be used to add a comment to an existing page.

```yaml
flows:
  default:
  - task: confluence
    in:
      action: addCommentsToPage
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      pageTitle: "My Page Title"
      pageComment: "<p>This is a comment to an existing page</p>"
```

Additional parameters to use are:

- `pageTitle` - string, Required - title of a page to which comments are added.
- `pageComment` - string, Required - comments added to an existing page.

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
      pageTitle: "My Page Title"
      attachmentComment: "My attachment comments"
      attachmentPath: path/to/the/attachment.txt
```

Additional parameters to use are:

- `attachmentComment` - Required - string, comments added to an attachment.
- `attachmentPath` - Required - string, path to an attachment file.

<a name="createChildPage"/>

## Create a Child Page

The `createChildPage` action can be used to create a new page, with content, as
a child of another page. The output of the action is stored in a variable
`childPageId`. It can used at later point in the flow.

```yaml
- task: confluence
    in:
      action: createChildPage
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      spaceKey: "MYSPACEKEY"
      parentPageTitle: "My Parent Page Title"
      childPageTitle: "My Child Page Title"
      childPageContent: "<p>This is <br/> child page content</p>"
- log: "Child Page Id is ${childPageId}"
```

Additional parameters to use are:

- `parentPageTitle` - string, Required - title of parent page.
- `childPageTitle` - string, Required - title of child page.
- `childPageContent` - string, Required - content added to child page.

<a name="deletePage"/>

## Delete a Page

The `deletePage` action can be used to delete an existing page.

```yaml
flows:
  default:
  - task: confluence
     in:
      action: deletePage
      userId: myUserId
      password: ${crypto.exportCredentials('Default', 'mycredentials', null).password}
      pageTitle: "My Page Title"
```

Additional parameters to use are:

- `pageTitle` - string, Required - title of page that you intend to delete.
