---
layout: wmt/docs
title:  Vault by HashiCorp Task
side-navigation: wmt/docs-navigation.html
deprecated: true
description: Plugin for handling Vault secret data
---

# {{ page.title }}

The `hashivault` task allows workflows to read and write secrets
with [Vault by HashiCorp](https://www.vaultproject.io/).

- [Usage](#usage)
- [Task Output](#task-output)
- [Setting Default Task Parameters](#setting-default-task-parameters)
- [Reading Secret Data](#reading-secret-data)
- [Writing Secret Data](#writing-secret-data)

## Usage

To enable the task in a Concord flow, it must be added as a
[dependency](../processes-v1/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:hashivault-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
    # full task call
    - task: hashivault
      in:
        action: "readKV"
        baseUrl: "https://my-vault.example.com:8200"
        path: "${vaultPath}"
    # public methods require default variables
    - expr: ${hashivault.readKV('path/to/secret', 'my-key')}
      out: singleValue
```

__Common Parameters__
- `action`: Action to perform
  - `readKV` - Read key/value data from a Vault secret
  - `writeKV` - Write key/value data to a Vault secret
- `apiToken` - Vault API token for authentication
- `apiTokenSecret` - Concord Secret details to retrieve a Vault API token
  - `org` - Concord Organization
  - `name` - Concord Secret name
  - `password` - Optional, Cord Secret password
- `baseUrl` - Vault API URL
- `engineVersion` - Optional, Vault engine version to use. Default is `2` 
- `namespace` - Optional, Vault namespace to use
- `path` - Path of the Vault secret to use
- `verifySsl` - Optional, if `false`, disables SSL verification

__`readKV` Action Parameters__
- `key` - Optional, specific Vault key to retrieve a value at

__`writeKV` Action Parameters__
- `kvPairs` - Map of key/value pairs to write to the Vault secret

## Task Output

The output of the full task call are saved into the `result` variable. This
variable includes `ok`, `data`, and `error` members.

```yaml
flows:
  default:
  - task: hashivault
    in:
      ...
  - if: ${result.ok}
    then:
      - log: "Successfully retrieved Vault data"
      # can be accessed in ${result.data}
    else:
      - log: "Error with task: ${result.error}"
```

The output of the task's public method call returns _only_ the retrieved Vault data.

```yaml
- expr: ${hashivault.readKV('path/to/secret', 'aKey')}
  out: justAString
```

## Setting Default Task Parameters

Set a `hashivaultParams` variable to provide a default set of parameters to the
task. This is helpful when the task is called multiple time and allows the use
of the task's public methods.

```yaml
configuration:
  arguments:
    hashivaultParams:
      baseUrl: "https://my-vault.example.com:8200"
      apiTokenSecret:
        org: "my-org"
        name: "my-token-secret"
      namespace: "/my-ns"

flows:
  default:
    # public methods are more succinct
    - expr: ${hashivault.readKV('path/to/secret')}
      out: kvPairs

    # or use the full call to override a default parameter
    - task: hashivault
      in:
        path: "path/to/secret"
        namespace: "/another-ns"
```

## Reading Secret Data

Use the `readKV` action to read key/value pairs from a Vault secret. Additionally,
use the `key` parameter to read a single value from a Vault secret.

```yaml
- task: hashivault
  in:
    action: "readKV"
    baseUrl: "https://my-vault.example.com:8200"
    path: "path/to/secret"

# 'result' variable now contains:
#  ok: true/false
#  data: [ 'aKey': 'aValue', ... ]
#  error: "error string"

- task: hashivault
  in:
    action: "readKV"
    baseUrl: "https://my-vault.example.com:8200"
    path: "path/to/secret"
    key: "aKey"

# 'result' variable now contains:
#  ok: true/false
#  data: 'aValue'
#  error: "error string"
```

The task's public can be used to retrieve only the data when
[default parameters](#setting-default-task-parameters) are set.

```yaml
- expr: ${hashivault.readKV('path/to/secret')}
  out: result
# 'result' variable now contains:
# [ 'aKey': 'aValue', ... ]

- expr: ${hashivault.readKV('path/to/secret', 'aKey')}
  out: result
# 'result' variable now contains:
# 'value'
```

The public method calls can be plugged directly into other task calls.

```yaml
- task: ansible
  in:
    vaultPassword: ${hashivault.readKV('path/to/secret', 'vault-pass')}
    ...
```

## Writing Secret Data

Use the `writeKV` action to write key/value pairs to a Vault secret.

```yaml
- task: hashivault
  in:
    action: "writeKV"
    baseUrl: "https://my-vault.example.com:8200"
    path: "path/to/secret"
    kvPairs:
      aKey: "a-value"
      bKey: "b-value"

# 'result' variable now contains:
#  ok: true/false
#  data: null
#  error: "error string"
```

The task's public can be used to write the data when
[default parameters](#setting-default-task-parameters) are set.

```yaml
- set:
    kvPairs:
      aKey: "a-value"
      bKey: "b-value"
- ${hashivault.writeKV('path/to/secret', kvPairs)}
# nothing returned
```
