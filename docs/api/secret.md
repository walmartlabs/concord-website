---
layout: wmt/docs
title:  Secret
side-navigation: wmt/docs-navigation.html
---

# {{ page.title }}

A secret is either a username/password or name/ssh-key pair that is used to 
access repositories and other systems.

The REST API provides support for a number of operations:

- [Create a Secret with New SSH Key Pair](#create-secret-ssh-new)
- [Create a Secret with Existing SSH Key Pair](#create-secret-ssh-exist)
- [Get Public SSH Key of Secret](#get-key)
- [Create a Secret with Username and Password Values](#create-secret-user-pwd)
- [Add a Plain Value Secret](#create-secret-plain)
- [Delete a Secret](#delete-secret)
- [List Secrets](#list-secrets)


<a name="create-secret-ssh-new"/>
## Create a Secret with New SSH Key Pair

Generates a new SSH key pair with a name for the secret to access it. The public
key is returned in the response.


* **Permissions** `secret:create`
* **URI** `/api/v1/secret/keypair?name=${secretName}&generatePassword=${generatePassword}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Query parameters**
    - `name` - mandatory, unique name;
    - `generatePassword` - optional, if true and there is no
    `storePassword`, the server will encrypt the new secret with a
    random generated password.
* **Multipart request**
    - `storePassword` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "name": "secretName",
      "publicKey": "ssh-rsa AAAA... concord-server",
      "ok": true
    }
    ```

Examples:

On a default installation you can perform this step with the default `admin`
user and it's authorization token:

```
curl -X POST -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" 'https://concord.example.com/api/v1/secret/keypair?name=exampleSecretKey'
```

On a typical production installation you can pass your username and be quoted for the password

```
curl -u username -X POST  'https://concord.example.com/api/v1/secret/keypair?name=exampleSecretKey'
```

Or supply the password as well:

```
curl -u username:password ...
```

<a name="create-secret-ssh-exist"/>
## Create a Secret with Existing SSH Key Pair

Upload an existing SSH key pair  .

* **Permissions** `secret:create`
* **URI** `/api/v1/secret/keypair?name=${secretName}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Multipart request**
    - `${storePassword}` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back.
    - `public` - mandatory, public key, binary data;
    - `private` - mandatory, private key, binary data.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```
* **Example**
    ```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F private=@/path/to/mykey -F public=@/path/to/mykey.pub 'http://localhost:8001/api/v1/secret/keypair?name=myKey'
    ```

<a name="get-key"/>
## Get Public SSH Key of Secret

Returns a public key from an existing key pair of a secret.

* **Permissions** `secret:read:${secretName}`
* **URI** `/api/v1/secret/${secretName}/public`
* **Method** `GET`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "name": "secretName",
      "publicKey": "ssh-rsa AAAA... concord-server",
      "ok": true
    }
    ```

Examples:

On a default installation you can access a key with the default `admin` user and it's authorization token:

```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" 'https://concord.example.com/api/v1/secret/mykey/public'
```

On a typical production installation you can pass your username and be quoted
for the password:

```
curl -u username 'https://concord.example.com/api/v1/secret/mykey/public'
```

The server provides a JSON-formatted response similar to:
 
```json
{
  "name" : "exampleSecretKey",
  "publicKey" : "ssh-rsa ABCXYZ... concord-server",
  "ok" : true
}
```

The value of the `publicKey` attribute represents the public key of the newly
generated key.

The value of the `name` attribute e.g. `exampleSecretKey` identifies the key for
usage in Concord.


<a name="create-secret-user-pwd"/>
## Create a Secret with Username and Password Values

Creates a new secret containing username and password values.

* **Permissions** `secret:create`
* **URI** `/api/v1/secret/password?name=${secretName}&generatePassword=${generatePassword}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Query parameters**
    - `name` - mandatory, unique name;
    - `generatePassword` - optional, if true and there is no
    `storePassword`, the server will encrypt the new secret with a
    random generated password.
* **Multipart request**
    - `storePassword` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back;
    - `username` - mandatory, username part of the new secret;
    - `password` - mandatory, password part of the new secret.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```
* **Example**
    ```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F username=myUser -F password=myPassword -F storePassword=12345678 'http://localhost:8001/api/v1/secret/password?name=myCreds'
    ```

<a name="create-secret-plain"/>
## Add a Plain Value Secret

Adds a new secret containing a simple value.

* **Permissions** `secret:create`
* **URI** `/api/v1/secret/plain?name=${secretName}&generatePassword=${generatePassword}`
* **Method** `POST`
* **Headers** `Authorization`, `Content-Type: multipart/form-data`
* **Query parameters**
    - `name` - mandatory, unique name;
    - `generatePassword` - optional, if true and there is no
    `storePassword`, the server will encrypt the new secret with a
    random generated password.
* **Multipart request**
    - `storePassword` - optional, password, which will be used to
    encrypt the new secret and which can be used to retrieve it back;
    - `secret` - mandatory, value of the new secret. Can be a string
    or a stream of bytes.
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```
* **Example**
    ```
curl -H "Authorization: auBy4eDWrKWsyhiDp3AQiw" -F secret='my horrible secret' -F storePassword=12345678 'http://localhost:8001/api/v1/secret/plain?name=myValue'
    ```

<a name="delete-secret"/>
## Delete a Secret

Delets a secret and associated keys.

* **Permissions** `secret:delete:${secretName}`
* **URI** `/api/v1/secret/keypair?name=${secretName}`
* **Method** `DELETE`
* **Headers** `Authorization`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    {
      "ok": true
    }
    ```

<a name="list-secrets"/>
## List Secrets

Lists existing secrets.

* **Permissions**
* **URI** `/api/v1/secret?sortBy=${sortBy}&asc=${asc}`
* **Query parameters**
    - `sortBy`: `name`, `type`;
    - `asc`: direction of sorting, `true` - ascending, `false` - descending
* **Method** `GET`
* **Body**
    none
* **Success response**
    ```
    Content-Type: application/json
    ```

    ```json
    [
      { "name": "...", "type": "..." },
      { "name": "...", "type": "..." }
    ]
    ```
