---
layout: wmt/docs
title:  User
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A user represents an actual person using Concord to execute processes or
adminstrate the server.

The REST API provides support for a number of operations:

- [Create or Update a User](#create-user)
- [Find a User](#find-user)


<a name="create-user"/>
## Create or Update a User

Creates a new user with specified parameters or updates an existing one
using the specified username.

* **URI** `/api/v1/user`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "username": "myUser",
      "permissions": [
        "project:create",
        "process:start:*",
        "..."
      ]
    }
    ```
    Permissions are optional.

    See also [the list of available permissions](../getting-started/security.html#permissions).
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true,
      "id" : "9be3c167-9d82-4bf6-91c8-9e28cfa34fbb",
      "created" : false
    }
    ```

    The `created` paratemer indicates whether the user was created or updated.

<a name="find-user"/>
## Find a User

Find an existing user by name.

* **URI** `/api/v1/user/${username}`
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "id" : "...",
      "name" : "myUser",
      "permissions" : [ "*:*:*" ]

    }
    ```

    The `created` paratemer indicates whether the user was created or updated.

