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

## Usage

To be able to use the tasks in a Concord flow, the `concord-tasks` plugin must
be added as a [dependency](../getting-started/concord-dsl.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins.basic:concord-tasks:{{ site.concord_core_version }}
```

This adds the task to the classpath and allows you to invoke it in any flow.

Supported `action`s are `GET` (default), `CREATE`, `VALIDATE`, `REPLACE` and
`DELETE`. `REPLACE` first deletes the secret and then creates it again.

All actions, except `DELETE`, return a result that can be used in the flow.

- `CREATE` -> `${result}`: the newly created secrets data.
- `GET` -> `${result}`: the value of the secret.
- `VALIDATE, REPLACE` -> `${result}`: A validation status (one of `OK`,
    `MISSING`, `INVALID`, and `NOT_OWNED`).

## Parameters

### Common Parameters

* `action` (optional): The action, one of `GET` (default), `CREATE`, `VALIDATE`,
    `UPDATE` and `DELETE`.  `REPLACE` first deletes the secret and then creates
    it again.
* `name` (required): The name of the secret.
* `storePassword` (optional): The password the secret is encrypted with. If left
    blank, the secret has to be readable without a password.

### Parameters for Create

* `data` (required): The data for the secret.

### Parameters for Update

* `newStorePassword` (optional):  A new password for encrypting the secret.
* `data` (optional): New data for the secret.

### Parameters for Delete

* `skipValidation` (optional): Allow deleting a secret without giving a
    password, defaults to false.

## Examples

Create a secret.

```yaml
  create-secret:
  - log: "Create secret"
  - task: secrets
    in:
      action: CREATE
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
      action: VALIDATE
      name: anders-test-secret
      storePassword: Dingo1234
  - log: "Validate Result: ${result}"
  - if: ${result != "ok"}
    then:
      - throw: "Expected 'ok', got ${result}"
```
Replace a secret's password.

```yaml
  replace-secret-password:
  - log: "Replace secret password"
  - task: secrets
    in:
      action: UPDATE
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
      action: DELETE
      name: anders-test-secret2
      skipValidation: true
```
