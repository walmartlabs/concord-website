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

Supported `action`s are `GET` (default), `CREATE`, `VALIDATE`, `UPDATE` and
`DELETE`.

All actions return a `${result}` object with the following fields:
- `ok` - boolean: `true` if the operation was successful;
- `status` - string: `OK`, `NOT_FOUND`, `INVALID_REQUEST` and `ACCESS_DENIED`;
- `data` - string: only for `GET` action.

## Parameters

### Common Parameters

- `action` - string, optional: the action, one of `GET` (default), `CREATE`, `VALIDATE`, `UPDATE` and `DELETE`.
- `name` - string, required: the name of the secret;
- `storePassword` - string, optional: the password the secret is encrypted with. If left blank, the secret has
to be readable without a password;
- `ignoreError` - boolean, optional: if `true` the plugin will return the error in `${result.status}` instead of
throwing an exception.

### Parameters for Create

- `data` - string or a byte array, required: the data for the secret.

### Parameters for Update

- `newStorePassword` - string, optional: a new password for encrypting the secret;
- `data` - string or a byte array, required: new data for the secret.

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

Get a secret:
```yaml
  get-secret:
  - log: "Get secret"
  - task: secrets
    in:
      name: anders-test-secret
      storePassword: Dingo1234
  - log: "Get Result: ${result}"
```

Check if a secret exists:
```yaml
  validate-secret:
  - log: "Validate secret"
  - task: secrets
    in:
      action: GET
      name: anders-test-secret
      storePassword: Dingo1234
      ignoreErrors: true
  - log: "Validate Result: ${result}"
  - if: ${result != "OK"}
    then:
      - throw: "Secret doesn't exist"
```

Replace a secret's password:
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

Delete a secret:
```yaml
  delete-secret:
  - log: "Delete secret"
  - task: secrets
    in:
      action: DELETE
      name: anders-test-secret2
```
