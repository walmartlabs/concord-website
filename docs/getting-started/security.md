---
layout: wmt/docs
title:  Security and Permissions
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

- [Authentication](#authentication)
- [Managing credentials](#managing-credentials)

## Authentication

### Using API keys

The key must be passed in the `Authorization` header on every API request. For example:
```
curl -v -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" ...
```

API keys are managed using the [API key](../api/apikey.html) endpoint.

### Using Username and Password

For example:
```
curl -v -u myuser:mypwd ...
```

The actual user record will be created on the first successful authentication attempt.
After that, it can be managed as usual, by using the [User](../api/user.html) API endpoint.

Username/password authentication uses an LDAP/Active Directory realm. Check
[Configuration](./configuration.html#ldap) document for details.

## Managing Credentials

Credentials (secrets) are managed using the user interface or the 
[secret](../api/secret.html) API endpoint.
