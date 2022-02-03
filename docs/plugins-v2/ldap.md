---
layout: wmt/docs
title:  LDAP Task
side-navigation: wmt/docs-navigation.html
description: Plugin for executing LDAP queries
---

# {{ page.title }}

The `ldap` task supports several search queries to an LDAP server.

- [Usage](#usage)
- [Overview](#overview)

Possible search operations are: 

- [Search for an entry by DN](#search-by-dn)
- [Search for a user](#get-user)
- [Search for a group](#get-group)
- [Check user is a member of a group](#is-member-of)
  
<a name="usage"/>

## Usage

To be able to use the `ldap` task in a Concord flow, it must be added as a
[dependency](../processes-v2/configuration.html#dependencies):

```yaml
configuration:
  dependencies:
  - mvn://com.walmartlabs.concord.plugins:ldap-task:{{ site.concord_plugins_version }}
```

This adds the task to the classpath and allows you to invoke the
[LDAP task](#overview).

<a name="overview"/>

## Overview

The `ldap` task allows users to make search queries to an LDAP server as a step of
a flow. It uses a number of required input parameters that are common for all
operations:

- `action`: determines the operation to be performed with the current
  invocation of the LDAP task
- `ldapAdServer`: URL to the LDAP server, e.g `ldap://hostname.domain.com:3268`
- `bindUserDn`: the identifier of the account which is used to bind to the LDAP
  server for the operation
- `bindPassword`: the password of the `bindUserDn` identifier, typically
  provided by usage of the [Crypto task](./crypto.html)
- `searchBase`: defines the starting point for the search in the directory tree, e.g. `DC=subdomain,DC=domain,DC=com`

The `ldapAdServer` variable configures the
connection to the LDAP server. It is best configured globally by a
[default process configuration](../getting-started/policies.html#default-process-configuration-rule)
policy:

```json
{
  "defaultProcessCfg": {
    "defaultTaskVariables": {
      "ldap": {
        "ldapAdServer": "ldap://hostname.domain.com:3268"
      }
    }
  }
}
```

A minimal configuration taking advantage of a globally configured API URL
includes the `action` to perform, the `searchBase`, and any additional
parameters needed for the action:

```yaml
flows:
  default:
  - task: ldap
    in:
      bindUserDn: "CN=example,CN=Users,DC=subdomain,DC=domain,DC=com"
      bindPassword: "${crypto.exportAsString('bindPassword', 'myStorePassword')}"
      action: getUser
      searchBase: "DC=subdomain,DC=domain,DC=com"
      user: "userId"
      ....
```

<a name="searchByDn"/>

## Search By DN

The LDAP task can be used to search for an LDAP entry by DN (Distinguished Name)
with the `searchByDn` action.

```yaml
flows:
  default:
  - task: ldap
    in:
      bindUserDn: "CN=example,CN=Users,DC=subdomain,DC=domain,DC=com"
      bindPassword: "${crypto.exportAsString('bindPassword', 'myStorePassword')}"
      action: searchByDn
      searchBase: "DC=subdomain,DC=domain,DC=com"
      dn: "CN=exampleCN1,CN=exampleCN2,DC=subdomain,DC=domain,DC=com"
      out: searchByDnResult
```

Additional parameters to use are:

- `dn`: the distinguished name of the LDAP entry

<a name="getUser"/>

## Get User

The LDAP task can be used to search for a user with the `getUser` action.

```yaml
flows:
  default:
  - task: ldap
    in:
      bindUserDn: "CN=example,CN=Users,DC=subdomain,DC=domain,DC=com"
      bindPassword: "${crypto.exportAsString('bindPassword', 'myStorePassword')}"
      action: getUser
      searchBase: "DC=subdomain,DC=domain,DC=com"
      user: ${initiator.username}
      out: getUserResult
```

Additional parameters to use are:

- `user`: the user id, email address, or user principal name to search for

<a name="getGroup"/>

## Get Group

The LDAP task can be used to search for a group with the `getGroup` action. You
can specify whether it is a security group or not by `securityEnabled`

```yaml
flows:
  default:
  - task: ldap
    in:
      bindUserDn: "CN=example,CN=Users,DC=subdomain,DC=domain,DC=com"
      bindPassword: "${crypto.exportAsString('bindPassword', 'myStorePassword')}"
      action: getGroup
      searchBase: "DC=subdomain,DC=domain,DC=com"
      group: "mySecurityGroupName"
      securityEnabled: true
      out: getGroupResult
```

Additional parameters to use are:

- `group`: the identifier of the issue
- `securityEnabled`: a boolean (`true`/`false`) that determines whether to
  search for security group or not

<a name="isMemberOf"/>

## Is Member Of

The LDAP task can be used to check whether a user is a member of a particular
group, includeing recursive searching, with the `isMemberOf` action.

```yaml
flows:
  default:
  - task: ldap
    in:
      bindUserDn: "CN=example,CN=Users,DC=subdomain,DC=domain,DC=com"
      bindPassword: "${crypto.exportAsString('bindPassword', 'myStorePassword')}"
      action: isMemberOf
      searchBase: "DC=subdomain,DC=domain,DC=com"
      user: ${initiator.username}
      group: "mySecurityGroupName"
      securityEnabled: true
      out: isMemberOfResult
```

- `user`: the user id, email address, or user principal name to search for
- `group`: the identifier of the issue
- `securityEnabled`: a boolean (`true`/`false`) that determines whether to
  search for security group or not
