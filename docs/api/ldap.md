---
layout: wmt/docs
title:  LDAP Mapping
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }} 

An LDAP mapping associates LDAP groups with Concord [roles](./role.html).

The REST API provides support for a number of operations:

- [Create or Update a LDAP Mapping](#create-mapping)
- [List LDAP Mappings](#list-mappings)
- [Delete a LDAP mapping](#delete-mapping)
- [List LDAP Groups of a User](#list-user-groups)

<a name="create-mapping"/>
## Create or Update a LDAP Mapping

Creates a new mapping with specified parameters or updates an existing one
using the specified LDAP DN.

* **Permissions** `ldapMapping:create`, `ldapMapping:update`
* **URI** `/api/v1/ldap/mapping`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "ldapDn": "CN=Team,OU=DevOps,DC=office,DC=org,DC=com",
      "roles": [
        "myRole1",
        "myRole2",
        "..."
      ]
    }
    ```

    Roles must exist prior to the creation of the mapping.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true,
      "id": "..."
      "created" : false
    }
    ```

    The `created` paratemer indicates whether the mapping was created or updated.

<a name="list-mappings"/>
## List LDAP Mappings

Lists existing LDAP mappings.

* **Permissions** none
* **URI** `/api/v1/ldap/mapping`
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
        "ldapDn": "...",
        "roles": ["..."]
      },
      {

      }
    ]
    ```

<a name="delete-mapping"/>
## Delete a LDAP mapping

Removes an existing LDAP mapping.

* **Permissions** `ldapMapping:delete`
* **URI** `/api/v1/ldap/mapping/${id}`
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

<a name="list-user-groups"/>
## List LDAP Groups of a User

Retrieves a list of LDAP groups for a specific user.

* **Permissions** `ldap:query`
* **URI** `/api/v1/ldap/query/${username}/group`
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    ["groupA", "groupB", "..."]
    ```
