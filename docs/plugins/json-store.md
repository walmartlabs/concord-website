---
layout: wmt/docs
title:  JSON Store Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `jsonStore` task provides access to [JSON Stores](../getting-started/json-store.html).
It allows users to add, update and remove JSON store items using Concord flows.

This task is provided automatically by Concord.

## Usage

### Create or Update an Item

Syntax:

```yaml
- ${jsonStore.put(orgName, storeName, itemPath, data)}
- ${jsonStore.put(storeName, itemPath, data)}
```

The `data` parameter must be a Java object. Only types that can be represented
in JSON are supported: Java lists, maps, strings, numbers, boolean values, etc.

The task uses the current process' organization name if the `orgName` parameter
is omitted. 

Example:

```yaml
configuration:
  arguments:
    myItem:
      x: 123
      nested:
        value: "abc"

flows:
  default:
    - "${jsonStore.put("myStore", "anItem", myItem)}"    
```

## Retrieve an Item

Syntax:

```yaml
- ${jsonStore.get(orgName, storeName, itemPath)}
- ${jsonStore.get(storeName, itemPath)}
```

The expression returns the specified item parsed into a Java object or `null`
if no such item exists.

Example:

```yaml
flows:
  default:
    - expr: "${jsonStore.get('myStore', 'anItem')}"
      out: anItem

    - if: "${anItem == null}"
      then:
        - log: "Can't find the item you asked for."
      else:
        - log: "${anItem}"
```

## Remove an Item

Syntax:

```yaml
- ${jsonStore.delete(orgName, storeName, itemPath)}
- ${jsonStore.delete(storeName, itemPath)}  
```

The expression returns `true` if the specified item was removed or `false` if
it didn't exist.

<a name="execute-query"/>

## Execute a Named Query

Syntax:

```yaml
- ${jsonStore.executeQuery(storeName, queryName)}
- ${jsonStore.executeQuery(storeName, queryName, params)}
- ${jsonStore.executeQuery(orgName, storeName, queryName)}
- ${jsonStore.executeQuery(orgName, storeName, queryName, params)}
```

The expression returns a `List` of items where each item represents a row
object returned by the query.

Query parameters (the `params` arguments) must be a Java `Map` object that can
be represented with JSON.

You can also pass the parameters directly in the expression:

```yaml
- "${jsonStore.executeQuery('myStore', 'lookupServiceByUser', {'users': ['mike']})}"
```

Example:

```yaml
configuration:
  arguments:
    myQueryParams:
      users:
        - "mike"

flows:
  default:
    - expr: "${jsonStore.executeQuery('myStore', 'lookupServiceByUser', myQueryParams)}"
      out: myResults

    - log: "${myResults}"
```

(see also [the example](../getting-started/json-store.html#example) on the
JSON Store page).
