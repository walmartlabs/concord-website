---
layout: wmt/docs
title:  Team
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A team owns projects, repositories and secrets. Users can be in
multiple teams simultaneously.

The REST API provides support for a number of operations:

- [Create or Update a Team](#create-team)
- [List Teams](#list-teams)
- [List Users in a Team](#list-users)
- [Add Users to a Team](#add-users)
- [Remove Users from a Team](#remove-users)

<a name="create-team"/>
## Create a Team

Creates a new team with specified parameters or updates an existing one.

* **Permissions** `team:manage`
* **URI** `/api/v1/team`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "myTeam",
      "description": "my team",
      "enabled": true
    }
    ```
    All parameters except `name` are optional.
    
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true,
      "id": "..."
    }
    ```

<a name="list-teams">
## List Teams

Lists all existing teams.

* **Permissions**
* **URI** `/api/v1/team`
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
      { "name": "..." },
      { "name": "...", "description": "my project", ... }
    ]
    ```

<a name="list-users">
## List Users in a Team

Returns a list of users associated with the specified team.

* **Permissions**
* **URI** `/api/v1/team/${teamName}/users`
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
      { "id": "...", "username": "..." },
      { "id": "...", "username": "..." }
    ]
    ```

<a name="add-users">
## Add Users to a Team

Adds a list of users to the specified team.

* **Permissions** `team:manage`
* **URI** `/api/v1/team/${teamName}/users`
* **Method** `PUT`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    ["userA", "userB", "..."]
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

<a name="remove-users">
## Remove Users from a Team

Removes a list of users from the specified team.

* **Permissions** `team:manage`
* **URI** `/api/v1/team/${teamName}/users`
* **Method** `DELETE`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    ["userA", "userB", "..."]
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
