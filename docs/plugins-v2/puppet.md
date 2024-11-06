---
layout: wmt/docs
title:  Puppet Task
side-navigation: wmt/docs-navigation.html
description: Plugin for interacting with Puppet's REST API
---

# {{ page.title }}

The `puppet` task allows users to interact with various
[Puppet Enterprise](https://puppet.com/) API endpoints.

- [Usage](#usage)
- [Task Output](#task-output)
- [Creating an API Token](#api-token)
- [Executing PuppetDB Query](#db-query)
  - [Filtering Results](#filtering-results)
- [Using Self-Signed Certificates](#certificates)
  - [Text](#cert-text)
  - [Path](#cert-path)
  - [Secret](#cert-secret)
  - [Disabling Certificate Validation](#cert-ignore)

<a name="usage"/>

## Usage

To be able to use the task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:puppet-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the task in a flow:

```yaml
flows:
  default:
  - task: puppet
    in:
      action: "createApiToken"
      rbacUrl: 'https://peconsole.example.com:4433'
      username: 'my-user'
      password: 'my-pass'
      lifetime: '1y'
      label: 'one year token'
      description: 'Created by Puppet Task for Concord'
    out: tokenResult

  - task: puppet
    in:
      action: "pql"
      databaseUrl: 'https://puppetdb.example.com:8081'
      apiToken: 'puppet-api-token'
      queryString: "inventory{ limit 10 }"
    out: queryResult
```

__Common Parameters__

- `action`: Action to perform
  - `createApiToken`: Create an API token
  - `pql`: Execute a Puppet Query Language query
- `certificate`: Certificate for validating SSL connections with self-signed
  certificates
  - `path`: Path to Base64-encoded certificate file
  - `secret`: Single-value file Concord secret holding Base64-encoded certificate
    file
    - `org`: Concord organization where the secret is saved
    - `name`: Name of the secret
    - `password`: Optional password for the secret
  - `text`: Base64 encoded certificate string
- `connectTimeout`: Network connect timeout in seconds, default value is `30`
- `debug`: If `true`, enables additional debug output
- `ignoreErrors`: If `true`, exceptions are suppressed. `${result.ok}` is set to
  `false` when exceptions are encountered. `${result.error}` contains the
  exception message
- `puppetParams`: Map to hold default values for any other parameters for
  the Puppet Task
- `readTimeout`: Network read timeout ins seconds, default value is `30`
- `validateCerts`: If `true`, ignored certificate verification on HTTPS URLs
- `writeTimeout`: Network write timeout in seconds, default value is `30`

__`createApiToken` Action Parameters__

- `password`: Password for authentication
- `rbacUrl`: URL for RBAC API queries
- `tokenDescription`: Token description
- `tokenLabel`: Token label
- `tokenLife`: Token lifetime. Number followed by y (years), d (days), h (hours),
  m (minutes), or s (seconds)
- `username`: Username for authentication

__`pql` Action Parameters__

- `apiToken`: API token for authentication
- `databaseUrl`: URL for executing database API queries
- `queryString`: PQL statement to execute

<a name="task-output"/>

## Task Output

In addition to
[common task result fields](../processes-v2/flows.html#task-result-data-structure),
the `puppet` task returns:

- `data` - Data returned from the Puppet API. Type (e.g. String, Map, List) depends
  on the `action` used;


The results of the task are saved into the `result` variable.

```yaml
flows:
  default:
  - task: puppet
    in:
      ...
  - if: ${result.ok}
    then:
      - log: "Puppet query result: ${result.data}"
    else:
      - log: "Error with task: ${result.error}"
```

<a name="api-token"/>

## Creating an API Token

> Note that API tokens can only be created with the RBAC API which is part of
> [Puppet Enterprise](https://puppet.com/products/puppet-enterprise)

Concord can generate API tokens for use to authenticate with other Puppet API
endpoints.

```yaml
flows:
  default:
  - task: puppet
    in:
      action: "createApiToken"
      rbacUrl: 'https://peconsole.example.com:4433'
      username: 'my-user'
      password: 'my-pass'
      tokenLife: '1y'
      label: 'One year token'
      description: 'created by Puppet Task for Concord'
    out: result
  # don't actually log an API token
  - log: "Got API token: ${result.data}"
```

<a name="db-query"/>

## Executing PuppetDB Query

Concord can execute [PQL queries](https://puppet.com/docs/puppetdb/7/api/query/v4/pql.html).

```yaml
flows:
  default:
  - task: puppet
    in:
      action: "pql"
      databaseUrl: 'https://puppetdb.example.com:8081'
      apiToken: 'my-api-token'
      queryString: 'inventory[certname]{ limit 5 }'
    out: result
```

### Filtering Results

The value of `result.data` of the example query above is a list of objects

```json
[
  {
    "certname": "host01.example.com"
  },
  {
    "certname": "host02.example.com"
  },
  {
    "certname": "host03.example.com"
  },
  {
    "certname": "host04.example.com"
  },
  {
    "certname": "host05.example.com"
  }
]
```

You can filter the objects down to a more simple list of strings with an
expression.

```yaml
- expr: "${result.data.stream().map(x -> x.get('certname')).toList()}"
  out: namesOnly
```

The value of `namesOnly` is a list of strings:

```json
[
  "host01.example.com",
  "host02.example.com",
  "host03.example.com",
  "host04.example.com",
  "host05.example.com"
]
```

<a name="certificates"/>

## Using Self-Signed Certificates

API endpoints which use self-signed certificates for SSL connections require
a public certificate to be provided to the Puppet Task. Use one of three ways to
provide the cert to the task. Alternatively, ignore certificate verification
altogether.

```text
# Get the public cert from Puppet Master of Masters
curl -k https://mom.example.com:8140/puppet-ca/v1/certificate/ca

# output
-----BEGIN CERTIFICATE-----
MIICsDCCAZgCCQDw4hBBzMyVRzANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDDA93
d3cuZXhhbXBsZS5jb20wHhcNMTkwNTIxMTMxMjQ3WhcNMjkwNTE4MTMxMjQ3WjAa
MRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQC9Ll8J5ravkkCIw0szg3LPH7crfHdnJ0QHPHJUCuu3+7YPfXAA
PLu59bEasI/Hfa6LiW1YTYVrhnuA82OFLmuNqhmgHIvUDNJH5Xu/scn9r7srN67Q
x0duM0XkHi5FFbYh8lgvEUXOjfFVWkNUVmQvhd6AWHjyrw1d1GEAfMS4NhBQLfov
asP3AHEHZt8JZAs5VeG3wtcwRkAiild2OTEqVtP4lhgedfR2C10lj43b7LtxnY6k
Z2h1yedFsmKsZ+tsrP2I350qf9BDmpt5rrV3qblx6MXaHTdoV1xl5bKXqWzDcXXX
cBhy0wEKIQNNX+qPtGo461oWDDbWddajPfcFAgMBAAEwDQYJKoZIhvcNAQELBQAD
ggEBAGdy6scvRQOWvSJ1gcKgIXrhgd6RbGq7ccyZusOYOvg2pKxPKDiTpaRx9zr4
HDyryfXQmQsmcahuGcO3EroQh+KPCHrMOZgUTrZEGNct6na/eCHm5rJB1uY7dkyt
a/lSBtgE/jjmsRS4vSN6DXPFmkpFGsY4gUu0v/66NaWWY+Ak6NzvXoEys4eKJ4k6
aC1fpp7rBer1wSgzFxkmnS+aPl9Yic46BLk1mPMSEn3BabnYzDjC/Q/+CTNINoR2
r2xDuuKuhiCgxevHQ48w+QoxMNgtdfaWLD+A9uV3Ds+hN2eJCh/sVzisjechX89s
xZHfg5zRgZavH0uRF/FEkjnXD1I=
-----END CERTIFICATE-----
```

<a name="cert-text"/>

### Text

Provide the Base64-encoded certificate text as a parameter for the task.

```yaml
- task: puppet
  in:
    certificate:
      text: |
        -----BEGIN CERTIFICATE-----
        MIICsDCCAZgCCQDw4hBBzMyVRzANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDDA93
        d3cuZXhhbXBsZS5jb20wHhcNMTkwNTIxMTMxMjQ3WhcNMjkwNTE4MTMxMjQ3WjAa
        MRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IB
        DwAwggEKAoIBAQC9Ll8J5ravkkCIw0szg3LPH7crfHdnJ0QHPHJUCuu3+7YPfXAA
        PLu59bEasI/Hfa6LiW1YTYVrhnuA82OFLmuNqhmgHIvUDNJH5Xu/scn9r7srN67Q
        x0duM0XkHi5FFbYh8lgvEUXOjfFVWkNUVmQvhd6AWHjyrw1d1GEAfMS4NhBQLfov
        asP3AHEHZt8JZAs5VeG3wtcwRkAiild2OTEqVtP4lhgedfR2C10lj43b7LtxnY6k
        Z2h1yedFsmKsZ+tsrP2I350qf9BDmpt5rrV3qblx6MXaHTdoV1xl5bKXqWzDcXXX
        cBhy0wEKIQNNX+qPtGo461oWDDbWddajPfcFAgMBAAEwDQYJKoZIhvcNAQELBQAD
        ggEBAGdy6scvRQOWvSJ1gcKgIXrhgd6RbGq7ccyZusOYOvg2pKxPKDiTpaRx9zr4
        HDyryfXQmQsmcahuGcO3EroQh+KPCHrMOZgUTrZEGNct6na/eCHm5rJB1uY7dkyt
        a/lSBtgE/jjmsRS4vSN6DXPFmkpFGsY4gUu0v/66NaWWY+Ak6NzvXoEys4eKJ4k6
        aC1fpp7rBer1wSgzFxkmnS+aPl9Yic46BLk1mPMSEn3BabnYzDjC/Q/+CTNINoR2
        r2xDuuKuhiCgxevHQ48w+QoxMNgtdfaWLD+A9uV3Ds+hN2eJCh/sVzisjechX89s
        xZHfg5zRgZavH0uRF/FEkjnXD1I=
        -----END CERTIFICATE-----
    ...
```

<a name="cert-path"/>

### Path

Provide the certificate file in the project's repository or in the payload to
start the process.

```yaml
- task: puppet
  in:
    certificate:
      path: path/to/cert
    ...
```

<a name="cert-secret"/>

### Secret

Create a Concord secret with the certificate in a Base64-encoded format file.

```yaml
# Provide the cert from a Concord secret (single value, file)
- task: puppet
  in:
    certificate:
      secret:
        org: my-org
        name: my-secret
        password: secret-pass # or null, if no password
    ...
```

<a name="cert-ignore"/>

### Disabling Certificate Validation

Set the `validateCerts` parameter to `false` to disabling certificate validation

```yaml
- task: puppet
  in:
    validateCerts: false
    ...
```
