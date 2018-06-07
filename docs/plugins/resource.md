---
layout: wmt/docs
title:  Resource Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `resource` task provides methods to persist data to a file in the scope of a
process. This data can be read back for later use in the same process. The
`resource` task supports `json` and `string` formats.

The task is provided automatically by Concord and does not require any
external dependencies.

<a name="usage"/>

## Usage

### Reading a resource

The `asJson` method of the `resource` task can read a JSON-file resource and
create a `json` object.

```yaml
- flows:
    default:
    - expr: ${resource.asJson('sample-file.json')}
      out: jsonObj
    # we can now use it like a simple object
    - log: ${jsonObj.any_key}
    ```

The `asString` method can read a file resource and create a `string` object with
the content.

```yaml
- log: ${resource.asString(sample-file.txt)}
```

### Writing a Resource

The `writeAsJson` method of the `resource` task can write a JSON object into a
JSON-file resource.

```yaml
- flows:
    default:
    - set:
       newObj:
        name: testName
        type: testType
    - log: ${resource.writeAsJson(newObj)} 
```


The `writeAsString` method is used to write a file with `string` content.

```yaml
- log: ${resource.writeAsString('test string')} 
```

The `writeAsJson` and `writeAsString` methods return path of the newly created
file as result. These values can be stored in a variable later be used to read
content back into the process with the read methods.
