---
layout: wmt/docs
title:  Resource Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `resource` task provides methods to persist data to a file in the scope of a
process as well as to load data from files. The `resource` task supports JSON,
YAML and `string` formats.

The task is provided automatically by Concord and does not require any
external dependencies.

## Reading a Resource

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
- log: ${resource.asString('sample-file.txt')}
```

The `asYaml` method supports reading files using the YAML format.

```yaml
- flows:
    default:
    - expr: ${resource.asYaml('sample-file.yml')}
      out: ymlObj
    # we can now use it like a simple object
    - log: ${ymlObj.any_key}
```

## Writing a Resource

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

The `writeAsYaml` method supports the YAML format.

The `writeAs*` methods return the path of the newly created file as
result. These values can be stored in a variable later be used to read content
back into the process with the read methods.

## Pretty Format

The `prettyPrintJson` method of the `resource` task allows you to create a
version of a JSON string or an object, that is better readable in a log or other
output.

```yaml
- log: ${resource.prettyPrintJson('{"testKey":"testValue"}')}
```

```yaml
- flows:
    default:
    - set:
       newObj:
        name: testName
        type: testType
    - log: ${resource.prettyPrintJson(newObj)}  
```

