---
layout: wmt/docs
title:  Role
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A role is a set of rights/permissions assigned to users.

The REST API provides support for working with roles:

- [Create or Update a Role](#create-update)
- [Get a Role](#get)
- [Remove a Role](#delete)
- [List Roles](#list)

<a name="create-update"/>

## Create or Update a Role

Creates a new role or updates an existing one. Requires administrator
privileges.

* **URI** `/api/v1/role`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "myRole",
      "permissions": [...set of permissions...]
    }
    ```
    
    - `name` - the role's name;
    - `permissions` - optional, the set of role's permissions;
* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    {
      "result": "CREATED",
      "id": "..."
    }
    ```

<a name="get"/>

## Get a Role

Returns an existing role.

* **URI** `/api/v1/role/${name}`
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
      "id": "...",
      "name": "...",
      "permissions": [...set of permissions...]
    }
    ```

<a name="delete"/>

## Remove a Role

Deletes an existing role.

* **URI** `/api/v1/role/${name}`
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
      "result": "DELETED",
      "ok": true
    }
    ```

<a name="list"/>

## List Roles

List all existing roles.

* **URI** `/api/v1/role`
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
        "name": "...",
        "permissions": [...set of permissions...] 
      }
    ]
    ```
