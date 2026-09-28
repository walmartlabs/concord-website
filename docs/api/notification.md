---
layout: wmt/docs
title:  Notification
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A notification is a short message that can be assigned to either a [user](./user.html) , [project](./project.html), or [organization](./organization.html) . They persist until the notification "owner" deliberately dismisses them. The "owner" for a notification looks different depending on the scope of the given notification.
* user notifications are owned by the user the notification is assigned to
* project notifications are dismissable by anybody with write permissions to the project
* organization notifications

## Create Notification

* **URI** `/api/v1/notifications
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**

    JSON object with the following fields:
    ```json
    {
	    "summary": "Notification Summary",
	    "body": "Full notification body text",
	    "actionLink": "http://example.com/", // optional, a link that is relevant to the notification
	    "triggerEmail": false, // should this notification email the relevant users
	    "userId": "0c8fdeca-5158-4781-ac58-97e34b9a70ee" // user that owns the notification
    }
    ```
	For notifications that are not tied to a user, but instead a project or organization, you can replace the `userId` field with `organizationId` or `projectId` field respectively. For notifications tied to a `projectId` you can also optionally specify a `repositoryId`.


* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "id" : "0c8fdeca-5158-4781-ac58-97e34b9a70ee",
      "result" : "CREATED"
    }
    ```

## Dismiss Notification

Dismisses a notification on behalf of the current user.

* **URI** `/api/v1/notification/{id}`
* **Method** `DELETE`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    {
      "result": "DELETED"
    }
    ```

Dismissing a notification does not delete its underlying record — the
row is kept and stamped with `dismissedTimestamp` and `dismissedBy`
for auditing purposes, and is simply excluded from future dismissible
views.

Only the target user (for `USER`-scoped notifications), a project
owner (for `PROJECT`-scoped notifications), an org member (for
`ORG`-scoped notifications), or an administrator/moderator can dismiss
a given notification.

## List Notifications

Returns a paginated list of notifications for a given owner.

* **URI** `/api/v1/notification`
* **Method** `GET`
* **Headers** `Authorization`
* **Query parameters**
    * `ownerKind` - the scope of the notifications to list. One of
      `USER`, `ORG`, `PROJECT`, `REPOSITORY`. Defaults to `USER`.
    * `ownerId` - the ID of the owner (user, organization, project or
      repository). Optional when `ownerKind` is `USER` — it defaults
      to the current user's ID. Required for all other scopes.
* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    [
      {
        "id": "...",
        "userId": "...",
        "summary": "...",
        "body": "...",
        "actionLink": "...",
        "triggerEmail": false,
        "createdAt": "..."
      }
    ]
    ```

    Fields with no value (`orgId`, `projectId`, `repoId`,
    `dismissedTimestamp`, `dismissedBy`) are omitted from the
    response rather than returned as `null`. A dismissed notification
    includes `dismissedTimestamp` and `dismissedBy`:

    ```json
    {
      "id": "...",
      "orgId": "...",
      "summary": "...",
      "body": "...",
      "actionLink": "...",
      "triggerEmail": false,
      "createdAt": "...",
      "dismissedTimestamp": "...",
      "dismissedBy": "..."
    }
    ```

> Only administrators and moderators (the `concordModerator` role) can
> list notifications for an owner other than themselves. Requesting
> `ORG` or `PROJECT` scope as a regular user requires org membership,
> or project `OWNER` access, respectively.
