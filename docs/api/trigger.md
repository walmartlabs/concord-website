---
layout: wmt/docs
title:  Trigger
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

[Triggers](../getting-started/triggers.html) start processes in reaction to external events.

The REST API provides support for a number of operations:

- [List Triggers](#list-triggers)
- [Refresh Triggers](#refresh-triggers)


<a name="list-triggers"/>
## List Triggers

Returns a list of triggers registered for the specified project's repository.

* **URI** `/api/v1/org/${orgName}/project/${projectName}/repository/${repoName}/trigger`
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    [
      {
        "id": "...",
        "conditions": {
          ...
        }        
      }
    ]
    ```

<a name="refresh-triggers"/>
## Refresh Triggers

Reloads the trigger definitions for the specified project's repository.

* **URI** `/api/v1/org/${orgName}/project/${projectName}/repository/${repoName}/trigger`
* **Method** `POST`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    none
