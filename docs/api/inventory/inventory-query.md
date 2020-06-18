---
layout: wmt/docs
title:  Inventory Query
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

**Note:** the Inventory Query API is deprecated in favor of
[the JSON Store API](../json-store.html).

Inventory Queries are used to access data stored in an [Inventory](inventory).

The REST API provides support working with inventory queries:

- [Create an Inventory Query](#create-update-inventory-query)
- [Execute an Inventory Query](#execute-inventory-query)
- [Query and Execution Examples](#create-and-execute-examples)
  - [Example: Return All Data](#example-return-all-data)
  - [Example: Return Only Host Value](#example-return-only-host)
  - [Example: Parameterized Query All Data](#example-parameterized-query-all-data)
  - [Example: Parameterized Query Only Hostname](#example-parameterized-query-only-host)
- [Delete an Inventory Query](#delete-inventory-query)
- [List Inventory Queries](#list-inventory-queries)
- [Example Queries](#examples)

<a name="create-update-inventory-query"/>

## Create or Update an Inventory Query

Creates a new inventory query with specified query.

* **URI** `/api/v1/org/{orgName}/inventory/${inventoryName}/query/${queryName}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: text/plain` or `Content-Type: application/json`
* **Body**
    ```sql
    SELECT CAST(json_build_object('host', item_data->'host') as varchar) FROM inventory_data;
    ```

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

<a name="execute-inventory-query"/>

## Execute an Inventory Query

Executes an inventory query. The response data varies depending on the selected
columns in the inventory query.

* **URI** `/api/v1/org/{orgName}/inventory/${inventoryName}/query/${queryName}/exec`
* **Method** `POST`
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
        "host": "my.host.example.com"
      },
      ...
    ]
    ```

<a name="create-and-execute-examples"/>

## Query and Execution Examples

Below is a set of queries and execution parameters for a small example data set
of two servers in the same datacenter, but used for different environments.

```json
{
  "host": "myhost.cert.example.com",
  "meta": {
    "env": "cert",
    "datacenter": "US-South"
  }
}
```

```json
{
  "host": "myhost.prod.example.com",
  "meta": {
    "env": "prod",
    "datacenter": "US-South"
  }
}
```

<a name="example-return-all-data"/>

### Example: Return All Inventory Data

Create the inventory query to simply return all data for each item in the inventory.

```
curl -u myusername \
  -H 'Content-Type: text/plain' \
  -d 'SELECT CAST(item_data as varchar) FROM inventory_data;' \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/all-data
```

Execute the query.

```
curl -u myusername \
  -X POST \
  -H 'Content-Type: application/json' \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/all-data/exec
```

The query will return all of the inventory data.

```json
[
  {
    "host": "myhost.cert.example.com",
    "meta": {
      "env": "cert",
      "datacenter": "US-South"
    }
  },
  {
    "host": "myhost.prod.example.com",
    "meta": {
      "env": "prod",
      "datacenter": "US-South"
    }
  }
]
```

<a name="example-return-only-host"/>

### Example: Return Only Host Value

Create the inventory query to return only the `host` for each item in the inventory.

```
curl -u myusername \
  -H 'Content-Type: text/plain' \
  -d "SELECT CAST(json_build_object('host', item_data->'host') as varchar) FROM inventory_data;" \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/host-only
```

Execute the query.

```
curl -u myusername \
  -X POST
  -H 'Content-Type: application/json' \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/host-only/exec
```

The query will extract only the `host` value from each item.

```json
[
  {
    "host": "myhost.cert.example.com"
  },
  {
    "host": "myhost.prod.example.com"
  }
]
```

<a name="example-parameterized-query-all-data"/>

### Example: Parameterized Query Return All Data

Create the parameterized query.

```
curl -u myusername \
  -H 'Content-Type: text/plain' \
  -d "SELECT CAST(item_data as varchar) FROM inventory_data WHERE item_data @> ?::jsonb;" \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/parameterized-all-data
```

Execute the query to match only hosts in the `cert` environment.

```
curl -u myusername \
  -H 'Content-Type: application/json' \
  -d '{ "meta": { "env": "cert" } }' \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/parameterized-all-data/exec
```

The results will be filtered by the `env` value and all data for the host matching
the `env` value given in the filter.

```json
[
  {
    "host": "myhost.cert.example.com",
    "meta": {
      "env": "cert",
      "datacenter": "US-South"
    }
  }
]
```

<a name="example-parameterized-query-only-host"/>

### Example: Parameterized Query Return Only Hostname

Create the parameterized query to return only the `host` for each item in
the inventory.

```
curl -u myusername \
  -H 'Content-Type: text/plain' \
  -d "SELECT CAST(json_build_object('host', item_data->>'host') as varchar) FROM inventory_data WHERE item_data @> ?::jsonb;" \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/parameterized-host-only
```

Execute the query to match only hosts in the `US-South` datacenter.

```
curl -u myusername \
  -H 'Content-Type: application/json' \
  -d '{ "meta": { "datacenter": "US-South" } }' \
  https://concord.example.com/api/v1/org/Default/inventory/my-inventory/query/parameterized-host-only/exec
```

The results will be filtered by the `datacenter` value and only the host value
will be returned.

```json
[
  {
    "host": "myhost.cert.example.com"
  },
  {
    "host": "myhost.prod.example.com"
  }
]
```

<a name="delete-inventory-query"/>

## Delete an Inventory Query

Deletes an inventory query.

* **URI** `/api/v1/org/{orgName}/inventory/${inventoryName}/query/${queryName}`
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

<a name="list-inventory-queries"/>

## List Inventory Queries

Lists inventory queries for an inventory.

* **URI** `/api/v1/org/{orgName}/inventory/${inventoryName}`
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
        "name": "query-name",
        "inventoryId": "...",
        "text": "SELECT CAST(json_build_object('host', item_data->'host') as varchar) FROM inventory_data;"
      },
      ...
    ]
    ```



<a name="examples"/>

## Examples Queries

Below is a set of queries and execution parameters for a small example data set
of two servers in the same datacenter, but used for different environments.

```json
{
  "host": "myhost.cert.example.com",
  "meta": {
    "env": "cert",
    "datacenter": "US-South"
  }
}
```

```json
{
  "host": "myhost.prod.example.com",
  "meta": {
    "env": "prod",
    "datacenter": "US-South"
  }
}
```

### Return All Data

Query:

```sql
SELECT CAST(item_data as varchar) FROM inventory_data;
```

Results:

```json
[
  {
    "host": "myhost.cert.example.com",
    "meta": {
      "env": "cert",
      "datacenter": "US-South"
    }
  },
  {
    "host": "myhost.prod.example.com",
    "meta": {
      "env": "prod",
      "datacenter": "US-South"
    }
  }
]
```

### Return Only Hostname

Query:

```sql
SELECT CAST(json_build_object('host', item_data->'host') as varchar) FROM inventory_data;
```

Results:

```json
[
  {
    "host": "myhost.cert.example.com"
  },
  {
    "host": "myhost.prod.example.com"
  }
]
```

### Parameterized Query Return Only Hostname

Query:

```sql
SELECT CAST(json_build_object('host', item_data->>'host') as varchar) FROM inventory_data WHERE item_data @> ?::jsonb;
```

Execution Filter:

```json
{
  "meta": {
    "datacenter": "US-South"
  }
}
```

Results:

```json
[
  {
    "host": "myhost.cert.example.com"
  },
  {
    "host": "myhost.prod.example.com"
  }
]
```

### Parameterized Query Return All Data

Query:

```sql
SELECT CAST(item_data as varchar) FROM inventory_data WHERE item_data @> ?::jsonb;
```

Execution Filter:

```json
{
  "meta": {
    "env": "cert"
  }
}
```

Result:

```json
[
  {
    "host": "myhost.cert.example.com",
    "meta": {
      "env": "cert",
      "datacenter": "US-South"
    }
  }
]
```


