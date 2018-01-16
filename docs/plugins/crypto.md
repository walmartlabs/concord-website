---
layout: wmt/docs
title:  Crypto Task
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

The `crypto` task provides methods to work with Concord's
[secrets store](../api/secret.html) as well as the methods to encrypt and
decrypt simple values without storing.

- [Exporting a SSH key pair](#ssh-key)
- [Exporting Credentials](#credentials)
- [Encrypting and Decrypting Values](#encrypting)
  
The task is provided automatically by the Concord and does not
require any external dependencies.

<a name="ssh-key"/>
## Exporting a SSH key pair

A SSH key pair, [stored in the secrets store](../api/secret.html) can
be exported as a pair of files into a process' working directory:

```yaml
- ${crypto.exportKeyAsFile('myKey', 'myKeyPassword')}
```

This expression returns a map with two keys:
- `public` - relative path to the public key of the key pair;
- `private` - same but for the private key.

A full example adds a key via the REST API with the default user credentials:

```
$ curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F storePassword="myKeyPassword" 'http://localhost:8001/api/v1/secret/keypair?name=myKey'
{

  "name" : "myKey",
  "publicKey" : "...",
  "exportPassword" : "myKeyPassword",
  "ok" : true
}
```

And subsequently exports the key in the default flow.

```yaml
flows:
  default:
  - expr: ${crypto.exportKeyAsFile('myKey', 'myKeyPassword')}
    out: myKeys
  - log: "Public: ${myKeys.public}"
  - log: "Private: ${myKeys.private}"
```

The keypair password itself can be encrypted using a 
[simple single value encryption](#encrypting) described below.

<a name="credentials"/>
## Exporting Credentials

Credentials, so username and password pairs, can be exported with:

```yaml
- ${crypto.exportCredentials('myCredentials', 'myPassword')}
```

The expression returns a map with two keys:
- `username` - username part
- `password` - password part

<a name="plain"/>
## Exporting Plain Secrets

A "plain" secret is a single encrypted value, which is stored using
the REST API or the UI and retrieved using the
`crypto.exportAsString` method:
    
```
$ curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F storePassword="myPassword" -F secret="my value" 'http://localhost:8001/api/v1/secret/plain?name=mySecret'
```

```yaml
- log: "${crypto.exportAsString('mySecret', 'myPassword')}"
```

In this example, `my value` will be printed in the log.

Alternatively, the `crypto` task provides a method to export plain
secrets as files:
```yaml
- log: "${crypto.exportAsFile('mySecret', 'myPassword')}"
```

The method returns a path to the temporary file containing the
exported secret.

<a name="encrypting"/>
## Encrypting and Decrypting Values

A value can be encrypted with a project's key and subsequently
decrypted in the same project's process. The value is not persistently stored.


The REST API can be used to encrypt the value using the the project specific key
and the `encrypt` context:

```
curl -H "Content-Type: application/json" \
-H "Authorization: auBy4eDWrKWsyhiDp3AQiw" \
-d '{ "value": "my secret value" }' \
http://localhost:8001/api/v1/project/myProject/encrypt
```

The result returns the encrypted value in the `data` element:

```json
{
  "data" : "4d1+ruCra6CLBboT7Wx5mw==",
  "ok" : true
}
```

The value of `data` field can be used as a process variable by adding it as an
attribute in the Concord file, in the project's configuration or can be supplied 
to a specific process execution in the  request JSON.

A value can be encrypted and decrypted only by the same server.

To decrypt the previously encrypted value:

```yaml
- ${crypto.decryptString("4d1+ruCra6CLBboT7Wx5mw==")}
```

Alternatively, the encrypted value can be passed as a variable:

```yaml
- ${crypto.decryptString(mySecret)}
```

The following example uses the `decryptString` method of the `crypto` task to set
the value of the `name` attribute: 

```yaml
flows:
  default:
  - log: "Hello, ${name}"

configuration:
  arguments:
    name: ${crypto.decryptString("4d1+ruCra6CLBboT7Wx5mw==")}
```
