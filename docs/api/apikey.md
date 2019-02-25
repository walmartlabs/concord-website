---
layout: wmt/docs
title:  API Key
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

An API Key is specific to a user and allows access to the API with the key
replacing the usage of user credentials for authentication.

The REST API provides support for a number of operations:

- [Create a New API Key](#create-key)
- [List Existing API keys](#list-keys)
- [Delete an Existing API Key](#delete-key)

<a name="create-key"/>
## Create a New API Key

Creates a new API key for a user.

* **URI** `/api/v1/apikey`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
  ```json
  {
    "username": "myLdapUsername"
  }
  ```
* **Success response**
  ```
  Content-Type: application/json
  ```

  ```json
  {
    "ok": true,
    "id": "...",
    "key": "..."
  }
  ```
* **Example**
  ```
  curl -u myLdapUser -H "Content-Type: application/json" -d '{ "username": "myLdapUser" }' http://localhost:8001/api/v1/apikey
  ```

<a name="list-keys"/>
## List Existing API keys

Lists any existing API keys for the user. Only returns metadata, not actual keys.

* **URI** `/api/v1/apikey`
* **Method** `GET`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    [
      {
        "id" : "2505acba-314d-11e9-adf9-0242ac110002",
        "name" : "key#1"
      }, {
        "id" : "efd12c7a-3162-11e9-b9c0-0242ac110002",
        "name" : "myCustomApiKeyName"
      }
    ]
    ```
* **Example**
  ```
  curl -u myLdapUser -H "Content-Type: application/json" http://localhost:8001/api/v1/apikey
  ```

<a name="delete-key"/>
## Delete an existing API key

Removes an existing API key.

* **URI** `/api/v1/apikey/${id}`
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
