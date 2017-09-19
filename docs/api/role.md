---
layout: wmt/docs
title:  Role
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Roles group permissions to projects and other aspects and can be assigned to
users via LDAP mappings.

The REST API provides support for a number of operations:

- [Create or Update a Role](#create-role)

<a name="create-role"/>
## Create or Update a Role

Creates a new role with specified parameters or updates an existing one
using the specified name.

* **Permissions** `role:create`, `role:update`
* **URI** `/api/v1/role`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "myRole",
      "permissions": [
        "project:create",
        "process:start:*",
        "..."
      ]
    }
    ```
    See also [the list of available permissions](../getting-started/security.html#permissions).
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true,
      "created" : false
    }
    ```

    The `created` paratemer indicates whether the role was created or updated.

