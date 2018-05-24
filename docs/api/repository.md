---
layout: wmt/docs
title:  Repository
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A repository resource to manage repositories associated with a project.

The REST API provides support for a number of operations:

- [Create a Repository](#create-repository)
- [Update a Repository](#update-repository)
- [Delete a Repository](#delete-repository)

<a name="create-repository"/>
## Create a repository

Creates a new repository with specified parameters.

* **URI** `/api/v1/org/{orgName}/project/{projectName}/repository`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "id": "...",
      "projectId": "...",
      "name": "...",
      "url": "...",
      "branch": "...",
      "commitId": "...",
      "path": "...",
      "secretId": "...",
      "secretName": "..."
    }
    ```

* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "result": "CREATED",
      "ok": true
    }
    ```

<a name="update-repository"/>
## Update a repository

Updates existing repository with specified parameters.

* **URI** `/api/v1/org/{orgName}/project/{projectName}/repository`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "id": "...",
      "projectId": "...",
      "name": "...",
      "url": "...",
      "branch": "...",
      "commitId": "...",
      "path": "...",
      "secretId": "...",
      "secretName": "..."
    }
    ```

* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "result" : "UPDATED",
      "ok" : true
    }
    ```


<a name="delete-repository"/>
## Delete a Repository

Removes a repository.

* **URI** `/api/v1/org/{orgName}/project/{projectName}/repository/{repositoryName}`
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

