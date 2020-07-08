---
layout: wmt/docs
title:  Security and Permissions
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

- [Authentication](#authentication)
- [Secret Management](#secret-management)

## Authentication

Concord supports multiple authentication methods:
- Concord API tokens;
- basic authentication (username/password);
- OpenID Connect, via [the OIDC plugin](https://github.com/walmartlabs/concord/tree/master/server/plugins/oidc).

Plugins can implement additional authentication methods.

### Using API keys

The key must be passed in the `Authorization` header on every API request. For
example:

```
curl -v -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" ...
```

API keys are managed using the [API key](../api/apikey.html) endpoint or using
the UI.

### Using Username and Password

For example:
```
curl -v -u myuser:mypwd ...
```

The actual user record will be created on the first successful authentication
attempt. After that, it can be managed as usual, by using
the [User](../api/user.html) API endpoint.

Username/password authentication uses an LDAP/Active Directory realm. Check
[Configuration](./configuration.html#ldap) document for details.

## Secret Management

Concord provides an API to create and manage various types of secrets that can
be used in user flows and for Git repository authentication.

Secrets can be created and managed using
[the Secret API endpoint](../api/secret.html) or the UI.

Supported types:
- plain strings and binary data (files) ([example](../api/secret.html#example-single-value-secret);
- username/password pairs ([example](../api/secret.html#example-username-password-secret));
- SSH key pairs ([example](../api/secret.html#example-new-key-pair)).

Secrets can optionally be protected by a password provided by the user.
Non password-protected secrets are encrypted with an environment specific key
defined in Concord Server's configuration.

Additionally, Concord supports "encrypted strings" - secrets that are stored
"inline", directly in Concord YAML files:

```yaml
flows:
  default:
    - log: "Hello, ${crypto.decryptString('aXQncyBub3QgYW4gYWN0dWFsIGVuY3J5cHRlZCBzdHJpbmc=')}"
``` 

Concord encrypts and decrypts such values by using a project-specific
encryption key. In order to use encrypted strings, the process must run in a project.

The [crypto](../plugins/crypto.html) task can be used to work with secrets and
encrypted strings.
