---
layout: wmt/docs
title:  Template
---

# Template

## Create a new template alias

Creates a new or updates existing template alias.

* **Permissions** `template:manage`
* **URI** `/api/v1/template/alias`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "alias": "my-template",
      "url": "http://host/path/my-template.jar"
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
    
## List template aliases

Lists existing template aliases.

* **Permissions** `template:manage`
* **URI** `/api/v1/template/alias`
* **Method** `GET`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```
    
    ```json
    [
      { "alias": "my-template", "url": "http://host/port/my-template.jar"},
      { "alias": "...", "url": "..."}
    ]
    ```
    
## Delete an existing template alias

Removes an existing template alias.

* **Permissions** `template:manage`
* **URI** `/api/v1/template/alias/${alias}`
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
