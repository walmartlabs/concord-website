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
- [Get Project Configuration](#get-project-configuration)
- [Update Project Configuration](#update-project-configuration)

<a name="create-project"/>
## Create a Project

Creates a new project with specified parameters.

* **URI** `/api/v1/org/${orgName}/project`
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
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true,
      "result": "CREATED"
    }
    ```

<a name="update-project"/>
## Update a Project

Updates parameters of an existing project.

* **URI** `/api/v1/org/${orgName}/project`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "New name",
      "id": "---",
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
    All parameters are optional.
    
    Omitted parameters are not updated.

    Project `id` is mandatory, in case of updating project `name`, .
    
    An empty value must be specified in order to remove a project's value:
    e.g. an empty `repositories` object to remove all repositories from a project.

    See also: [project configuration](#project-configuration)
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true,
      "result": "UPDATED",
      "id": "---"
    }
    ```

<a name="delete-project"/>
## Delete a Project

Removes a project and its resources.

* **URI** `/api/v1/org/${orgName}/project/${projectName}`
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
      "ok": true,
      "result": "DELETED"
    }
    ```

<a name="list-projects">
## List Projects

Lists all existing projects.

* **URI** `/api/v1/org/${orgName}/project`
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

<a name="get-project-configuration"/>
## Get Project Configuration

Returns project's configuration JSON or its part.

* **URI** `/api/v1/org/${orgName}/project/${projectName}/cfg/${path}`
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

* **URI** `/api/v1/org/${orgName}/project/${projectName}/cfg/${path}`
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
      "ok": true,
      "result": "UPDATED"
    }
    ```
