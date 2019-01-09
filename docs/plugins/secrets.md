---
layout: wmt/docs
title:  Secrets Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `secrets` task is used for reading, writing, deleting and validating
data from Concord.

- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)

<a name="usage">
## Usage

To be able to use the tasks in a Concord flow, the `secrets` plugin must be added
as a [dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:secrets-tasks:{{ site.concord_version }}
```

This adds the task to the classpath and allows you to invoke it in any flow.

Supported `action`s are `get` (default), `create`, `validate`, `update` and `delete`.

All actions except `delete` returns a result that can be used in the flow.

- `create` -> `${result}`: the newly created secrets data.
- `get` -> `${result}`: the value of the secret.
- `validate, update` -> `${result}`: A validation status (one of `ok`,
    `missing`, `invalid`, and `notOwned`).

<a name="parameters">
## Parameters

### Common Parameters

* `action` (optional) - The action, one of `get` (default), `create`, `validate`,
    `update` and `delete`.
* `name` (required) - The name of the secret.
* `storePassword` (optional) The password the secret will be encrypted with. If
    left bland the secret will be readable without a password.

### Parameters for Create

* `action` (optional) - The action, one of `get` (default), `create`, `validate`,
    `update` and `delete`.
* `name` (required) - The name of the secret.
* `storePassword` (optional) The password the secret will be encrypted with. If
    left bland the secret will be readable without a password.
* `data` (required) - The data for the secret.

### Parameters for Update

* `newStorePassword` (optional) - A new password for encrypting the secret.
* `data` (optional) - New data for the secret.

### Parameters for Delete

* `skipValidation` (optional) - Allow deleting a secret without giving
    a password, defaults to false.

<a name="examples">
## Examples

Create a secret.

```yaml
  create-secret:
    - log: "Create secret"
    - task: secrets
      in:
        action: create
        name: anders-test-secret
        data: anders-test-value
        storePassword: Dingo1234
    - log: "Create Result: ${result}"

```

Get a secret.

```yaml
  get-secret:
    - log: "Get secret"
    - task: secrets
      in:
        name: anders-test-secret
        storePassword: Dingo1234
    - log: "Get Result: ${result}"
```

Validate a secret exists
```yaml
  validate-secret:
    - log: "Validate secret"
    - task: secrets
      in:
        action: validate
        name: anders-test-secret
        storePassword: Dingo1234
    - log: "Validate Result: ${result}"
    - if: ${result != "ok"}
      then:
        - throw: "Expected 'ok', got ${result}"
```
Update a secret's password.

```yaml
  update-secret-password:
    - log: "Update secret password"
    - task: secrets
      in:
        action: update
        name: anders-test-secret
        storePassword: Dingo1234
        newStorePassword: Tapir1234
```

Delete a secret without knowing the `storePassword`.
```yaml
  delete-secret:
    - log: "Delete secret"
    - task: secrets
      in:
        action: delete
        name: anders-test-secret2
        skipValidation: true
```
