---
layout: wmt/docs
title:  Checkpoint
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Checkpoint is a point within a flow from which a process can be restored. A flow can contains multiple checkpoints.

The REST API provides support for a number of operations:

- [Restore Process](#restore-process)
- [List Checkpoints](#list-checkpoints)

<a name="list-checkpoints"/>
## List Checkpoints

List all checkpoints of a process.

* **URI** `/api/v1/process/{id}/checkpoint`
* **Method** `GET`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    none

* **Success response**

    ```
    Content-Type: application/json
    ```
    
    ```json
    [
        {
            "checkpointId": "...",
            "checkpointName": "...",
            "checkpointDate": "..."
        },
        {
            "checkpointId": "...",
            "checkpointName": "...",
            "checkpointDate": "..."
        },
        ...
    ]
    ```


<a name="restore-process"/>
## Restore a process

Restore a process from a specific checkpoint.

* **URI** `/api/v1/process/{id}/checkpoint/restore`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "checkpointId": "..."
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
    