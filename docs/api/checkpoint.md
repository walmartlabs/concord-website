---
layout: wmt/docs
title:  Checkpoint
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The checkpoint API can be used to list and restore
[checkpoints created in a flow](../processes-v1/flows.html#checkpoints).

- [List Checkpoints](#list)
- [Restore a Process](#restore)

<a name="list"/>

## List Checkpoints

You can access a paginated list of checkpoints for a specific process,
identified by the `id`, with the REST API.

> The `/api/v1/process/{id}/checkpoint` endpoint is deprecated since version
> 2.44.0 in favor of the paginated `/api/v3` endpoint described below.

* **URI** `/api/v3/process/{id}/checkpoint`
* **Method** `GET`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Query parameters**
    * `offset` - number of checkpoints to skip; defaults to `0`
    * `limit` - maximum number of checkpoints to return; defaults to `10`
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
            "name": "...",
            "createdAt": "..."
        },
        {
            "id": "...",
            "name": "...",
            "createdAt": "..."
        },
        ...
    ]
    ```

<a name="restore"/>

## Restore a Process

You can restore a process state from a named checkpoint of a specific process
using the process identifier in the URL and the checkpoint identifier in the
body.

* **URI** `/api/v1/process/{id}/checkpoint/restore`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "id": "..."
    }
    ```

* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```
