---
layout: wmt/docs
title:  Crypto
side-navigation: wmt/docs-navigation.html
---

# Crypto task

This task provides the methods to work with Concord's secrets store
as well as the methods to encrypt and decrypt simple values without
storing.

  * [Exporting a SSH key pair](#exporting-a-ssh-key-pair)
  * [Exporting credentials (username/password pairs)](#exporting-credentials--username-password-pairs-)
  * [Encrypting a value without storing it](#encrypting-a-value-without-storing-it)
  * [Decrypting a value](#decrypting-a-value)

## Exporting a SSH key pair

A SSH key pair, [stored in the secrets store](../api/secret.html) can
be exported as a pair of files into a process' working directory:
```yaml
- ${crypto.exportKeyAsFile('myKey', 'myKeyPassword')}
```

This expression returns a map with two keys:
- `public` - relative path to the public key of the key pair;
- `private` - same but for the private key.

Full example:
```
$ curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F storePassword=12345678 'http://localhost:8001/api/v1/secret/keypair?name=myKey'
{

  "name" : "myKey",
  "publicKey" : "...",
  "exportPassword" : "12345678",
  "ok" : true
}
```

```yaml
flows:
  main:
  - expr: ${crypto.exportKeyAsFile('myKey', 'myKeyPassword')}
    out: myKeys
  - log: "Public: ${myKeys.public}"
  - log: "Private: ${myKeys.private}"
```

The keypair password itself can be encrypted using a [simple single
value encryption](#encrypting-a-value-without-storing-it) described
below.

## Exporting credentials (username/password pairs)

Usage:
```yaml
- ${crypto.exportCredentials('myCredentials', 'myPassword')}
```

The expression returns a map with two keys:
- `username` - username part of the credentials;
- `password` - password part of the credentials.

## Encrypting a value without storing it

A value can be encrypted with a project's key and subsequently
decrypted in the same project's process.

```
curl -H "Content-Type: application/json" \
-H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
-d '{ "value": "my secret value" }' \
http://localhost:8001/api/v1/project/myProject/encrypt
```

The result will look like this:

```json
{
  "data" : "4d1+ruCra6CLBboT7Wx5mw==",
  "ok" : true
}
```

The value of `data` field must be used as-is as a process variable.
It can be added to the Concord file, project's configuration or to
request JSON.

A value can be encrypted and decrypted only by the same server.

## Decrypting a value

To decrypt the previously encrypted value:

```yaml
- ${crypto.decryptString("4d1+ruCra6CLBboT7Wx5mw==")}
```

Alternatively, the encrypted value can be passed as a variable:

```yaml
- ${crypto.decryptString(mySecret)}
```

Full example:

```
$ curl -H "Content-Type: application/json" \
-H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
-d '{ "value": "Concord" }' \
http://localhost:8001/api/v1/project/myProject/encrypt

{
  "data" : "4d1+ruCra6CLBboT7Wx5mw==",
  "ok" : true
}
```

```yaml
flows:
  main:
  - log: "Hello, ${name}"

configuration:
  entryPoint: main
  arguments:
    name: ${crypto.decryptString("4d1+ruCra6CLBboT7Wx5mw==")}
```
