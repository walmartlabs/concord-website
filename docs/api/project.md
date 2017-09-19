---
layout: wmt/docs
title:  Project
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A project is a container for one or more repositories, a [secret](./secret.html)
for accessing the repositories and further configuration.

The REST API provides support for a number of operations:

- [Create a Project](#create-project)
- [Update a Project](#update-project)
- [Delete a Project](#delete-project)
- [List Projects](#list-projects)
- [Create a Repository](#create-repository)
- [Update a Repository](#update-repository)
- [Delete a Repository](#delete-repository)
- [List Repositories](#list-repositories)
- [Get Project Configuration](#get-project-configuration)
- [Update Project Configuration](#update-project-configuration)

<a name="create-project"/>
## Create a Project

Creates a new project with specified parameters or updates an existing one.

* **Permissions** `project:create`, `project:update:${projectName}`, `secret:read:${secretName}` (optional)
* **URI** `/api/v1/project`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "myProject",
      "description": "my project",

      "repositories": {
        "myRepo": {
          "url": "...",
          "branch": "...",
          "path": "...",
          "secret": "..."
        }
      },

      "cfg": {
        ...
      }
    }
    ```
    All parameters except `name` are optional.

    The project configuration is a JSON object of the following structure:
    ```json
    {
      "group1": {
        "subgroup": {
          "key": "value"
        }
      },
      "group2": {
        ...
      }
    }
    ```

    Most of the parameter groups are defined by used plugins.

    See also: [create a new repository](#create-a-new-repository)
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```

<a name="update-project"/>
## Update a Project

Updates parameters of an existing project.

* **Permissions** `project:update:${projectName}`, `secret:read:${secretName}` (optional)
* **URI** `/api/v1/project/${projectName}`
* **Method** `PUT`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "description": "my updated project",

      "repositories": {
        "myRepo": {
          "url": "...",
          "branch": "...",
          "secret": "..."
        }
      },

      "cfg": {
        ...
      }
    }
    ```
    All parameters are optional. Omitted parameters will not be updated.
    An empty value must be specified in order to remove a project's value:
    e.g. an empty `repositories` object to remove all repositories from a project.

    See also: [create a new repository](#create-a-new-repository), [project configuration](#project-configuration)
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```

<a name="delete-project"/>
## Delete a Project

Removes a project and its resources.

* **Permissions** `project:delete:${projectName}`
* **URI** `/api/v1/project/${projectName}`
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
      "ok": true
    }
    ```

<a name="list-projects">
## List Projects

Lists all existing projects.

* **Permissions**
* **URI** `/api/v1/project?sortBy=${sortBy}&asc=${asc}`
* **Query parameters**
    - `sortBy`: `projectId`, `name`;
    - `asc`: direction of sorting, `true` - ascending, `false` - descending
* **Method** `GET`
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

<a name="create-repository"/>
## Create a Repository

Adds a new repository for a project.

* **Permissions** `project:update:${projectName}`, `secret:read:${secretName}` (optional)
* **URI** `/api/v1/project/${projectName}/repository`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "myRepo",
      "url": "...",
      "branch": "...",
      "commitId": "...",
      "path": "...",
      "secret": "..."
    }
    ```

    Mandatory parameters: `name` and `url`.
    Parameters `branch` and `commitId` are mutually exclusive.
    The referenced secret must exist beforehand.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```

<a name="update-repository"/>
## Update a Repository

Updates parameters of an existing repository.

* **Permissions** `project:update:${projectName}`, `secret:read:${secretName}`
* **URI** `/api/v1/project/${projectName}/repository/${repoName}`
* **Method** `PUT`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "url": "...",
      "branch": "...",
      "secret": "..."
    }
    ```

    All parameters except `url` are optional.
    The referenced secret must exist beforehand.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```

<a name="delete-repository"/>
## Delete a Repository

Removes a repository.

* **Permissions** `project:update:${projectName}`
* **URI** `/api/v1/project/${projectName}/repository/${repoName}`
* **Method** `DELETE`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```

<a name="list-repositories"/>
## List Repositories

Lists existing repositories in a project.

* **Permissions** `project:read:${projectName}`
* **URI** `/api/v1/project/${projectName}/repository?sortBy=${sortBy}&asc=${asc}`
* **Query parameters**
    - `sortBy`: `name`, `url`, `branch`;
    - `asc`: direction of sorting, `true` - ascending, `false` - descending
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
      { "name": "...", "url": "...", "branch": "...", "secret": "..." },
      { "name": "...", "url": "..." }
    ]
    ```

<a name="get-project-configuration"/>
## Get Project Configuration

Returns project's configuration JSON or its part.

* **Permissions** `project:read:${projectName}`
* **URI** `/api/v1/project/${projectName}/cfg/${path}`
* **Query parameters**
    - `path`: path to a sub-object in the configuration, can be empty
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
      ...
    }
    ```

a name="update-project-configuration"/>
## Update Project Configuration

Updates project's configuration or its part.

* **Permissions** `project:read:${projectName}`
* **URI** `/api/v1/project/${projectName}/cfg/${path}`
* **Query parameters**
    - `path`: path to a sub-object in the configuration, can be empty
* **Method** `PUT`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "group1": {
        "param1": 123
      }
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
