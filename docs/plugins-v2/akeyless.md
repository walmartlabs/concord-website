---
layout: wmt/docs
title: Akeyless Task
side-navigation: wmt/docs-navigation.html
deprecated: true
description: Plugin for handling Akeyless secret data
---

# {{ page.title }}

The `akeyless` task allows workflows to interact with various
[Akeyeless](https://www.akeyless.io/) API endpoints.

- [Usage](#usage)
- [Task Output](#task-output)
- [Setting Default Task Parameters](#setting-default-task-parameters)
- [Get Access Token](#get-access-token)
- [Get Secret Data](#get-secret-data)
- [Get Multiple Secrets](#get-multiple-secrets)
- [Create a Secret](#create-a-secret)
- [Update a Secret](#update-a-secret)
- [Delete a Secret](#delete-a-secret)

## Usage

To enable the task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:akeyless-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
    # full task call
    - task: akeyless
      in:
        action: getSecret
        path: "/my-secret"
      out: result
    # shorthand, public method
    - expr: "${akeyless.getSecret('/my-secret')}"
      out: singleValue
```

__Common Parameters__
- `action`: Action to perform. One of:
    - `auth` - Retrieves an API access token
    - `createSecret` - Create a static secret
    - `deleteItem` - Delete an item
    - `getSecret` - Get value for one secret path
    - `getSecrets` - Get value for multiple secret paths
    - `updateSecret` - Update a secret's value
- `apiBasePath` - Akeyless API URL
- `debug`: optional `boolean`, enabled extra debug log output for troubleshooting
- `accessToken` - API access token. Supersedes `auth` parameter
- `auth` - API authentication info. Used to generate an authentication token when
  `accessToken` is not provided. Supported authentication methods are:
    - `apiKey` - Details for [API Key authentication method](https://docs.akeyless.io/docs/api-key)
        - `accessId`
        - `accessKey`

## Task Output

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the output of the full `akeyless` task call returns:

- `data` - map of retrieved secret data;

```yaml
configuration:
  arguments:
    myPath: "/my-secret"
flows:
  default:
    - task: akeyless
      in:
        action: getSecret
        path: "${myPath}"
      out: result
    - if: ${result.ok}
      then:
        - log: "Successfully retrieved secret data"
        # can be accessed in ${result.data[myPath]}
      else:
        - log: "Error with task: ${result.error}"
```

The output of public method calls may different depending on the method called.
See the documentation for the specific method for output details.

## Setting Default Task Parameters

Set a `akeylessParams` variable to provide a default set of parameters to the
task. This is helpful when the task is called multiple time and allows the use
of the task's public methods.

```yaml
configuration:
  arguments:
    akeylessParams:
      apiBasePath: "https://api.akeyless.io"
      auth:
        apiKey:
          accessId: { org: "Default", name: "dev-akeyless-id" }
          accessKey: { org: "Default", name: "dev-akeyless-key" }

flows:
  default:
    # public methods are more succinct
    - expr: "${akeyless.getSecret('/my-secret')}"
      out: secretData

    # or use the full call to override a default parameter
    - task: akeyless
      in:
        apiBasePath: # override apiBasePath here
        action: getSecret
        # ...
      out: result
```

## Get Access Token

Use the `auth` action to generate an access token from a given authentication method.

```yaml
- task: akeyless
  in:
    action: auth
  out: result
# 'result' variable now contains:
# {
#   "data": {
#     "accessToken" : "<the-actual-value>"
#   }
# }
```

## Get Secret Data

Use the `getSecret` action to get the value of a single secret.

```yaml
- task: akeyless
  in:
    action: getSecret
    path: "/my-secret"
  out: result
# 'result' variable now contains:
# {
#   "data": {
#     "/my-secret" : "<the-actual-value>"
#   }
# }
```

The task's public can be used to retrieve only the data when
[default parameters](#setting-default-task-parameters) are set.

```yaml
- set: # value is just the secret string
    mySecretData: "${akeyless.getSecret('/my-secret')}"
```

## Get Multiple Secrets

Use the `getSecrets` action to get the values of multiple secrets in one call.

```yaml
- task: akeyless
  in:
    action: getSecrets
    paths:
      - "/my-first-secret"
      - "/subpath/my-second-secret"
    out: result
# 'result' variable now contains:
# {
#   "data": {
#     "/my-first-secret" : "<the-actual-value1>",
#     "/subpath/my-second-secret" : "<the-actual-value2>"
#   }
# }
```

## Create a Secret

Use the `createSecret` action to create a static secret.

Available parameters:

- `path`: name, including full path, of the secret
- `value`: secret value
- `description`: optional `String`, description of the secret
- `multiline`: optional `boolean`, The provided value is a multiline value
  (separated by `'\n'`). Default is `false`
- `protectionKey`: optional `String`, The name of a key used to encrypt the
  secret value (if empty, the account default protection key is used)
- `tags`: optional list of `String` values, List of tags to apply to the secret

```yaml
- task: akeyless
  in:
    action: createSecret
    path: "/path/to/my-secret"
    value: "don't hardcode this"
    description: "This is my super secret secret"
```

## Update a Secret

Use the `upateSecret` action to update a secret.

Available parameters:

- `path`: name, including full path, of the secret
- `value`: secret value
- `multiline`: optional `boolean`, The provided value is a multiline value
  (separated by `'\n'`). Default is `false`
- `protectionKey`: optional `String`, The name of a key used to encrypt the
  secret value (if empty, the account default protection key is used)
- `keepPreviousVersion`: optional `boolean`, when `true` keeps the previous version
  in the secret's history. Default is `true`

```yaml
- task: akeyless
  in:
    action: updateSecret
    path: "/my-secret"
    value: "aNewValue"
    multiline: false
    keepPreviousVersion: false  # default is true
```

## Delete a Secret

Use the `deleteItem` action to delete an item.

Available parameters:

- `path`: name, including full path, of the secret
- `deleteImmediately`: optional `boolean`, when `true` deletes the item
  immediately. Default is `true`
- `deleteInDays`: optional `number`, sets secrets to be deleted after the given
  number of days
- `version`: optional `number`, specific version to delete. Default is all versions.
  `0`=last version, `-1`=entire item with all versions

```yaml
# delete all version of a secret
- task: akeyless
  in:
    action: deleteItem
    path: "/my-secret"

# delete on older version of a secret
- task: akeyless
  in:
    action: deleteItem
    path: "/my-secret"
    version: 2
    deleteImmediately: true # same as default

# mark secret for deletion in 15 days
- task: akeyless
  in:
    action: deleteItem
    path: "/my-secret"
    deleteInDays: 15
```
