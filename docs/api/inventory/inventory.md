---
layout: wmt/docs
title:  Inventory
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

**Note:** the Inventory API is deprecated in favor of
[the JSON Store API](../json-store.html).

An organization can contain one or more inventories.

The REST API provides support for working with inventories:

- [Create an Inventory](#create-inventory)
- [Update an Inventory](#update-inventory)
- [Delete an Inventory](#delete-inventory)
- [List Inventories](#list-inventories)
- [Add Host Data to an Inventory](#add-host-data-to-an-inventory)

To remove a project's value, specify an empty value. For example, you can use an
empty `parent` inventory JSON object to remove a parent inventory from an 
inventory.

<a name="create-inventory"/>

## Create an Inventory

Creates a new inventory with specified parameters.

* **URI** `/api/v1/org/{orgName}/inventory`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "inventory",
      "orgId": "---",
      "orgName": "---",
      "visibility": "Public/Private",
      "owner": {
		"id": "---",
		"username": "---"
	       },
      "parent": {
		"id": "---",
		"name": "---",
		...
	       }
    }
    ```
    All parameters except `name` are optional.

    Parent inventory is also an inventory JSON object.

* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    {
      "result": "CREATED",
      "ok": true,
      "id": "..."
    }
    ```


<a name="update-inventory"/>

## Update an Inventory

Updates parameters of an existing inventory.

* **URI** `/api/v1/org/{orgName}/inventory`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "name": "new name",
      "id": "---",
      "orgId": "---",
      "orgName": "---",
      "visibility": "---",
      "owner": {
		"id": "---",
		"username": "---"
	       },
      "parent": {
		"id": "---",
		"name": "---",
		...
	       }
    }
    ```

    All parameters are optional except when updating inventory 'name', 'id'
    is required.

    Omitted parameters are not updated.

* **Success response**

    ```
    Content-Type: application/json
    ```

    ```json
    {
      "result": "UPDATED",
      "ok": true,
      "id": "..."
    }
    ```

<a name="delete-inventory"/>

## Delete an Inventory

Removes an existing inventory and all its data and associated queries.

* **URI** `/api/v1/org/${orgName}/inventory/${inventoryName}`
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

<a name="list-inventories"/>

## List Inventories

Lists all existing inventories for the specified organization.

* **URI** `/api/v1/org/${orgName}/inventory`
* **Method** `GET`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    [
      { "id": "...", "name": "..." },
      ...
    ]
    ```


<a name="add-data-to-inventory"/>

## Add Host Data to an Inventory

Adds or updates host data. `${itemPath}` is a unique to identify the data (e.g.
a fully-qualified hostname).

* **URI** `/api/v1/org/${orgName}/inventory/${inventoryName}/data/${itemPath}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: application/json`
* **Body**
    ```json
    {
      "host": "my.host.example.com",
      "meta": {
        "env": "cert",
        ...
      }
    }
    ```
* **Success Response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "host": "my.host.example.com",
      "meta": {
        "env": "cert",
        ...
      }
    }
    ```
