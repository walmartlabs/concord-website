---
layout: wmt/docs
title:  Running Flows
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

- [Overview](#overview)
- [Secrets](#secrets)
- [Dependencies](#dependencies)
- [Imports](#imports)

## Overview

**Note:** this feature is still under active development. All features
described here are subject to change.

**Note:** this feature supports only [`concord-v2` flows](../processes-v2/index.html).
The CLI tool forces the `runtime` parameter value to `concord-v2`.

The CLI tool can run Concord flows locally:

```yaml
# concord.yml
flows:
  default:
    - log: "Hello!"
```

```
$ concord run
Starting...
21:23:45.951 [main] Hello!
...done!
```

By default, `concord run` copies all files in the current directory into
a `$PWD/target` directory -- similarly to Maven.

The `concord run` command doesn't use a Concord Server, the flow execution is
purely local. However, if the flow uses external resources (such as
`dependencies` or `imports`) a working network connection might be required.

Supported features:
- all regular [flow](../processes-v2/flows.html) elements;
- [dependencies](#dependencies);
- [imports](#imports);
- [secrets](../plugins-v2/crypto.html). See [below](#secrets) for
more details.

Features that are currently *not* supported:
- [forms](../getting-started/forms.html);
- [profiles](../processes-v2/profiles.html);
- password-protected secrets.

## Secrets

By default, Concord CLI uses a local file-based storage to access
[secrets](../plugins-v2/crypto.html) used in flows.

For example, when running a flow like this:

```yaml
# concord.yml
flows:
  default:
    - log: "${crypto.exportAsString('myOrg', 'mySecretString', null)}"
```

Concord CLI looks for a `$HOME/.concord/secrets/myOrg/mySecretString` file
and returns its content.

For key pair secrets Concord CLI looks for two files:
- `$HOME/.concord/secrets/$ORG_NAME/$SECRET_NAME` (private key)
- `$HOME/.concord/secrets/$ORG_NAME/$SECRET_NAME.pub` (public key)

**Note:** currently, all secret values stored without encryption. Providing
a password in the `crypto` task arguments makes no effect.

The CLI tool also supports the `crypto.decryptString` method, but instead of
decrypting the provided string, the string is used as a key to look up
the actual value in a "vault" file.

The default value file is stored in the `$HOME/.concord/vaults/default`
directory and has very simple key-value format:
```
key = value
```

Let's take this flow as an example:

```yaml
flows:
  default:
    - log: "${crypto.decryptString('ZXhhbXBsZQ==')}"
```

When executed, it looks for the `ZXhhbXBsZQ==` key in the vault file and
returns the associated value.

```
$ cat $HOME/.concord/vaults/default
ZXhhbXBsZQ\=\= = hello!

$ concord run
Starting...
21:52:07.221 [main] hello!
...done!
```

## Dependencies

Concord CLI supports flow [dependencies](../processes-v2/configuration.html#dependencies).

By default, dependencies cached in `$HOME/.concord/depsCache/`.

For Maven dependencies Concord CLI uses [Maven Central](https://repo.maven.apache.org/maven2/)
repository by default.

## Imports

Concord CLI supports flow [imports](../processes-v2/imports.html).

For example:
```yaml
# concord.yml
imports:
  - git:
      url: "https://github.com/walmartlabs/concord.git"
      path: "examples/hello_world"
```

When executed it produces:

```
$ concord run
Starting...
21:58:37.918 [main] Hello, Concord!
...done!
```

By default, Concord CLI stores a local cache of `git` imports in
`$HOME/.concord/repoCache/$URL`.
