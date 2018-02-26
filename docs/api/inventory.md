---
layout: wmt/docs
title:  Inventory
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

An organization can contain one or more inventories.

The REST API provides support for a number of operations:

- [Create an Inventory](#create-inventory)
- [Update an Inventory](#update-inventory)

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
    All parameters are optional.

    Omitted parameters are not updated.
    
    In case of updating the inventory `name`, inventory `id` is mandatory.
    
    An empty value must be specified in order to remove a project's value:
    e.g. an empty `parent` object to remove parent inventory from a inventory.
    Parent inventory is also an inventory JSON object.
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
