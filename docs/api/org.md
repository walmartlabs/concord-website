---
layout: wmt/docs
title:  Team
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

An Organization owns projects, repositories, secrets and teams.

The REST API provides support for a number of operations:

- [Create or Update an Organization](#create-org)
- [List Organizations](#list-org)

<a name="create-orgs"/>
## Create an Organization

Creates a new organization with specified parameters or updates an
existing one.

Only administrators can create new organizations.

* **URI** `/api/v1/org`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "myOrg"
    }
    ```
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "result": "CREATED",
      "ok": true,
      "id": "..."
    }
    ```

<a name="list-orgs">
## List Organizations

Lists all available organizations.

* **URI** `/api/v1/org?onlyCurrent=${onlyCurrent}`
* **Method** `GET`
* **Headers** `Authorization`
* **Parameters**
    If the `${onlyCurrent}` parameter is `true`, then the server will
    return the list of the current user's organizations. Otherwise,
    all organizations will be returned. 
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
        "name": "..."
      },
      {
        "id": "...",
        "name": "..."
       }
    ]
    ```
