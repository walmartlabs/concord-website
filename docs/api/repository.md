---
layout: wmt/docs
title:  Repository
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

Concord projects have one or multiple associated repositories. The `repository` API supports
a number of operations on the project specific repositories:

- [Create a Repository](#create-repository)
- [Update a Repository](#update-repository)
- [Delete a Repository](#delete-repository)

<a name="create-repository"/>
## Create a Repository

A new repository can be created with a POST request and the required parameters.

* **URI** `/api/v1/org/{orgName}/project/{projectName}/repository`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "...",
      "url": "...",
      "branch": "...",
      "commitId": "...",
      "path": "...",
      "secretId": "..."
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
## Update a Repository

An existing repository can be updated with a POST request and the changed
parameters.

* **URI** `/api/v1/org/{orgName}/project/{projectName}/repository`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "id": "...",
      "name": "...",
      "url": "...",
      "branch": "...",
      "commitId": "...",
      "path": "...",
      "secretId": "..."
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

A DELETE request can be used to removes a repository.

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

