---
layout: wmt/docs
title:  Repository
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A repository contains information regarding online directory with project deployment files.

The REST API provides support for a number of operations:

- [Create/Update a Repository](#create-repository)
- [Delete a Repository](#delete-repository)
- [Refresh Repository](#refesh-repository)

<a name="create-repository"/>
## Create a Repository

Creates/Update a new repository with specified parameters.

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
     `name`, `url`, `secretId` are mandatory.

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

<a name="refesh-repository">
## Refresh Repository

Refresh repository cached data.

* **URI** `/api/v1/org/{orgName}/project/{projectName}/repository/{repositoryName}/refresh`
* **Method** `POST`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
       "result": "UPDATED",
       "ok": true
    }
    ```
